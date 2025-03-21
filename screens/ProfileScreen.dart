import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:projectlavage/screens/signin_screen.dart';
import '../ThemeProvider.dart';
import '../services/auth_service.dart';

import 'AbonnementUserPage.dart';
import 'AboutUsScreen.dart';
import 'EditProfilePage.dart';
import 'Footer.dart';

class ProfileScreen extends StatelessWidget {
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    var themeProvider = Provider.of<ThemeProvider>(context);
    bool isDarkMode = themeProvider.isDarkMode;

    return Scaffold(
      appBar: AppBar(

        leading: IconButton(
          icon:
          Icon(Icons.arrow_back, color: Theme.of(context).iconTheme.color),
          onPressed: () {
            Navigator.pushNamed(context, '/home');  // Naviguer vers la page UserScreen
          },

        ),

        title: Text(
          "Mon profil",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.cyan,
        elevation: 0,
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
          children: [
            _buildProfileOption(
                Icons.person_outline, "Modifier Profil", context, isDarkMode),
            _buildProfileOption(
                Icons.notifications_none, "Notifications", context, isDarkMode),
            Divider(color: Theme.of(context).dividerColor),
            _buildProfileOption(
                Icons.shopping_cart_outlined, "Commandes", context, isDarkMode),
            _buildProfileOption(Icons.location_on_outlined,
                "Localisation du technicien", context, isDarkMode),
            Divider(color: Theme.of(context).dividerColor),
            _buildProfileOption(
                Icons.info_outline, "À propos de nous", context, isDarkMode),
            _buildProfileOption(Icons.subscriptions_outlined, "Abonnements",
                context, isDarkMode),
            Divider(color: Theme.of(context).dividerColor),
            _buildProfileOption(
                Icons.logout, "Déconnecter", context, isDarkMode,
                isLogout: true),
          ],
        ),
      ),
      bottomNavigationBar: Footer(
        currentIndex: 2,
        isDarkMode: isDarkMode,
        toggleTheme: themeProvider.toggleTheme,
        onTap: (index) {
          if (index != 2) {
            _navigateToScreen(context, index);
          }
        },
      ),
    );
  }

  Widget _buildProfileOption(
      IconData icon, String title, BuildContext context, bool isDarkMode,
      {bool isLogout = false}) {
    Color textColor = isDarkMode ? Colors.white : Colors.black87;

    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
      ),
      margin: EdgeInsets.symmetric(vertical: 8),
      color: Theme.of(context).cardColor,
      child: ListTile(
        leading: Icon(icon, color: Color(0xFF00BCD0), size: 30),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: textColor, // Texte qui s'adapte au mode sombre
          ),
        ),
        trailing: Icon(Icons.arrow_forward_ios, size: 18, color: textColor),
        onTap: () {
          if (isLogout) {
            _handleLogout(context);
          } else {
            _navigateToPage(title, context, isDarkMode,
                Provider.of<ThemeProvider>(context, listen: false).toggleTheme);
          }
        },
      ),
    );
  }

  void _navigateToPage(String title, BuildContext context, bool isDarkMode,
      VoidCallback toggleTheme) {
    switch (title) {
      case "Modifier Profil":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => EditProfilePage(
              isDarkMode: true, // ou false selon l'état
              toggleTheme: (){  },)));
        break;
      case "À propos de nous":
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AboutUsScreen(
                    isDarkMode: isDarkMode, toggleTheme: toggleTheme)));
        break;
      case "Abonnements":
        Navigator.push(context,
            MaterialPageRoute(builder: (context) => AbonnementUserPage()));
        break;
    }
  }

  void _handleLogout(BuildContext context) async {
    await authService.signOut();

    bool isDarkMode =
        Provider.of<ThemeProvider>(context, listen: false).isDarkMode;
    VoidCallback toggleTheme =
        Provider.of<ThemeProvider>(context, listen: false).toggleTheme;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) =>
              SignInScreen(isDarkMode: isDarkMode, toggleTheme: toggleTheme)),
    );
  }

  void _navigateToScreen(BuildContext context, int index) {
    switch (index) {
      case 0:
        Navigator.pushReplacementNamed(context, '/home');
        break;
      case 1:
        Navigator.pushReplacementNamed(context, '/help');
        break;
      case 2:
        Navigator.pushReplacementNamed(context, '/profile');
        break;
    }
  }
}