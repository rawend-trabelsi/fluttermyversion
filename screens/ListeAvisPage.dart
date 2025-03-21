import 'package:flutter/material.dart';

import '../models/Avis.dart';
import '../services/AvisService.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart'; // Modèle Avis

class ListeAvisPage extends StatefulWidget {
  @override
  _ListeAvisPageState createState() => _ListeAvisPageState();
}

class _ListeAvisPageState extends State<ListeAvisPage> {
  late Future<List<Avis>> _avisFuture;

  @override
  void initState() {
    super.initState();
    _avisFuture = AvisService().getAllAvis(); // Appel au service pour récupérer les avis
  }

  Map<String, List<Avis>> _groupAvisByService(List<Avis> avisList) {
    // Groupement des avis par titreService
    Map<String, List<Avis>> groupedAvis = {};
    for (var avis in avisList) {
      String key = avis.titreService ?? 'Service inconnu';
      if (!groupedAvis.containsKey(key)) {
        groupedAvis[key] = [];
      }
      groupedAvis[key]!.add(avis);
    }
    return groupedAvis;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text(
          'Liste des Avis',
          style: TextStyle(

            color: Colors.black,
          ),
        ),
        backgroundColor: Color(0xFF00BCD0).withOpacity(0.88),
        automaticallyImplyLeading: false,
      ),
      drawer: Sidebar(
        authService: AuthService(),
        onSelectPage: (index) {},
        isDarkMode: false,
        toggleTheme: () {},
      ),

      body: FutureBuilder<List<Avis>>(
        future: _avisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }
          else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(
              child: Text(
                "Aucun avis pour le moment",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey,
                ),
              ),
            );
          } else {
            // Grouping avis by service
            Map<String, List<Avis>> groupedAvis = _groupAvisByService(snapshot.data!);

            return ListView.builder(
              padding: EdgeInsets.all(10),
              itemCount: groupedAvis.keys.length,
              itemBuilder: (context, index) {
                String service = groupedAvis.keys.elementAt(index);
                List<Avis> avisList = groupedAvis[service]!;

                return Card(
                  elevation: 6,
                  shadowColor: Colors.grey.withOpacity(0.5),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15),
                  ),
                  margin: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  child: ExpansionTile(
                    title: Text(
                      service,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Color(0xFF00BCD0),

                      ),
                    ),
                    children: avisList.map((avis) {
                      return ListTile(
                        contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        title: Text(
                          avis.commentaire ?? 'Pas de commentaire',
                          style: TextStyle(fontSize: 14, color: Colors.black87),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.star_rate_rounded, color: Colors.amber, size: 16),
                                SizedBox(width: 4),
                                Text(
                                  '${avis.etoile} étoiles',
                                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.email_outlined, size: 16, color: Colors.redAccent),
                                SizedBox(width: 4),
                                Text(
                                  avis.email ?? 'Email inconnu',
                                  style: TextStyle(fontSize: 12, color: Colors.black54),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, size: 16, color: Colors.grey),
                      );
                    }).toList(),
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
