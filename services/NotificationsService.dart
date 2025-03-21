import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:web_socket_channel/web_socket_channel.dart';
import '../models/technician_notification.dart';
import '../screens/ApiException.dart';

class NotificationService {
  final String baseUrl;

  NotificationService(this.baseUrl);

  // ✅ Récupérer le token JWT stocké en local
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // ✅ Extraire l'email de l'utilisateur à partir du token JWT
  Future<String?> getUserEmailFromToken() async {
    try {
      String? token = await getToken();
      if (token == null) {
        debugPrint("🚨 Aucun token trouvé ! L'utilisateur doit se reconnecter.");
        return null;
      }

      // Décoder le JWT (base64)
      List<String> tokenParts = token.split('.');
      if (tokenParts.length != 3) throw Exception("JWT invalide");

      String payload = utf8.decode(base64Url.decode(base64Url.normalize(tokenParts[1])));
      Map<String, dynamic> decodedPayload = json.decode(payload);

      String? email = decodedPayload['sub']; // 'sub' contient généralement l'email dans le JWT
      debugPrint("📧 Email extrait du token : $email");

      return email;
    } catch (e) {
      debugPrint("❌ Erreur extraction email depuis JWT : $e");
      return null;
    }
  }

  // ✅ Récupérer les notifications du technicien
  Future<List<TechnicianNotification>> getNotifications() async {
    try {
      String? token = await getToken();
      if (token == null) throw ApiException("Utilisateur non authentifié !");

      String? userEmail = await getUserEmailFromToken();
      if (userEmail == null) throw ApiException("Impossible d'extraire l'email utilisateur !");

      String encodedEmail = Uri.encodeComponent(userEmail);
      final url = "$baseUrl/api/notifications/$encodedEmail";

      debugPrint("📡 Envoi requête GET à: $url");

      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("📩 Réponse reçue: ${response.statusCode}");
      debugPrint("🔍 Corps de la réponse: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => TechnicianNotification.fromJson(data)).toList();
      } else {
        throw ApiException("Échec du chargement des notifications : ${response.statusCode}");
      }
    } catch (e) {
      debugPrint("❌ Erreur récupération notifications: $e");
      throw ApiException("Erreur lors de la récupération des notifications");
    }
  }

  // ✅ Marquer une notification comme lue
  Future<void> markNotificationAsRead(int notificationId) async {
    try {
      String? token = await getToken();
      if (token == null) throw ApiException("Utilisateur non authentifié !");

      final response = await http.put(
        Uri.parse("$baseUrl/api/notifications/$notificationId/read"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("✅ Notification mise à jour: ${response.statusCode}");
      if (response.statusCode != 200) {
        throw ApiException("Impossible de marquer la notification comme lue");
      }
    } catch (e) {
      debugPrint("❌ Erreur mise à jour notification: $e");
      throw ApiException("Erreur lors de la mise à jour de la notification");
    }
  }

  // ✅ Supprimer une notification
  Future<void> deleteNotification(int notificationId) async {
    try {
      String? token = await getToken();
      if (token == null) throw ApiException("Utilisateur non authentifié !");

      final response = await http.delete(
        Uri.parse("$baseUrl/api/notifications/$notificationId"),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      debugPrint("🗑️ Suppression notification: ${response.statusCode}");
      if (response.statusCode != 200) {
        throw ApiException("Échec de la suppression de la notification");
      }
    } catch (e) {
      debugPrint("❌ Erreur suppression notification: $e");
      throw ApiException("Erreur lors de la suppression de la notification");
    }
  }

  // ✅ Connexion WebSocket pour recevoir les notifications en temps réel
  Future<WebSocketChannel?> connectToNotificationSocket() async {
    try {
      String? userEmail = await getUserEmailFromToken();
      if (userEmail == null) {
        debugPrint("❌ Impossible d'établir la connexion WebSocket : email non trouvé.");
        return null;
      }

      String encodedEmail = Uri.encodeComponent(userEmail);
      final wsUrl = 'ws://${baseUrl.replaceFirst('http://', '')}/api/notifications/$encodedEmail';
      debugPrint("🔗 Connexion WebSocket à : $wsUrl");

      return WebSocketChannel.connect(Uri.parse(wsUrl));
    } catch (e) {
      debugPrint("❌ Erreur connexion WebSocket: $e");
      return null;
    }
  }

  // ✅ Stream pour récupérer le nombre de notifications non lues
  Stream<int> getUnreadNotificationsCountStream() async* {
    while (true) {
      try {
        final notifications = await getNotifications();
        int unreadCount = notifications.where((n) => !n.isRead).length;
        yield unreadCount;
      } catch (e) {
        debugPrint("Erreur récupération notifications non lues: $e");
        yield 0;
      }
      await Future.delayed(Duration(seconds: 10)); // Vérifier toutes les 10 secondes
    }
  }
}
