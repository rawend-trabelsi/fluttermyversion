import 'dart:io';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import '../services/auth_service.dart';
import 'VerifyCodePage.dart';
import 'LoadingPage.dart';

class ForgotPasswordPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const ForgotPasswordPage({
    required this.isDarkMode,
    required this.toggleTheme,
    super.key,
  });

  @override
  _ForgotPasswordPageState createState() => _ForgotPasswordPageState();
}

class _ForgotPasswordPageState extends State<ForgotPasswordPage> {
  final TextEditingController _emailController = TextEditingController();
  final FocusNode _emailFocusNode = FocusNode();
  final AuthService authService = AuthService();
  String? _emailError;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      FocusScope.of(context).requestFocus(_emailFocusNode);
    });
  }

  @override
  void dispose() {
    _emailController.dispose();
    _emailFocusNode.dispose();
    super.dispose();
  }

  bool isValidEmail(String email) {
    final emailRegex = RegExp(r"^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}");
    return emailRegex.hasMatch(email);
  }

  Future<bool> isConnected() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } on SocketException {
      return false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: widget.isDarkMode ? Colors.white : Colors.black),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: Text(
          'Modifier mot de passe',
          style: TextStyle(
            color: widget.isDarkMode ? Colors.white : Colors.black,
            fontSize: 18,
            fontWeight: FontWeight.w500,
          ),
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
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 20),
            Text(
              'Veuillez entrer votre adresse e-mail pour recevoir un code de vérification',
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _emailController,
              focusNode: _emailFocusNode,
              keyboardType: TextInputType.emailAddress,
              textAlign: TextAlign.center,
              style: TextStyle(color: widget.isDarkMode ? Colors.white : Colors.black),
              onChanged: (value) {
                setState(() {
                  _emailError = isValidEmail(value) ? null : "L'email ne semble pas valide. Vérifiez le format.";
                });
              },
              decoration: InputDecoration(
                labelText: 'Email',
                labelStyle: TextStyle(
                  color: widget.isDarkMode ? Colors.white70 : Colors.grey,
                ),
                hintText: 'exemple@gmail.com',
                hintStyle: TextStyle(color: widget.isDarkMode ? Colors.white70 : Colors.black54),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.isDarkMode ? Colors.white70 : Colors.grey[300]!),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(color: widget.isDarkMode ? Colors.white : Colors.grey[400]!),
                ),
                errorText: _emailError,
              ),
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () async {
                  if (_emailController.text.isEmpty) {
                    setState(() {
                      _emailError = 'Veuillez entrer un email';
                    });
                    return;
                  }

                  if (!isValidEmail(_emailController.text)) {
                    setState(() {
                      _emailError = "L'email ne semble pas valide. Vérifiez le format.";
                    });
                    return;
                  }

                  bool connected = await isConnected();
                  if (!connected) {
                    Fluttertoast.showToast(
                      msg: "Connexion perdue. Vérifiez votre réseau.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                    return;
                  }

                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => LoadingPage( isDarkMode: widget
                        .isDarkMode, // Passer la vraie valeur
                      toggleTheme: widget.toggleTheme,)),
                  );

                  try {
                    bool success = await authService.requestPasswordReset(_emailController.text);
                    Navigator.pop(context);
                    if (success) {
                      Navigator.push(
                        context,

                            MaterialPageRoute(
                              builder: (context) => VerifyCodePage(
                                email: _emailController.text,
                                isDarkMode: widget.isDarkMode,
                                toggleTheme: widget.toggleTheme,
                              ),
                            ),
                          );

                          } else {
                      Fluttertoast.showToast(
                        msg: "Email n'existe pas. Veuillez vous inscrire.",
                        toastLength: Toast.LENGTH_SHORT,
                        gravity: ToastGravity.CENTER,
                        backgroundColor: Colors.red,
                        textColor: Colors.white,
                      );
                    }
                  } catch (e) {
                    Navigator.pop(context);
                    Fluttertoast.showToast(
                      msg: "Une erreur s'est produite. Veuillez réessayer.",
                      toastLength: Toast.LENGTH_SHORT,
                      gravity: ToastGravity.CENTER,
                      backgroundColor: Colors.red,
                      textColor: Colors.white,
                    );
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF00BCD0),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                child: const Text(
                  'Envoyer',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}