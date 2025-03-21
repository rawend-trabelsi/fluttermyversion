import 'package:flutter/material.dart';
import 'ProfileScreen.dart';
import 'user_screen.dart';

class Footer extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const Footer({
    Key? key,
    required this.currentIndex,
    required this.onTap,
    required this.isDarkMode,
    required this.toggleTheme,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      backgroundColor: isDarkMode ? Colors.grey[900] : Colors.white,
      selectedItemColor: Color(0xFF00BCD0), // Couleur active
      unselectedItemColor: isDarkMode
          ? Colors.grey[400]
          : Colors.grey, // Couleur inactive adaptée au thème
      currentIndex: currentIndex,
      onTap: (index) {
        onTap(index);
        // Ajouter la logique de navigation ici
        if (index == 0) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) => UserScreen(
                  username: '',
                  isDarkMode: isDarkMode,
                  toggleTheme: toggleTheme,
                )), // Navigation vers UserScreen
          );
        } else if (index == 2) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ProfileScreen()), // Navigation vers ProfileScreen
          );
        }
      },
      items: const [
        BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Accueil'),
        BottomNavigationBarItem(icon: Icon(Icons.help), label: 'Aide'),
        BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profil'),
      ],
    );
  }
}