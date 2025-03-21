import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/AvisService.dart';
import '../models/Avis.dart';
import '../ThemeProvider.dart';
import 'Footer.dart';

class AjouterAvisScreen extends StatefulWidget {
  final int serviceId;
  final String serviceTitre;

  const AjouterAvisScreen({Key? key, required this.serviceId, required this.serviceTitre})
      : super(key: key);

  @override
  _AjouterAvisScreenState createState() => _AjouterAvisScreenState();
}

class _AjouterAvisScreenState extends State<AjouterAvisScreen> {
  int _selectedStars = 0;
  TextEditingController _commentaireController = TextEditingController();
  String? email;
  String? serviceTitre;

  @override
  void initState() {
    super.initState();
    AvisService().getEmailFromToken().then((userEmail) {
      setState(() {
        email = userEmail;
      });
    }).catchError((e) {
      setState(() {
        email = 'Email non disponible';
      });
    });

    AvisService().getTitreService(widget.serviceId).then((title) {
      setState(() {
        serviceTitre = title;
      });
    }).catchError((e) {
      setState(() {
        serviceTitre = 'Titre non disponible';
      });
    });
  }

  Future<void> _submitAvis() async {
    if (_commentaireController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Veuillez écrire un commentaire")));
      return;
    }

    Avis avis = Avis(
      etoile: _selectedStars,
      commentaire: _commentaireController.text,
      email: email ?? 'Email non disponible',
      serviceId: widget.serviceId,
      titreService: serviceTitre ?? 'Titre non disponible',
    );

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString("jwt_token");

    if (token != null) {
      try {
        bool success = await AvisService().ajouterAvis(avis, token);

        if (success) {
          _showSuccessDialog();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text("Erreur lors de l'ajout de l'avis")));
        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Une erreur est survenue : $e")));
      }
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Token non trouvé")));
    }
  }

  void _showSuccessDialog() {
    final isDarkMode = Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          backgroundColor: isDarkMode ? Colors.black : Colors.white,
          child: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF00BCD0),
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Merci',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BCD0),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  'Avis ajouté avec succès !',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16, color: isDarkMode ? Colors.white : Colors.black),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context, true);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00BCD0),
                    padding: EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(30),
                    ),
                  ),
                  child: Text(
                    'OK',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        );
      },
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
          'Donner Avis',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        backgroundColor: isDarkMode ? Colors.grey[900] : Color(0xFF00BCD0),
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildLabel("Email:"),
            _buildReadOnlyField(email ?? 'Chargement...', isDarkMode),
            SizedBox(height: 10),
            _buildLabel("Service:"),
            _buildReadOnlyField(serviceTitre ?? 'Chargement...', isDarkMode),
            SizedBox(height: 10),
            _buildLabel("Score:"),
            Row(
              children: List.generate(5, (index) {
                return IconButton(
                  icon: Icon(
                    index < _selectedStars ? Icons.star : Icons.star_border,
                    color: Colors.amber,
                  ),
                  onPressed: () {
                    setState(() {
                      _selectedStars = index + 1;
                    });
                  },
                );
              }),
            ),
            SizedBox(height: 10),
            _buildLabel("Commentaire:"),
            TextField(
              controller: _commentaireController,
              maxLines: 4,
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00BCD0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00BCD0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(color: Color(0xFF00BCD0), width: 2),
                ),
                fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
                filled: true,
              ),
              style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
            ),
            SizedBox(height: 20),
            Center(
              child: ElevatedButton(
                onPressed: _submitAvis,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00BCD0),
                  padding: EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8)),
                ),
                child: Text(
                  "Envoyer",
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.white),
                ),
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: Footer(
        currentIndex: 0,
        isDarkMode: isDarkMode,
        toggleTheme: () => themeProvider.toggleTheme(),
        onTap: (index) {
          if (index != 0) {
            Navigator.pushReplacementNamed(context, '/home');
          }
        },
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(fontWeight: FontWeight.bold, color: Color(0xFF00BCD0)),
    );
  }

  Widget _buildReadOnlyField(String text, bool isDarkMode) {
    return TextField(
      readOnly: true,
      controller: TextEditingController(text: text),
      decoration: InputDecoration(
        border: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00BCD0)),
        ),
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00BCD0)),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Color(0xFF00BCD0), width: 2),
        ),
        fillColor: isDarkMode ? Colors.grey[800] : Colors.white,
        filled: true,
      ),
      style: TextStyle(color: isDarkMode ? Colors.white : Colors.black),
    );
  }
} 