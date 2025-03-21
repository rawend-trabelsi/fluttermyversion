import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/abonnement.dart';
import '../services/AbonnementService.dart';
import '../ThemeProvider.dart';
import 'Footer.dart';

class AbonnementUserPage extends StatefulWidget {
  @override
  _AbonnementUserPageState createState() => _AbonnementUserPageState();
}

class _AbonnementUserPageState extends State<AbonnementUserPage> {
  late Future<List<Abonnement>> _abonnements;

  @override
  void initState() {
    super.initState();
    _abonnements = AbonnementService().getAbonnements();
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          "Abonnements",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontWeight: FontWeight.bold,

          ),
        ),
        backgroundColor: Colors.cyan,
        elevation: 0,
        iconTheme: IconThemeData(color: isDarkMode ? Colors.white : Colors.black),
        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10), // Ajuste pour le mettre bien à droite
            child: IconButton(
              icon: Icon(
                isDarkMode ? Icons.dark_mode : Icons.wb_sunny,
                size: 30, // Taille de l'icône
                color: isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: () {
                themeProvider.toggleTheme();
              },

            ),
          ),
        ],
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const SizedBox(height: 10), // Espacement
          Expanded(
            child: FutureBuilder<List<Abonnement>>(
              future: _abonnements,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      "Erreur : ${snapshot.error}",
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  );
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Aucun abonnement disponible.",
                      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
                    ),
                  );
                }

                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    final abonnement = snapshot.data![index];
                    return Container(
                      margin: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.grey[800], // Même couleur pour mode clair et sombre
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: ListTile(
                        contentPadding: const EdgeInsets.all(10),
                        leading: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: abonnement.imageUrl.isNotEmpty
                              ? Image.memory(
                            base64Decode(abonnement.imageUrl),
                            width: 60,
                            height: 60,
                            fit: BoxFit.cover,
                          )
                              : Icon(Icons.image, size: 60, color: isDarkMode ? Colors.white : Colors.black),
                        ),
                        title: Text(
                          abonnement.titre,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white, // Texte en blanc pour contraste
                          ),
                        ),
                        subtitle: Text(
                          abonnement.prix == abonnement.prix.toInt()
                              ? '${abonnement.prix.toInt()} DT'
                              : '${abonnement.prix.toStringAsFixed(2)} DT',
                          style: TextStyle(fontSize: 14, color: Colors.grey[400]),
                        ),
                        trailing: TextButton(
                          onPressed: () {
                            // Action abonnement
                          },
                          style: TextButton.styleFrom(
                            backgroundColor: Colors.blueGrey[400], // Couleur du bouton inchangée
                            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          child: const Text(
                            "Abonner",
                            style: TextStyle(
                              color: Colors.white, // Toujours blanc pour contraste
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
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
      bottomNavigationBar: Footer(
        currentIndex: 2,
        isDarkMode: isDarkMode,
        toggleTheme: () => themeProvider.toggleTheme(),
        onTap: (index) {
          if (index != 2) {
            Navigator.pushReplacementNamed(context, '/profile');
          }
        },
      ),
    );
  }
}
