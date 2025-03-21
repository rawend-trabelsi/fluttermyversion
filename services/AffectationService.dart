import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';


import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:projectlavage/models/AffectationTechnicien.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pour récupérer le token depuis SharedPreferences

class AffectationService {
  static const String apiUrl =
      'http://10.0.2.2:8085/reservations/affectations'; // URL de votre API

  // Méthode pour récupérer le token depuis SharedPreferences
  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token'); // Retourne le token enregistré
  }

  // Méthode pour récupérer les affectations en utilisant le token
  Future<List<AffectationTechnicien>> fetchAffectations() async {
    try {
      // Récupérer le token
      String? token = await getToken();

      if (token == null) {
        throw Exception('Token non trouvé');
      }

      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Authorization': 'Bearer $token'
        }, // Ajoutez le token à l'en-tête
      );

      if (response.statusCode == 200) {
        Map<String, dynamic> data = json.decode(response.body);

        List<AffectationTechnicien> affectations = [];
        data.forEach((key, value) {
          affectations.add(AffectationTechnicien.fromJson(value));
        });

        return affectations;
      } else {
        throw Exception('Failed to load affectations');
      }
    } catch (e) {
      throw Exception('Failed to load affectations: $e');
    }
  }
}
