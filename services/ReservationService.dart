import 'dart:convert';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/reservation_model.dart';
import '../screens/ApiException.dart';

class ReservationService {
  static const String baseUrl = "http://10.0.2.2:8085/reservations";

  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString(
        'jwt_token'); // Assure-toi que le token est bien stocké sous cette clé
  }
  Future<List<Reservation>> fetchReservations() async {
    try {
      String? token = await getToken(); // Récupérer le token

      if (token == null) {
        throw Exception("Token non disponible !");
      }

      final response = await http.get(
        Uri.parse(baseUrl),
        headers: {
          'Authorization': 'Bearer $token', // Ajouter le token
          'Content-Type': 'application/json',
        },
      );

      print("Réponse reçue: ${response.statusCode}");
      print("Corps de la réponse: ${response.body}");

      if (response.statusCode == 200) {
        List<dynamic> jsonResponse = json.decode(response.body);
        return jsonResponse.map((data) => Reservation.fromJson(data)).toList();
      } else {
        throw Exception('Échec du chargement des réservations');
      }
    } catch (e) {
      print("Erreur: $e");
      throw Exception("Erreur lors de la récupération des réservations");
    }
  }

  Future<void> affecterTechnicien(
      int reservationId, String emailTechnicien, BuildContext context) async {
    try {
      // Récupérer le token depuis SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        throw Exception('Token non trouvé');
      }

      // Envoi de la requête HTTP avec le token
      final response = await http.put(
        Uri.parse(
            "$baseUrl/$reservationId/affecter-technicien-par-email/$emailTechnicien"),
        headers: {
          "Content-Type": "application/json",
          "Authorization": "Bearer $token",
        },
      );

      // Log pour déboguer
      print("Response Status: ${response.statusCode}");
      print("Response Body: ${response.body}");

      // Gestion des différentes réponses HTTP
      if (response.statusCode == 404) {
        if (response.body.contains("Réservation introuvable")) {
          throw ApiException(
              'Réservation introuvable. Veuillez vérifier l\'ID de la réservation.');
        } else if (response.body.contains("Technicien introuvable")) {
          throw ApiException(
              'Technicien introuvable. Vérifiez l\'adresse e-mail du technicien.');
        } else {
          throw ApiException('Erreur 404: Ressource introuvable.');
        }
      } else if (response.statusCode == 400) {
        // Gestion des erreurs 400 avec messages spécifiques
        if (response.body.contains("Le technicien est en repos")) {
          throw ApiException(
              'Le technicien est en repos ce jour-là. Veuillez choisir un autre technicien.');
        } else if (response.body.contains(
            "La reservation dépasse les horaires de travail du technicien")) {
          // Extraire les horaires de travail du message d'erreur
          final regex = RegExp(r'\((\d{2}:\d{2}) - (\d{2}:\d{2})\)');
          final match = regex.firstMatch(response.body);
          if (match != null) {
            final heureDebut = match.group(1);
            final heureFin = match.group(2);
            throw ApiException(
                'La reservation dépasse les horaires de travail du technicien. Les horaires sont de $heureDebut à $heureFin.');
          } else {
            throw ApiException(
                'La reservation dépasse les horaires de travail du technicien.');
          }
        } else if (response.body
            .contains("Le technicien a déjà une réservation entre")) {
          // Extraire la plage horaire du message d'erreur
          final regex = RegExp(r'(\d{2}:\d{2}) et (\d{2}:\d{2})');
          final match = regex.firstMatch(response.body);
          if (match != null) {
            final dateDebut = match.group(1);
            final dateFin = match.group(2);
            throw ApiException(
                'Le technicien a déjà une reservation entre $dateDebut et $dateFin.');
          } else {
            throw ApiException(
                'Le technicien a déjà une reservation sur cette plage horaire.');
          }
        } else {
          if (response.statusCode == 400) {
            try {
              throw ApiException(response.body);
            } catch (e) {
              // En cas d'erreur de décodage JSON, utiliser le corps de la réponse tel quel
              final responseBody =
                  json.decode(response.body); // Décoder le JSON
              final errorMessage =
                  responseBody['message']; // Extraire le message
              throw ApiException(errorMessage);
            }
          }
        }
      } else if (response.statusCode == 200) {
        // Succès
        _showSuccessMessage(context,
            'Le technicien a été affecté avec succès à la réservation.');
      } else {
        if (response.statusCode == 400) {
          try {
            throw ApiException(response.body);
          } catch (e) {
            // En cas d'erreur de décodage JSON, utiliser le corps de la réponse tel quel
            final responseBody = json.decode(response.body); // Décoder le JSON
            final errorMessage = responseBody['message']; // Extraire le message
            throw ApiException(errorMessage);
          }
        }
      }
    } on ApiException catch (e) {
      // Gestion des exceptions personnalisées
      _showErrorMessage(context, e.toString()); // Affiche uniquement le message
    } catch (e) {
      // Gestion des erreurs générales (erreurs réseau, etc.)
      print("Erreur: $e");
      _showErrorMessage(context, 'Erreur: $e');
    }
  }

  void _showErrorMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  void _showSuccessMessage(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
      ),
    );
  }

  Future<void> updateTechnicienReservation(
      int reservationId, String emailTechnicien, BuildContext context) async {
    try {
      // Récupérer le token d'authentification depuis SharedPreferences
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        throw Exception("Token d'authentification non trouvé");
      }

      // Construire l'URL de l'endpoint
      final url = Uri.parse(
          '$baseUrl/$reservationId/modifier-affectation/$emailTechnicien');

      // Envoyer la requête PUT
      final response = await http.put(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // Ajouter le token dans l'en-tête
        },
      );

      // Vérifier la réponse
      if (response.statusCode == 200) {
        // Succès
        print("Technicien modifié avec succès !");
        _showSuccessMessage(
            context, 'Le technicien a été modifié avec succès.');
      } else if (response.statusCode == 404) {
        // Gestion des erreurs 404
        if (response.body.contains("Réservation introuvable")) {
          throw ApiException(
              'Réservation introuvable. Veuillez vérifier l\'ID de la réservation.');
        } else if (response.body.contains("Technicien introuvable")) {
          throw ApiException(
              'Technicien introuvable. Vérifiez l\'adresse e-mail du technicien.');
        } else {
          throw ApiException('Erreur 404: Ressource introuvable.');
        }
      } else if (response.statusCode == 400) {
        // Gestion des erreurs 400 avec messages spécifiques
        if (response.body.contains("Le technicien est en repos")) {
          throw ApiException(
              'Le technicien est en repos ce jour-là. Veuillez choisir un autre technicien.');
        } else if (response.body.contains(
            "La reservation dépasse les horaires de travail du technicien")) {
          // Extraire les horaires de travail du message d'erreur
          final regex = RegExp(r'\((\d{2}:\d{2}) - (\d{2}:\d{2})\)');
          final match = regex.firstMatch(response.body);
          if (match != null) {
            final heureDebut = match.group(1);
            final heureFin = match.group(2);
            throw ApiException(
                'La réservation dépasse les horaires de travail du technicien. Les horaires sont de $heureDebut à $heureFin.');
          } else {
            throw ApiException(
                'La réservation dépasse les horaires de travail du technicien.');
          }
        } else if (response.body
            .contains("Le technicien a déjà une réservation entre")) {
          // Extraire la plage horaire du message d'erreur
          final regex = RegExp(r'(\d{2}:\d{2}) et (\d{2}:\d{2})');
          final match = regex.firstMatch(response.body);
          if (match != null) {
            final dateDebut = match.group(1);
            final dateFin = match.group(2);
            throw ApiException(
                'Le technicien a déjà une réservation entre $dateDebut et $dateFin.');
          } else {
            throw ApiException(
                'Le technicien a déjà une réservation sur cette plage horaire.');
          }
        } else {
          // En cas d'erreur générique dans le corps de la réponse
          try {
            throw ApiException(response.body);
          } catch (e) {
            final responseBody = json.decode(response.body); // Décoder le JSON
            final errorMessage = responseBody['message']; // Extraire le message
            throw ApiException(
                errorMessage); // Lever l'exception avec le message
          }
        }
      } else {
        throw Exception(
            'Échec de la mise à jour du technicien : ${response.body}');
      }
    } on ApiException catch (e) {
      // Gestion des exceptions personnalisées
      _showErrorMessage(context, e.toString()); // Affiche uniquement le message
    } catch (e) {
      // Gestion des erreurs générales (erreurs réseau, etc.)
      print("Erreur: $e");
      _showErrorMessage(context, 'Erreur: $e');
    }
  }
}
