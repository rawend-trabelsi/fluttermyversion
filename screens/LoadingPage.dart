import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const LoadingPage(isDarkMode: false, toggleTheme: _toggleTheme),
    );
  }

  static void _toggleTheme() {
    // Implémentation de votre logique pour changer de thème
  }
}

class LoadingPage extends StatefulWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const LoadingPage({
    required this.isDarkMode,
    required this.toggleTheme,
    super.key,
  });

  @override
  _LoadingPageState createState() => _LoadingPageState();
}

class _LoadingPageState extends State<LoadingPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.isDarkMode ? Colors.black : const Color(0xFF00BCD0), // Fond bleu clair en mode normal
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            SizedBox(
              width: 200,
              height: 200,
              child: CircularProgressIndicator(
                strokeWidth: 20, // Épaisseur ajustée
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.isDarkMode ? Colors.white : Colors.white, // Blanc en mode clair
                ),
                backgroundColor: widget.isDarkMode
                    ? Colors.white.withOpacity(0.3)
                    : Colors.white.withOpacity(0.6), // Opacité plus proche du design de l'image
              ),
            ),
            Text(
              "Loading...",
              style: TextStyle(
                color: widget.isDarkMode ? Colors.white : Colors.white, // Texte en blanc en mode clair
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
      appBar: AppBar(
        backgroundColor: widget.isDarkMode ? Colors.black : Colors.white,
        elevation: 0,
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
    );
  }
}
