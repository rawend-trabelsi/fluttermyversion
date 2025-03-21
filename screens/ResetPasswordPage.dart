import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:projectlavage/screens/signin_screen.dart';
import 'package:projectlavage/services/auth_service.dart';
import 'package:google_fonts/google_fonts.dart';

class ResetPasswordPage extends StatefulWidget {
  final String email;
  final String oldPassword;
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const ResetPasswordPage({
    Key? key,
    required this.email,
    required this.oldPassword,
    required this.isDarkMode,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  _ResetPasswordPageState createState() => _ResetPasswordPageState();
}

class _ResetPasswordPageState extends State<ResetPasswordPage> {
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();
  final AuthService _authService = AuthService();
  final _formKey = GlobalKey<FormState>();

  bool _isPasswordVisible = false;
  bool _isConfirmPasswordVisible = false;

  void _showConfirmrrsetDialog() {
    bool isDark = widget.isDarkMode;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: isDark ? Colors.black : Colors.white, // Fond en noir ou blanc selon le mode
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    Container(
                      width: 150,
                      height: 150,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00BCD0),
                        shape: BoxShape.circle,
                      ),
                    ),
                    const Icon(Icons.check_rounded, color: Colors.white, size: 80),
                    const Positioned(
                      top: 30,
                      right: 50,
                      child: CircleAvatar(backgroundColor: Color(0xFF8ED3ED), radius: 6),
                    ),
                    const Positioned(
                      bottom: 30,
                      left: 50,
                      child: CircleAvatar(backgroundColor: Color(0xFF8ED3ED), radius: 6),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                Text(
                  'Félicitations !',
                  style: GoogleFonts.rochester(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : Colors.black, // Texte en blanc ou noir selon le mode
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Mot de passe modifié avec succès',
                  style: TextStyle(
                    fontSize: 16,
                    color: isDark ? Colors.white70 : Colors.grey[600], // Texte en gris clair ou foncé selon le mode
                  ),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => SignInScreen(
                          isDarkMode: widget.isDarkMode,
                          toggleTheme: widget.toggleTheme,
                        ),
                      ),
                          (Route<dynamic> route) => false,
                    );
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF00BCD0),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Retour à la connexion', style: TextStyle(color: Colors.white)),
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
    bool isDark = widget.isDarkMode;

    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          'Modifier Mot de passe',
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: widget.isDarkMode ? Colors.white : Colors.black, // Blanc en dark mode, noir sinon
          ),
        ),


        backgroundColor: isDark ? Colors.black : Colors.white,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: widget.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),

        actions: [
          Padding(
            padding: EdgeInsets.only(right: 10), // Ajuste pour le mettre bien à droite
            child: IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                size: 30, // Taille de l'icône
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: widget.toggleTheme,
            ),
          ),
        ],

      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 32),
          TextFormField(
            controller: _passwordController,
            obscureText: !_isPasswordVisible,
            decoration: InputDecoration(
              hintText: 'Nouveau Mot de passe',
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Color(0xFF00BCD0)), // Bordure par défaut
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Color(0xFF00BCD0)), // Bordure quand non sélectionné
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(8.0),
                borderSide: BorderSide(color: Color(0xFF00BCD0), width: 2.0), // Bordure plus épaisse en focus
              ),
              filled: true,
              fillColor: isDark ? Colors.grey[900] : Colors.white, // Fond selon mode
              hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
              suffixIcon: IconButton(
                icon: Icon(
                  _isPasswordVisible ? Icons.visibility : Icons.visibility_off,
                  color: Color(0xFF00BCD0),
                ),
                onPressed: () => setState(() => _isPasswordVisible = !_isPasswordVisible),
              ),
            ),


          style: TextStyle(color: isDark ? Colors.white : Colors.black),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Veuillez entrer un mot de passe';
                  } else if (value.length < 8) {
                    return 'Le mot de passe doit contenir au moins 8 caractères';
                  } else if (value == widget.oldPassword) {
                    return "Le nouveau mot de passe ne peut pas être identique à l'ancien";
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPasswordController,
                obscureText: !_isConfirmPasswordVisible,
                decoration: InputDecoration(
                  hintText: 'Confirmer nouveau Mot de passe',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFF00BCD0)), // Bordure par défaut
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFF00BCD0)), // Bordure quand non sélectionné
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8.0),
                    borderSide: BorderSide(color: Color(0xFF00BCD0), width: 2.0), // Bordure plus épaisse en focus
                  ),
                  filled: true,
                  fillColor: isDark ? Colors.grey[900] : Colors.white,
                  hintStyle: TextStyle(color: isDark ? Colors.white70 : Colors.black54),
                  suffixIcon: IconButton(
                    icon: Icon(_isConfirmPasswordVisible ? Icons.visibility : Icons.visibility_off, color: Color(0xFF00BCD0)),
                    onPressed: () => setState(() => _isConfirmPasswordVisible = !_isConfirmPasswordVisible),
                  ),
                ),
                style: TextStyle(color: isDark ? Colors.white : Colors.black),
                validator: (value) {
                  if (value != _passwordController.text) {
                    return 'Les mots de passe ne correspondent pas';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () async {
                  if (_formKey.currentState!.validate()) {
                    bool success = await _authService.resetPassword(widget.email, _passwordController.text);

                    if (success) {
                      _showConfirmrrsetDialog();
                    } else {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(
                            'Mot de passe identique à l\'ancien',
                            style: TextStyle(color: Colors.white), // Texte en blanc pour la lisibilité
                          ),
                          backgroundColor: Color(0xFF00BCD0), // Couleur du fond du SnackBar
                          behavior: SnackBarBehavior.floating, // Optionnel : effet flottant
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8.0), // Coins arrondis
                          ),
                        ),
                      );
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD0),
                  minimumSize: const Size(double.infinity, 50),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(0)),
                ),
                child: const Text('SUBMIT', style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
