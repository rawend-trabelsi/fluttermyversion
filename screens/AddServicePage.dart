import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../services/ServiceService.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart';
 // Importer AdminScreen pour réutiliser le Drawer

class AddServicePage extends StatefulWidget {
  @override
  _AddServicePageState createState() => _AddServicePageState();
}

class _AddServicePageState extends State<AddServicePage> {
  final _titreController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _prixController = TextEditingController();
  final _dureeController = TextEditingController();
  XFile? _imageFile;

  // Méthode pour choisir une image
  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      _imageFile = image;
    });
  }

  // Méthode pour soumettre un service
  Future<void> _submitService() async {
    if (_titreController.text.isNotEmpty &&
        _prixController.text.isNotEmpty &&
        double.tryParse(_prixController.text) != null) {
      try {
        double prix = double.parse(_prixController.text);

        // Appeler la méthode de ServiceService pour créer le service
        await ServiceService().createService(
          _titreController.text,
          _descriptionController.text,
          prix,
          _dureeController.text,
          _imageFile,
        );

        // Afficher un AlertDialog pour informer de l'ajout réussi
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
                      'Le service a été ajouté avec succès !',
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16),
                    ),
                    SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context); // Ferme le dialog
                        Navigator.pop(
                            context, true); // Retourne à la page précédente
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF00BCD0),
                        padding: EdgeInsets.symmetric(
                            horizontal: 40, vertical: 12),
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
        // Gérer les erreurs en cas d'échec
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

        elevation: 0,

        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black), // Bouton hamburger
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        title: Text('Ajouter service'),
        automaticallyImplyLeading: false,
        actions: [],

      ),
      drawer: Sidebar(
        authService: AuthService(),
        onSelectPage: (index) {},
        isDarkMode: false, // ✅ Correction ici (ou true selon le besoin)
        toggleTheme: () {},
      ),

      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              SizedBox(height: 20),
              GestureDetector(
                onTap: _pickImage,
                child: CircleAvatar(
                  radius: 50,
                  backgroundColor: Colors.grey[200],
                  backgroundImage: _imageFile != null
                      ? FileImage(File(_imageFile!.path))
                      : null,
                  child: _imageFile == null
                      ? Icon(
                      Icons.add_photo_alternate, size: 40, color: Colors.grey)
                      : null,
                ),
              ),
              SizedBox(height: 30),
              CustomTextField(
                  controller: _titreController, hintText: "Titre du service"),
              CustomTextField(
                  controller: _descriptionController, hintText: "Description"),
              CustomTextField(
                controller: _prixController,
                hintText: "Prix",
                keyboardType: TextInputType.number, // Champ numérique
              ),
              CustomTextField(controller: _dureeController, hintText: "Durée"),
              SizedBox(height: 30),
              ElevatedButton(
                onPressed: _submitService,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00BCD0),
                  minimumSize: Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                ),
                child: Text("Ajouter",
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
