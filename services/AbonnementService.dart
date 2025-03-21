import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pour utiliser SharedPreferences
import '../models/abonnement.dart';
import 'package:path/path.dart' as path;

class AbonnementService {
  static const String _baseUrl = 'http://10.0.2.2:8085/api/abonnements';

  // Récupérer le token JWT stocké dans SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Lire le token JWT depuis SharedPreferences
  }

  // Récupérer tous les abonnements
  Future<List<Abonnement>> getAbonnements() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((abonnement) => Abonnement.fromJson(abonnement)).toList();
    } else {
      throw Exception('Erreur de récupération des abonnements');
    }
  }

  // Créer un abonnement avec image et données
  Future<void> createAbonnement(
    String titre,
    double prix,
    XFile? imageFile,
  ) async {
    String? token = await _getToken();
    var uri = Uri.parse(_baseUrl);
    var request = http.MultipartRequest("POST", uri);

    // Ajouter les champs de texte (titre et prix)
    request.fields['titre'] = titre;
    request.fields['prix'] = prix.toString();

    // Ajouter l'image si elle est choisie
    if (imageFile != null) {
      var file = await http.MultipartFile.fromPath(
        'image', // Nom du champ du fichier
        imageFile.path,
        filename: path.basename(imageFile.path),
      );
      request.files.add(file);
    }

    // Ajouter le token JWT dans l'en-tête
    if (token != null) {
      request.headers.addAll({'Authorization': 'Bearer $token'});
    }

    // Envoyer la requête
    var response = await request.send();

    if (response.statusCode == 201) {
      print("Abonnement créé avec succès");
    } else {
      throw Exception('Erreur lors de la création de l\'abonnement');
    }
  }

  // Mettre à jour un abonnement
  Future<Abonnement> updateAbonnement({
    required int id,
    required String titre,
    required double prix,
    XFile? imageFile, // Nouvelle image choisie
  }) async {
    String? token = await _getToken();
    var uri = Uri.parse('$_baseUrl/$id');
    var request = http.MultipartRequest('PUT', uri);

    // Ajouter les champs de texte (titre et prix)
    request.fields['titre'] = titre;
    request.fields['prix'] = prix.toString();

    // Ajouter l'image si elle est choisie
    if (imageFile != null) {
      var file = await http.MultipartFile.fromPath(
        'image', // Nom du champ du fichier
        imageFile.path,
        filename: path.basename(imageFile.path),
      );
      request.files.add(file);
    }

    // Ajouter le token JWT dans l'en-tête
    if (token != null) {
      request.headers.addAll({'Authorization': 'Bearer $token'});
    }

    // Envoyer la requête
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      return Abonnement.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Erreur lors de la mise à jour de l\'abonnement: ${response.statusCode} - ${response.body}');
    }
  }

  // Supprimer un abonnement
  Future<void> deleteAbonnement(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression de l\'abonnement');
    }
  }

  Future<int> getAbonnementCount() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/count'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception(
          'Erreur lors de la récupération du nombre d\'abonnements');
    }
  }
}
