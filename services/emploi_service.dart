import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/TechnicienEmploi.dart';
import 'auth_service.dart';

class EmploiService {
  final String apiUrl = "http://10.0.2.2:8085/emplois";

  Future<String?> getToken() async {
    return await AuthService.getToken();
  }

  Future<List<String>> getEmailsTechniciens() async {
    try {
      // Récupérer le token depuis SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString(
          'jwt_token'); // Assurez-vous que le token est stocké sous cette clé

      if (token == null || token.isEmpty) {
        throw Exception('Token non trouvé');
      }

      // Envoi de la requête avec le token
      final response = await http.get(
        Uri.parse('$apiUrl/techniciens/emails'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        print("Réponse des techniciens: ${response.body}");

        // La réponse est un tableau de chaînes, donc on peut directement la décoder
        List<dynamic> techniciens = json.decode(response.body);

        // Retourner la liste des emails
        return List<String>.from(techniciens.map((email) => email as String));
      } else {
        // Gérer les erreurs spécifiques renvoyées par le serveur
        final errorResponse = json.decode(response.body);
        throw Exception(
            'Erreur: ${errorResponse['error']}, Message: ${errorResponse['message']}');
      }
    } catch (e) {
      print("Erreur lors de la récupération des emails: $e");
      throw Exception('Erreur de réseau ou d\'API: $e');
    }
  }

// Fonction pour récupérer les emplois des techniciens
  Future<List<TechnicienEmploi>> getTechniciensEmplois(String token) async {
    final response = await http.get(
      Uri.parse('$apiUrl/techniciens'),
      // Utilisation de l'URL de base + endpoint pour les emplois
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token', // Ajout du JWT token
      },
    );

    if (response.statusCode == 200) {
      List<dynamic> emploisData = json.decode(response.body);
      return emploisData
          .map((emploi) => TechnicienEmploi.fromJson(emploi))
          .toList(); // Adapter selon la structure de la réponse
    } else {
      throw Exception('Erreur lors de la récupération des emplois');
    }
  }

  // Ajouter un emploi pour un technicien
  // Ajouter un emploi pour un technicien
  Future<bool> ajouterEmploiTechnicien(TechnicienEmploi emploiRequest) async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Token non trouvé');
    }

    final response = await http.post(
      Uri.parse('$apiUrl/technicien/ajout'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode(emploiRequest.toJson()),
    );

    if (response.statusCode == 200) {
      return true;
    } else {
      throw Exception('ce technicien exitse');
    }
  }

  Future<bool> updateEmploiTechnicien(
      int id, TechnicienEmploi emploiRequest) async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Token non trouvé');
    }

    final response = await http.put(
      Uri.parse(
          '$apiUrl/technicien/update/$id'), // L'URL de mise à jour avec l'ID
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body:
          jsonEncode(emploiRequest.toJson()), // Conversion de l'objet à envoyer
    );

    if (response.statusCode == 200) {
      return true; // Mise à jour réussie
    } else {
      throw Exception(
          'Erreur lors de la mise à jour de l\'emploi: ${response.body}');
    }
  }

  Future<bool> emailTechnicienExiste(String email) async {
    String? token = await getToken();
    if (token == null) {
      throw Exception('Token non trouvé');
    }

    final response = await http.get(
      Uri.parse('$apiUrl/technicien/existe?email=$email'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      return json.decode(response.body) as bool; // Retourne true ou false
    } else {
      throw Exception(
          'Erreur lors de la vérification de l\'email: ${response.body}');
    }
  }
}
