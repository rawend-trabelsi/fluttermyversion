import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart';
import 'package:shared_preferences/shared_preferences.dart'; // Pour utiliser SharedPreferences
import '../models/ServiceDTO.dart';
import '../models/service.dart';
import 'package:path/path.dart' as path;

class ServiceService {
  static const String _baseUrl = 'http://10.0.2.2:8085/api/services';

  // Récupérer le token JWT stocké dans SharedPreferences
  Future<String?> _getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs
        .getString('jwt_token'); // Lire le token JWT depuis SharedPreferences
  }

  Future<List<ServiceDTO>> getServicesDTO() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode == 200) {
      // Désérialiser les données JSON en List<Service>
      List<dynamic> data = json.decode(response.body);
      List<Service> services =
          data.map((service) => Service.fromJson(service)).toList();

      // Convertir List<Service> en List<ServiceDTO>
      List<ServiceDTO> servicesDTO = services.map((service) {
        return ServiceDTO(
          id: service.id,
          titre: service.titre,
        );
      }).toList();

      return servicesDTO;
    } else {
      throw Exception('Erreur de récupération des services');
    }
  }

  // Récupérer tous les services
  Future<List<Service>> getServices() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((service) => Service.fromJson(service)).toList();
    } else {
      throw Exception('Erreur de récupération des services');
    }
  }

  Future<List<Service>> getServicesAdmin() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/admin'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((service) => Service.fromJson(service)).toList();
    } else {
      throw Exception('Erreur de récupération des services');
    }
  }

  // Méthode pour créer un service avec image et données
  Future<void> createService(String titre, String description, double prix,
      String duree, XFile? imageFile) async {
    String? token = await _getToken();
    var uri = Uri.parse(_baseUrl);
    var request = http.MultipartRequest("POST", uri);

    // Ajouter les champs de texte
    request.fields['titre'] = titre;
    request.fields['description'] = description;
    request.fields['prix'] = prix.toString();
    request.fields['duree'] = duree;

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
      print("Service créé avec succès");
    } else {
      throw Exception('Erreur lors de la création du service');
    }
  }

  Future<Service> updateService({
    required int id,
    required String titre,
    required String description,
    required double prix,
    required String duree,
    XFile? imageFile, // Nouvelle image choisie
    String? promotion_id, // Ajout du champ promotionId (optionnel)
  }) async {
    String? token = await _getToken();
    var uri = Uri.parse('$_baseUrl/$id');
    var request = http.MultipartRequest('PUT', uri);

    // Ajouter les champs de texte obligatoires
    request.fields['titre'] = titre;
    request.fields['description'] = description;
    request.fields['prix'] = prix.toString();
    request.fields['duree'] = duree;

    // Toujours ajouter promotion_id, même s'il est null
    request.fields['promotion_id'] =
        promotion_id ?? ''; // Si null, envoyer une chaîne vide

    // Nom et base64 de l'image
    String? imageBase64 = '';
    String? imageName = '';

    // Si une nouvelle image est sélectionnée
    if (imageFile != null) {
      final bytes = await imageFile.readAsBytes();
      imageBase64 = base64Encode(bytes);
      imageName = basename(imageFile.path); // Nom du fichier image
    }

    // Ajouter les champs 'image' et 'imageName'
    request.fields['image'] =
        imageBase64 ?? ''; // Si aucune image, envoyer une chaîne vide
    request.fields['imageName'] =
        imageName ?? ''; // Nom de l'image, vide ou existant

    // Ajouter l'entête d'autorisation avec le token JWT
    if (token != null) {
      request.headers.addAll({'Authorization': 'Bearer $token'});
    }

    // Si une nouvelle image est encodée, l'ajouter comme fichier multipart
    if (imageFile != null) {
      final imageBytes = await imageFile.readAsBytes();
      var imageFilePart = http.MultipartFile.fromBytes(
        'image',
        imageBytes,
        filename: imageName,
      );
      request.files.add(imageFilePart);
    }

    // Envoyer la requête PUT
    var streamedResponse = await request.send();
    var response = await http.Response.fromStream(streamedResponse);

    // Vérifier la réponse
    if (response.statusCode == 200) {
      return Service.fromJson(json.decode(response.body));
    } else {
      throw Exception(
          'Erreur lors de la mise à jour du service: ${response.statusCode} - ${response.body}');
    }
  }

  // Supprimer un service
  Future<void> deleteService(int id) async {
    final token = await _getToken();
    final response = await http.delete(
      Uri.parse('$_baseUrl/$id'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode != 204) {
      throw Exception('Erreur lors de la suppression du service');
    }
  }

  Future<List<String>> getServiceTitles() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/titres'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return List<String>.from(
          data); // Convertir les titres en une liste de String
    } else {
      throw Exception('Erreur de récupération des titres des services');
    }
  }
  // Ajouter une méthode pour obtenir le nombre de services

  Future<int> getServiceCount() async {
    final token = await _getToken();
    final response = await http.get(
      Uri.parse('$_baseUrl/count'),
      headers: token != null ? {'Authorization': 'Bearer $token'} : {},
    );

    if (response.statusCode == 200) {
      return int.parse(response.body);
    } else {
      throw Exception('Erreur lors de la récupération du nombre de services');
    }
  }
}
