import 'package:flutter/material.dart';

import '../services/auth_service.dart';
import 'admin_screen.dart';

class ListeUsers extends StatefulWidget {
  @override
  _ListeUsersState createState() => _ListeUsersState();
}

class _ListeUsersState extends State<ListeUsers> {
  late Future<List<Map<String, dynamic>>?> _usersFuture;

  @override
  void initState() {
    super.initState();
    _usersFuture = AuthService().getUsersWithUserRole();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Color(0xFF00BCD0).withOpacity(0.88),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Liste des Clients'),
        automaticallyImplyLeading: false,
      ),
      drawer: Sidebar(
        authService: AuthService(),
        onSelectPage: (index) {},
        isDarkMode: false,
        toggleTheme: () {},
      ),

      body: FutureBuilder<List<Map<String, dynamic>>?>(
        future: _usersFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur : \${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucun utilisateur trouvé"));
          } else {
            List<Map<String, dynamic>> users = snapshot.data!;
            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: users.length,
              itemBuilder: (context, index) {
                final user = users[index];
                return Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                    side: BorderSide(
                      color: Color(0xFF00BCD0), // Couleur de la bordure
                      width: 2, // Largeur de la bordure
                    ),
                  ),

                  margin: EdgeInsets.symmetric(vertical: 8, horizontal: 16),
                  child: ListTile(
                    contentPadding: EdgeInsets.all(16),
                    leading: CircleAvatar(
                      backgroundColor: Color(0xFF00BCD0),
                      radius: 30,
                      child: Icon(Icons.person, color: Colors.white, size: 30),
                    ),
                    title: Row(
                      children: [
                        Icon(Icons.account_circle, size: 16, color: Color(0xFF00BCD0)),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            user['username'] ?? 'N/A',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                              color: Colors.black87,
                            ),
                          ),
                        ),
                      ],
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.email, size: 20, color: Color(0xFF00BCD0)),
                            SizedBox(width: 8),
                            Text(user['email'] ?? 'N/A', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                        SizedBox(height: 8),
                        Row(
                          children: [
                            Icon(Icons.phone, size: 20, color: Color(0xFF00BCD0)),
                            SizedBox(width: 8),
                            Text(user['phone'] ?? 'N/A', style: TextStyle(fontSize: 16)),
                          ],
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}