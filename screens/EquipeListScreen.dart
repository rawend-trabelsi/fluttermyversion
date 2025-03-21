
import 'package:flutter/material.dart';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/EquipeService.dart';
import '../services/auth_service.dart';

import 'AddEquipeScreen.dart';
import 'admin_screen.dart';
import 'editEquipeScreen.dart';


class EquipeListScreen extends StatefulWidget {
  @override
  _EquipeListScreenState createState() => _EquipeListScreenState();
}

class _EquipeListScreenState extends State<EquipeListScreen> {
  final EquipeService equipeService = EquipeService();
  late Future<List<User>> futureUsers;
  List<User> filteredUsers = [];
  TextEditingController searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    loadUsers();

    searchController.addListener(() {
      filterUsers();
    });
  }

  void loadUsers() {
    futureUsers = equipeService.getUsers();
    futureUsers.then((users) {
      setState(() {
        filteredUsers = users;
      });
    });
  }

  void filterUsers() {
    final query = searchController.text.toLowerCase();
    futureUsers.then((users) {
      setState(() {
        filteredUsers = users.where((user) {
          return user.username.toLowerCase().contains(query) ||
              user.email.toLowerCase().contains(query);
        }).toList();
      });
    });
  }

  Future<void> showDeleteConfirmationDialog(int userId) async {
    bool? confirmDelete = await showDialog<bool>(
      context: context,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.warning_amber_rounded,
                  color: Colors.redAccent,
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Confirmation de suppression',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.redAccent,
                  ),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 10),
                Text(
                  'Êtes-vous sûr de vouloir supprimer cet membre ?',
                  style: TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(false);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.grey,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Annuler',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.of(context).pop(true);
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.redAccent,
                        padding: EdgeInsets.symmetric(
                            horizontal: 20, vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                      ),
                      child: Text(
                        'Supprimer',
                        style: TextStyle(fontSize: 16, color: Colors.white),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );

    if (confirmDelete == true) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Membre supprimé avec succès'),
          backgroundColor: Color(0xFF00BCD0),
          duration: Duration(seconds: 3),

        ),
      );

      await equipeService.deleteUser(userId);
      loadUsers();
      // Rafraîchir la liste après suppression
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste Membres'),
        backgroundColor: Color(0xFF00BCD0).withOpacity(0.88),
        centerTitle: true,
      ),

      drawer: Sidebar(
        authService: AuthService(),
        onSelectPage: (index) {},
        isDarkMode: false,
        toggleTheme: () {},
      ),

      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              controller: searchController,
              decoration: InputDecoration(
                hintText: 'Rechercher par email ou username',
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8.0),
                ),
              ),
            ),
          ),
          Expanded(
            child: FutureBuilder<List<User>>(
              future: futureUsers,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                }

                if (filteredUsers.isEmpty) {
                  return Center(
                    child: Text(
                      searchController.text.isEmpty
                          ? 'Aucun utilisateur trouvé.'
                          : 'Aucun utilisateur ou email  ne correspond à votre recherche.',
                      style: TextStyle(fontSize: 16, color: Colors.grey),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: filteredUsers.length,
                  itemBuilder: (context, index) {
                    final user = filteredUsers[index];
                    return Card(
                      elevation: 5,
                      margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                        side: BorderSide(color: Color(0xFF00BCD0), width: 2),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Icon(Icons.account_circle, size: 40, color: Colors.blue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    user.username,
                                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ],
                            ),
                            Divider(color: Colors.grey[300], thickness: 1, height: 20),
                            Row(
                              children: [
                                Icon(Icons.email, color: Colors.blue),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Email: ${user.email}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.phone, color: Colors.green),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Téléphone: ${user.phone ?? "Non spécifié"}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.work, color: Colors.orange),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Rôle: ${user.role ?? "Non spécifié"}',
                                    style: TextStyle(fontSize: 16),
                                  ),
                                ),
                              ],
                            ),
                            SizedBox(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton.icon(
                                  onPressed: () async {
                                    final result = await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditEquipeScreen(user: user),
                                      ),
                                    );
                                    if (result != null && result == true) {
                                      loadUsers(); // Refresh list after editing
                                    }
                                  },
                                  icon: Icon(Icons.edit, color: Colors.white),
                                  label: Text('Éditer', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                                SizedBox(width: 8),
                                ElevatedButton.icon(
                                  onPressed: () {
                                    showDeleteConfirmationDialog(user.id!);
                                  },
                                  icon: Icon(Icons.delete, color: Colors.white),
                                  label: Text('Supprimer', style: TextStyle(color: Colors.white)),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.red,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(20),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xFF00BCD0),
        onPressed: () async {
          final result = await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AddEquipeScreen()),
          );
          if (result != null && result == true) {
            loadUsers(); // Refresh list after adding a new user
          }
        },
        child: Icon(Icons.add),
      ),
    );
  }
}