
import 'dart:async';
import 'package:flutter/material.dart';
import '../services/auth_service.dart';
import 'ForgotPasswordPage.dart';
import 'ResetPasswordPage.dart';

class VerifyCodePage extends StatefulWidget {
  final String email;
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  VerifyCodePage({required this.email, required this.isDarkMode, required this.toggleTheme});

  @override
  _VerifyCodePageState createState() => _VerifyCodePageState();
}

class _VerifyCodePageState extends State<VerifyCodePage> {
  final List<TextEditingController> codeControllers = List.generate(6, (_) => TextEditingController());
  final AuthService authService = AuthService();
  int attemptCount = 0;
  bool canResend = true;
  late Timer resendTimer;
  int countdown = 120;
  bool isCodeExpired = false;

  @override
  void initState() {
    super.initState();
    startResendTimer();
  }

  void startResendTimer() {
    setState(() {
      canResend = false;
      countdown = 120;
      isCodeExpired = false;
    });
    resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (countdown > 0) {
        setState(() => countdown--);
      } else {
        setState(() {
          canResend = true;
          isCodeExpired = true;
        });
        resendTimer.cancel();
      }
    });
  }

  void resendCode() async {
    if (attemptCount < 3 && canResend) {
      bool codeSent = await authService.resendVerificationCode(widget.email);
      if (codeSent) {
        setState(() {
          attemptCount++;
          isCodeExpired = false;
        });
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Un nouveau code a été envoyé à ${widget.email}.')));
        startResendTimer();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Erreur lors de l'envoi du code.")));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Vous avez atteint le nombre de tentatives. Veuillez répéter le processus.')));
      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => ForgotPasswordPage(isDarkMode: widget.isDarkMode, toggleTheme: widget.toggleTheme)));
    }
  }

  @override
  void dispose() {
    resendTimer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = widget.isDarkMode;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : Colors.white,
      appBar: AppBar(
        backgroundColor: isDark ? Colors.black : Colors.white,
        actions: [
          Positioned(
            top: 40,
            right: 0, // Mettre 0 pour la coller complètement à droite
            child: IconButton(
              icon: Icon(
                widget.isDarkMode ? Icons.dark_mode : Icons.light_mode,
                size: 30,
                color: widget.isDarkMode ? Colors.white : Colors.black,
              ),
              onPressed: widget.toggleTheme,
            ),
          )

        ],
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              'Entrez le code de confirmation',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black),
            ),
            const SizedBox(height: 8),
            Text(
              'Entrez le code à 6 chiffres',
              style: TextStyle(fontSize: 16, color: isDark ? Colors.grey[400] : Colors.grey),
            ),
            const SizedBox(height: 32),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: List.generate(6, (index) {
                return SizedBox(
                  width: 40,
                  child: TextField(
                    controller: codeControllers[index],
                    keyboardType: TextInputType.number,
                    textAlign: TextAlign.center,
                    maxLength: 1,
                    style: TextStyle(color: isDark ? Colors.white : Colors.black),
                    decoration: InputDecoration(
                      counterText: '',
                      filled: true,
                      fillColor: isDark ? Colors.grey[800] : Colors.grey[200],
                      enabledBorder: OutlineInputBorder(borderSide: BorderSide(color: isDark ? Colors.grey[600]! : Colors.grey)),
                      focusedBorder: OutlineInputBorder(borderSide: BorderSide(color: Colors.blue)),
                    ),
                  ),
                );
              }),
            ),
            const SizedBox(height: 32),
            ElevatedButton(
              onPressed: () async {
                if (isCodeExpired) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Le code est expiré. Veuillez en demander un nouveau.')));
                  return;
                }
                if (!codeControllers.every((c) => c.text.isNotEmpty)) {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Veuillez entrer le code complet.')));
                  return;
                }
                String fullCode = codeControllers.map((c) => c.text).join();
                bool success = await authService.verifyResetCode(widget.email, fullCode);
                if (success) {
                  Navigator.push(context, MaterialPageRoute(builder: (context) => ResetPasswordPage(email: widget.email, oldPassword: '', isDarkMode: widget.isDarkMode, toggleTheme: widget.toggleTheme)));
                } else {
                  ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Code invalide. Veuillez réessayer.')));
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00BCD0), // Nouvelle couleur
                minimumSize: const Size(double.infinity, 50),
              ),
              child: const Text('Vérifier le code', style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 13),
        ElevatedButton(
          onPressed: canResend ? resendCode : null,
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.grey[900], // Toujours gris foncé (#212121)
            minimumSize: const Size(double.infinity, 50),
          ),


        child: Text(
                canResend ? 'Renvoyer le code' : 'Réessayez dans $countdown sec',
                style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 16),

          ],
        ),
      ),
    );
  }
}
