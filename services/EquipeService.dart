import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/UserUpdateRequest.dart';
import '../models/user.dart';

class EquipeService {
  static const String apiUrl = 'http://10.0.2.2:8096/api/v1/auth/admin';

  // Fonction pour récupérer le token JWT stocké dans SharedPreferences
  Future<String?> getToken() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    return prefs.getString('jwt_token');
  }

  // Ajouter un utilisateur
  Future<bool> addUser(User user) async {
    final String? token = await getToken();
    if (token == null) return false;

    final response = await http.post(
      Uri.parse('$apiUrl/add-user'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(user
          .toJson()), // Assurez-vous que l'objet User a une méthode toJson()
    );

    return response.statusCode == 200;
  }

  // Mettre à jour un utilisateur
  Future<void> updateUser(UserUpdateRequest userUpdateRequest) async {
    if (userUpdateRequest.id == null) {
      throw Exception("L'ID de l'utilisateur est nul");
    }

    final response = await http.put(
      Uri.parse('$apiUrl/update-user/${userUpdateRequest.id}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization':
            'Bearer ${await getToken()}', // Si vous utilisez un token JWT
      },
      body: json.encode(userUpdateRequest
          .toJson()), // Conversion de l'objet UserUpdateRequest en JSON
    );

    if (response.statusCode == 200) {
      print("User updated successfully");
    } else {
      print("Failed to update user: ${response.statusCode}");
      throw Exception('Failed to update user');
    }
  }

  // Supprimer un utilisateur
  Future<bool> deleteUser(int id) async {
    final String? token = await getToken();
    if (token == null) return false;

    final response = await http.delete(
      Uri.parse('$apiUrl/delete-user/$id'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    return response.statusCode == 200;
  }

  // Obtenir la liste des utilisateurs
  Future<List<User>> getUsers() async {
    final String? token = await getToken();
    if (token == null) return [];

    final response = await http.get(
      Uri.parse('$apiUrl/users'),
      headers: {
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> usersJson = jsonDecode(response.body);
      return usersJson.map((json) => User.fromJson(json)).toList();
    } else {
      return [];
    }
  }
}
