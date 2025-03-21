import 'package:flutter/material.dart';
import 'package:projectlavage/screens/signin_screen.dart';

import '../services/auth_service.dart';
import 'Footer.dart';
import 'ProfileScreen.dart';
import 'TechnicienDashboard.dart';

import '../services/auth_service.dart';

class EditProfilePageTechnicien extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const EditProfilePageTechnicien({
    Key? key,
    required this.isDarkMode,
    required this.toggleTheme,
  }) : super(key: key);


  @override
  _EditProfilePageTechnicienState createState() => _EditProfilePageTechnicienState();
}

class _EditProfilePageTechnicienState extends State<EditProfilePageTechnicien> {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController currentPasswordController = TextEditingController();
  final TextEditingController newPasswordController = TextEditingController();

  bool _isCurrentPasswordVisible = false;
  bool _isNewPasswordVisible = false;



  final _formKey = GlobalKey<FormState>();

  String? initialEmail;
  String? initialPhone;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final profile = await AuthService().getUserProfile();
    if (profile != null) {
      setState(() {
        usernameController.text = profile['username'] ?? '';
        emailController.text = profile['email'] ?? '';
        phoneController.text = profile['phone'] ?? '';
        initialEmail = profile['email'];
        initialPhone = profile['phone'];
      });
    }
  }

  Future<void> _updateProfile() async {
    if (!_formKey.currentState!.validate()) return;

    // Vérifications supplémentaires pour email et téléphone via AuthService
    final emailExists = await AuthService().checkEmail(emailController.text);
    if (emailExists && emailController.text != initialEmail) {
      _showErrorDialog("Cet email existe déjà.");
      return;
    }

    final phoneExists = await AuthService().checkPhone(phoneController.text);
    if (phoneExists && phoneController.text != initialPhone) {
      _showErrorDialog("Ce numéro de téléphone existe déjà.");
      return;
    }
    final success = await AuthService().updateProfile(
      usernameController.text,
      emailController.text,
      phoneController.text,
      currentPasswordController.text.isEmpty ? "" : currentPasswordController.text,
      newPasswordController.text.isEmpty ? "" : newPasswordController.text,
    );



    if (success) {
      if (_shouldRedirectToSignIn()) {
        _showSuccessDialog(isSignInRedirect: true);
      } else {
        _showSuccessDialog(isSignInRedirect: false);
      }
    } else {
      _showErrorDialog("Erreur lors de la mise à jour du profil");
    }
  }

  bool _shouldRedirectToSignIn() {
    return emailController.text != initialEmail ||
        (newPasswordController.text.isNotEmpty && newPasswordController.text != currentPasswordController.text);
  }

  void _showSuccessDialog({required bool isSignInRedirect}) {
    showDialog(
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
                  Icons.check_circle_outline,
                  color: Color(0xFF00BCD0), // Success icon with the desired color
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Mise à jour réussie',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BCD0),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  isSignInRedirect
                      ? 'Votre profil a été mis à jour. Veuillez vous reconnecter.'
                      : 'Votre profil a été mis à jour avec succès.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    if (isSignInRedirect) {
                      var isDarkMode;
                      var toggleTheme;
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => SignInScreen(      isDarkMode: widget.isDarkMode,
                          toggleTheme: widget.toggleTheme,)),
                      );
                    } else {
                      Navigator.of(context).pushReplacement(
                        MaterialPageRoute(builder: (context) => TechnicienDashboard(   isDarkMode: widget.isDarkMode,
                          toggleTheme: widget.toggleTheme,)),
                      );

                    }
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


  void _showErrorDialog(String message) {
    showDialog(
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
                  Icons.error_outline,
                  color: Colors.red, // Error icon with red color
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Erreur',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Colors.red, // Red color for error message
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  message, // Dynamically display error message
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red, // Red background for error
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
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xFF00BCD0).withOpacity(0.88),
        title: const Text(
          'Modifier Profil',
          style: TextStyle(
            fontWeight: FontWeight.bold, // Le texte sera en gras
            fontSize: 22, // Taille du texte
            color: Colors.black, // Couleur du texte
          ),
        ),


      ),
        drawer: TechnicienSidebar(
          authService: AuthService(),
          onSelectPage: (index) {},
          isDarkMode: false,
          toggleTheme: () {},
        ),

      body: Form(
        key: _formKey,
        child: Container(
          color: Colors.white,
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(
                  height: 120,
                  child: Image.asset('assets/images/edit_profile.png', fit: BoxFit.contain),
                ),
                const SizedBox(height: 20),
                TextFormField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Nom du Techncien',
                    enabledBorder: UnderlineInputBorder( // Supprime le cadre et garde uniquement une ligne en dessous
                      borderSide: BorderSide(color: Color(0xFF00BCD0)), // Ligne avec la couleur désirée
                    ),
                    focusedBorder: UnderlineInputBorder( // Garde la même couleur quand le champ est sélectionné
                      borderSide: BorderSide(color: Color(0xFF00BCD0), width: 2), // Ligne plus épaisse quand sélectionné
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le nom d\'utilisateur est obligatoire';
                    } else if (value.length < 3 || value.length > 50) {
                      return 'Le nom d\'utilisateur doit contenir entre 3 et 50 caractères';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    enabledBorder: UnderlineInputBorder( // Supprime le cadre et garde uniquement une ligne en dessous
                      borderSide: BorderSide(color: Color(0xFF00BCD0)), // Ligne avec la couleur désirée
                    ),
                    focusedBorder: UnderlineInputBorder( // Garde la même couleur quand le champ est sélectionné
                      borderSide: BorderSide(color: Color(0xFF00BCD0), width: 2), // Ligne plus épaisse quand sélectionné
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'L\'email est obligatoire';
                    } else if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                      return 'L\'email est invalide';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: phoneController,
                  decoration: InputDecoration(
                    labelText: 'Téléphone',
                    enabledBorder: UnderlineInputBorder( // Supprime le cadre et garde uniquement une ligne en dessous
                      borderSide: BorderSide(color: Color(0xFF00BCD0)), // Ligne avec la couleur désirée
                    ),
                    focusedBorder: UnderlineInputBorder( // Garde la même couleur quand le champ est sélectionné
                      borderSide: BorderSide(color: Color(0xFF00BCD0), width: 2), // Ligne plus épaisse quand sélectionné
                    ),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Le numéro de téléphone est obligatoire';
                    } else if (!RegExp(r'^\d{8}$').hasMatch(value)) {
                      return 'Le numéro de téléphone doit contenir exactement 8 chiffres';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: currentPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Mot de passe actuel',
                    enabledBorder: UnderlineInputBorder( // Supprime le cadre et garde uniquement une ligne en dessous
                      borderSide: BorderSide(color: Color(0xFF00BCD0)), // Ligne avec la couleur désirée
                    ),
                    focusedBorder: UnderlineInputBorder( // Garde la même couleur quand le champ est sélectionné
                      borderSide: BorderSide(color: Color(0xFF00BCD0), width: 2), // Ligne plus épaisse quand sélectionné
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isCurrentPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Color(0xFF00BCD0),

                      ),
                      onPressed: () {
                        setState(() {
                          _isCurrentPasswordVisible = !_isCurrentPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isCurrentPasswordVisible,
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 8) {
                      return 'Le mot de passe doit contenir au moins 8 caractères';
                    }
                    return null; // Retourne null si valide ou vide
                  },
                ),

                const SizedBox(height: 16),
                TextFormField(
                  controller: newPasswordController,
                  decoration: InputDecoration(
                    labelText: 'Nouveau mot de passe',
                    enabledBorder: UnderlineInputBorder( // Supprime le cadre et garde uniquement une ligne en dessous
                      borderSide: BorderSide(color: Color(0xFF00BCD0)), // Ligne avec la couleur désirée
                    ),
                    focusedBorder: UnderlineInputBorder( // Garde la même couleur quand le champ est sélectionné
                      borderSide: BorderSide(color: Color(0xFF00BCD0), width: 2), // Ligne plus épaisse quand sélectionné
                    ),
                    suffixIcon: IconButton(
                      icon: Icon(
                        _isNewPasswordVisible ? Icons.visibility : Icons.visibility_off,
                        color: Color(0xFF00BCD0),

                      ),
                      onPressed: () {
                        setState(() {
                          _isNewPasswordVisible = !_isNewPasswordVisible;
                        });
                      },
                    ),
                  ),
                  obscureText: !_isNewPasswordVisible,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (value == currentPasswordController.text) {
                        return 'Le nouveau mot de passe ne peut pas être identique au mot de passe actuel';
                      } else if (value.length < 8) {
                        return 'Le nouveau mot de passe doit contenir au moins 8 caractères';
                      }
                    }
                    return null; // Retourne null si valide ou vide
                  },
                ),


                const SizedBox(height: 40),
                ElevatedButton(
                  onPressed: _updateProfile,
                  child: const Text(
                    'MODIFIER',
                    style: TextStyle(color: Colors.white), // Couleur du texte en blanc
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Color(0xFF00BCD0), // Couleur de fond
                    minimumSize: Size(double.infinity, 50), // Largeur étendue (infinity) et hauteur de 50
                  ),
                )

                ,
              ],
            ),
          ),
        ),
      ),

    );
  }
}