import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../models/PromotionDTO.dart';

class PromotionService {
  final String apiUrl = 'http://192.168.1.14:8085/api/promotions';
  Future<String> addPromotion(PromotionDTO promotion) async {
    try {
      // 🔹 Récupérer le token JWT depuis SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('jwt_token') ?? '';

      if (token.isEmpty) {
        throw Exception("Token non disponible, veuillez vous reconnecter.");
      }

      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
        body: jsonEncode(promotion.toJson()),
      );

      if (response.statusCode == 200) {
        return "Promotion ajoutée avec succès";
      } else {
        throw Exception(
            "Erreur lors de l'ajout de la promotion: ${response.body}");
      }
    } catch (e) {
      throw Exception("Erreur: $e");
    }
  }

  Future<PromotionDTO> updatePromotion(PromotionDTO promotion) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('jwt_token') ?? '';

    final response = await http.put(
      Uri.parse(
          '$apiUrl/update/${promotion.id}'), // Assurez-vous que l'ID est bien inclus
      headers: {
        "Content-Type": "application/json",
        "Authorization": "Bearer $token",
      },
      body: jsonEncode(promotion.toJson()),
    );

    if (response.statusCode == 200) {
      return PromotionDTO.fromJson(jsonDecode(response.body));
    } else {
      throw Exception(
          "Erreur lors de la mise à jour de la promotion: ${response.body}");
    }
  }

  Future<Map<String, String>> getAuthHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token'); // Récupérer le token JWT

    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }

  Future<List<PromotionDTO>> getPromotions() async {
    try {
      print("Envoi de la requête GET à $apiUrl");
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: await getAuthHeaders(), // Gestion du JWT
      );

      print("Réponse reçue : ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        // Vérifier que la réponse est complète
        if (response.body.isEmpty) {
          throw Exception("La réponse est vide.");
        }

        // Afficher la réponse complète pour déboguer
        print("Réponse complète : ${response.body}");

        // Désérialiser le JSON
        List<dynamic> jsonData = jsonDecode(response.body);
        print("Données JSON reçues : $jsonData");

        // Vérifier que les données sont bien une liste
        if (jsonData is List) {
          return jsonData.map((promo) => PromotionDTO.fromJson(promo)).toList();
        } else {
          throw Exception("Les données reçues ne sont pas une liste.");
        }
      } else {
        throw Exception(
            "Erreur lors du chargement des promotions: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("Erreur lors de la récupération des promotions : $e");
      throw Exception("Erreur réseau : $e");
    }
  }

  Future<String> deletePromotion(int id) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('jwt_token');

    if (token == null) {
      throw Exception('Authentication token is missing');
    }

    final headers = {
      'Authorization': 'Bearer $token',
      'Content-Type': 'application/json',
    };

    // Construction de l'URL avec l'ID de la promotion
    final String url = "$apiUrl/delete/$id";

    final response = await http.delete(
      Uri.parse(url), // Utilisation de l'URL construite
      headers: headers,
    );

    if (response.statusCode == 200) {
      return 'Promotion supprimée avec succès';
    } else {
      throw Exception('Échec de la suppression de la promotion');
    }
  }

  Future<int> getPromotionCount() async {
    try {
      List<PromotionDTO> promotions = await fetchPromotions();
      print("Nombre de promotions récupérées : ${promotions.length}");
      return promotions.length;
    } catch (e) {
      print("Erreur lors du comptage des promotions : $e");
      return 0;
    }
  }

  Future<List<PromotionDTO>> fetchPromotions() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null) {
        throw Exception('Authentication token is missing');
      }

      final headers = {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      };

      final response = await http.get(Uri.parse(apiUrl), headers: headers);

      if (response.statusCode == 200) {
        List<dynamic> jsonData = jsonDecode(response.body);
        return jsonData.map((promo) => PromotionDTO.fromJson(promo)).toList();
      } else {
        throw Exception(
            "Erreur lors de la récupération des promotions: ${response.body}");
      }
    } catch (e) {
      throw Exception("Erreur réseau : $e");
    }
  }

  Future<Map<String, dynamic>> applyPromoCode(
      String codePromo, int serviceId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        throw Exception("Utilisateur non connecté.");
      }

      // Corps de la requête
      final requestBody = {
        'codePromo': codePromo,
        'serviceId': serviceId,
      };

      // Envoyer la requête POST
      final response = await http.post(
        Uri.parse('$apiUrl/apply'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      // Gérer la réponse
      if (response.statusCode == 200) {
        return json.decode(response.body);
      } else {
        final errorData = json.decode(response.body);
        throw Exception(errorData['error'] ?? "Erreur inconnue");
      }
    } catch (e) {
      throw Exception("Erreur de connexion au serveur : $e");
    }
  }
}
