import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/Avis.dart';
import '../services/AvisService.dart';
import '../ThemeProvider.dart';
import 'AjouterAvisScreen.dart';
import 'Footer.dart';

class ListeAvisScreen extends StatefulWidget {
  final int idService;

  ListeAvisScreen({required this.idService});

  @override
  _ListeAvisScreenState createState() => _ListeAvisScreenState();
}

class _ListeAvisScreenState extends State<ListeAvisScreen> {
  late Future<List<Avis>> avisFuture;
  final AvisService avisService = AvisService();

  @override
  void initState() {
    super.initState();
    avisFuture = avisService.fetchAvis(widget.idService);
  }

  Widget buildStars(int etoiles) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        return Icon(
          index < etoiles ? Icons.star : Icons.star_border,
          color: Colors.amber,
          size: 20,
        );
      }),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: const Text(
          'Liste des avis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Colors.cyan,
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
        children: [
          Expanded(
            child: FutureBuilder<List<Avis>>(
              future: avisFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
                  return Center(
                    child: Text(
                      "Soyez les premiers à laisser votre avis !",
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isDarkMode ? Colors.grey[400] : Colors.grey,
                      ),
                    ),
                  );
                } else {
                  return ListView.builder(
                    itemCount: snapshot.data!.length,
                    itemBuilder: (context, index) {
                      Avis avis = snapshot.data![index];
                      return Card(
                        color: isDarkMode ? Colors.grey[900] : Colors.white,

                        margin: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Text(
                                    avis.email,
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: isDarkMode ? Colors.grey[400] : Colors.grey[700],
                                    ),
                                  ),
                                  Spacer(),
                                  buildStars(avis.etoile),
                                ],
                              ),
                              SizedBox(height: 10),
                              Text(
                                avis.commentaire,
                                style: TextStyle(
                                  fontSize: 16,
                                  color: isDarkMode ? Colors.white : Colors.black,
                                ),
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
          ),
          Padding(
            padding: const EdgeInsets.all(10.0),
            child: SizedBox(
              width: 200,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AjouterAvisScreen(
                        serviceId: widget.idService,
                        serviceTitre: "Nom du service",
                      ),
                    ),
                  ).then((_) {
                    setState(() {
                      avisFuture = avisService.fetchAvis(widget.idService);
                    });
                  });
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isDarkMode ? Colors.blueGrey[900] : Colors.cyan,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                  padding: EdgeInsets.symmetric(vertical: 10),
                  elevation: 5,
                ),
                child: Text(
                  "Donner Avis",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ),
          Footer(
            currentIndex: 0,
            onTap: (index) {
              if (index != 0) {
                Navigator.pushReplacementNamed(context, '/home');
              }
            },
            isDarkMode: isDarkMode,
            toggleTheme: () => themeProvider.toggleTheme(),
          ),
        ],
      ),
    );
  }
}
