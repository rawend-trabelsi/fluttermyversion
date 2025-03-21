import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/Avis.dart';

class AvisService {
  final String apiUrl = "http://10.0.2.2:8085/api/avis";

  // Méthode pour récupérer les avis d'un service
  Future<List<Avis>> fetchAvis(int idService) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("Token JWT introuvable. Veuillez vous reconnecter.");
      }

      final response = await http.get(
        Uri.parse('$apiUrl/service/$idService'),
        headers: {
          "Authorization": "Bearer $token", // Ajout du JWT
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Avis.fromJson(e)).toList();
      } else {
        throw Exception(
            "Échec du chargement des avis : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur lors du chargement des avis : $e");
    }
  }

  // Méthode pour récupérer l'email de l'utilisateur à partir du token JWT
  Future<String> getEmailFromToken() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("Token JWT introuvable.");
      }

      final response = await http.get(
        Uri.parse('http://192.168.1.14:8085/api/avis/email'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return response.body; // Email renvoyé depuis le backend
      } else {
        throw Exception(
            "Échec de la récupération de l'email : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur lors de la récupération de l'email : $e");
    }
  }

  // Méthode pour récupérer le titre du service par ID
  Future<String> getTitreService(int serviceId) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("Token JWT introuvable.");
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:8085/api/avis/service/$serviceId/titre'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return response.body; // Titre du service renvoyé depuis le backend
      } else {
        throw Exception(
            "Échec de la récupération du titre du service : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(
          "Erreur lors de la récupération du titre du service : $e");
    }
  }

  // Méthode pour ajouter un avis
  Future<bool> ajouterAvis(Avis avis, String token) async {
    final response = await http.post(
      Uri.parse('$apiUrl/ajouter'), // Remplacez par votre endpoint
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: json.encode({
        'service': {
          'id': avis.serviceId,
        },
        'commentaire': avis.commentaire,
        'etoile': avis.etoile,
        'email': avis.email,
        'titreService': avis.titreService,
      }),
    );

    if (response.statusCode == 200) {
      // Si la requête est réussie, renvoyer true
      return true;
    } else {
      // Si la requête échoue, renvoyer false
      return false;
    }
  }

  Future<List<Avis>> getAllAvis() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("Token JWT introuvable. Veuillez vous reconnecter.");
      }

      final response = await http.get(
        Uri.parse('$apiUrl/all'),
        headers: {
          "Authorization": "Bearer $token", // Ajout du JWT
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        List<dynamic> body = jsonDecode(response.body);
        return body.map((e) => Avis.fromJson(e)).toList();
      } else {
        throw Exception(
            "Échec du chargement des avis : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Erreur lors du chargement des avis : $e");
    }
  }

  Future<double> calculerPourcentageAvis(int idService) async {
    try {
      // Récupérer les avis pour ce service
      List<Avis> avisList = await fetchAvis(idService);

      // Calculer le pourcentage d'avis (calculé comme le nombre d'avis par rapport au total d'avis possibles)
      double totalAvis = avisList.length.toDouble();

      // Si aucun avis n'est disponible, retourner 0%
      if (totalAvis == 0) {
        return 0.0;
      }

      // Calcul du pourcentage d'avis pour le service (en fonction du nombre d'avis)
      double pourcentageAvis = (totalAvis / totalAvis) * 100;

      // Retourner le pourcentage des avis
      return pourcentageAvis;
    } catch (e) {
      throw Exception("Erreur lors du calcul des pourcentages d'avis : $e");
    }
  }

  Future<int> getAvisCount() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString("jwt_token");

      if (token == null) {
        throw Exception("Token JWT introuvable. Veuillez vous reconnecter.");
      }

      final response = await http.get(
        Uri.parse('$apiUrl/count'),
        headers: {
          "Authorization": "Bearer $token",
          "Content-Type": "application/json",
        },
      );

      if (response.statusCode == 200) {
        return int.parse(response.body); // Convertir la réponse en entier
      } else {
        throw Exception(
            "Échec de la récupération du nombre total d'avis : ${response.statusCode}");
      }
    } catch (e) {
      throw Exception(
          "Erreur lors de la récupération du nombre total d'avis : $e");
    }
  }
}
