import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../models/abonnement.dart';
import '../services/AbonnementService.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart';

class UpdateAbonnementPage extends StatefulWidget {
  final Abonnement abonnement;

  UpdateAbonnementPage({required this.abonnement});

  @override
  _UpdateAbonnementPageState createState() => _UpdateAbonnementPageState();
}

class _UpdateAbonnementPageState extends State<UpdateAbonnementPage> {
  final _titreController = TextEditingController();
  final _prixController = TextEditingController();
  XFile? _imageFile; // La nouvelle image choisie (si elle existe)

  @override
  void initState() {
    super.initState();
    // Initialiser les champs de texte avec les informations de l'abonnement existant
    _titreController.text = widget.abonnement.titre;
    _prixController.text = widget.abonnement.prix.toString();
  }

  // Méthode pour choisir une nouvelle image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        _imageFile = image; // Mise à jour de l'image choisie
      });
    }
  }

  Future<void> _submitAbonnement() async {
    if (_titreController.text.isNotEmpty &&
        _prixController.text.isNotEmpty &&
        double.tryParse(_prixController.text) != null) {
      try {
        double prix = double.parse(_prixController.text);

        // Vérifiez si une nouvelle image a été choisie
        XFile? imageFile = _imageFile;

        // Si aucune nouvelle image n'est choisie, laissez imageFile = null
        if (_imageFile == null) {
          imageFile = null; // Pas de nouvelle image, conserver l'existante
        }

        // Appel de la méthode updateAbonnement avec l'image existante si nécessaire
        AbonnementService abonnementService = AbonnementService();
        Abonnement updatedAbonnement = await abonnementService.updateAbonnement(
          id: widget.abonnement.id,
          titre: _titreController.text,
          prix: prix,
          imageFile: imageFile, // Si imageFile est null, l'image existante est envoyée
        );

        // Afficher un message de succès si la mise à jour de l'abonnement est réussie
        showDialog(
          context: context,
          builder: (context) {
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
                      Icons.check_circle_outline,
                      color: Color(0xFF00BCD0),
                      size: 80,
                    ),
                    SizedBox(height: 20),
                    Text(
                      'Succès',
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00BCD0),
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      'L\'abonnement a été mis à jour avec succès!',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Ferme le dialog
                        Navigator.pop(context, true); // Retourne à la page précédente
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
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Erreur: ${e.toString()}'),
        ));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Veuillez remplir tous les champs correctement.'),
      ));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,

        backgroundColor: Color(0xFF00BCD0).withOpacity(0.88),
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black), // Bouton hamburger
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Modifier un abonnement'),
        automaticallyImplyLeading: false,
      ),
      drawer: Sidebar(
        authService: AuthService(),
        onSelectPage: (index) {},
        isDarkMode: false,
        toggleTheme: () {},
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imageFile != null
                      ? FileImage(File(_imageFile!.path))
                      : (widget.abonnement.imageUrl != null && widget.abonnement.imageUrl!.isNotEmpty)
                      ? (widget.abonnement.imageUrl!.startsWith('http')
                      ? NetworkImage(widget.abonnement.imageUrl!)
                      : MemoryImage(base64Decode(widget.abonnement.imageUrl!)) as ImageProvider)
                      : null,
                  child: _imageFile == null && (widget.abonnement.imageUrl == null || widget.abonnement.imageUrl!.isEmpty)
                      ? Icon(
                    Icons.add_photo_alternate,
                    size: 40,
                    color: Colors.grey,
                  )
                      : null,
                ),
              ),
              SizedBox(height: 30),
              CustomTextField(
                controller: _titreController,
                hintText: "Titre de l'abonnement",
              ),
              CustomTextField(
                controller: _prixController,
                hintText: "Prix de l'abonnement",
                keyboardType: TextInputType.number,
              ),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitAbonnement,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00BCD0),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text("Modifier",
                    style: TextStyle(fontSize: 18, color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CustomTextField extends StatelessWidget {
  final TextEditingController controller;
  final String hintText;
  final TextInputType? keyboardType;

  CustomTextField({
    required this.controller,
    required this.hintText,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: TextField(
        controller: controller,
        keyboardType: keyboardType,
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.symmetric(vertical: 10, horizontal: 10),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00BCD0)), // Couleur de la ligne quand désactivé
          ),
          focusedBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00BCD0), width: 2), // Couleur de la ligne quand en focus
          ),
          border: UnderlineInputBorder(
            borderSide: BorderSide(color: Color(0xFF00BCD0)), // Bordure par défaut
          ),
        ),
      ),
    );
  }
}
