import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';
import '../ThemeProvider.dart';
import 'footer.dart';

class AboutUsScreen extends StatelessWidget {
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  AboutUsScreen({required this.isDarkMode, required this.toggleTheme});

  // URLs et coordonnées
  final String instagramUrl =
      "https://www.instagram.com/aghsalni_?igsh=MTZycWF5OWU4NWxjOA%3D%3D";
  final String facebookUrl =
      "https://www.facebook.com/people/Aghsalni/61558848903153/?rdid=U6FVhOoDG0vj16Jp&share_url=https%3A%2F%2Fwww.facebook.com%2Fshare%2F1BBtcgheLW%2F";
  final String phoneNumber = "+216 20 361 369";
  final String whatsappNumber = "+216 20 361 369";
  final String email = "aghsalniinfo@gmail.com";

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch $url');
    }
  }

  Future<void> _makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  Future<void> _launchWhatsApp(String phoneNumber) async {
    final Uri uri = Uri.parse("https://wa.me/$phoneNumber");
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('Could not launch WhatsApp');
    }
  }

  Future<void> _launchEmail(String email) async {
    final Uri uri = Uri(
      scheme: 'mailto',
      path: email,
    );
    if (!await launchUrl(uri)) {
      throw Exception('Could not launch email');
    }
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = Provider.of<ThemeProvider>(context);
    final bool isDarkMode = themeProvider.isDarkMode;
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: isDarkMode ? Colors.black : Colors.white,
      appBar: AppBar(
        title: Text(
          "À propos de nous",
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyLarge!.color,
            fontWeight: FontWeight.bold,

          ),
        ),
        backgroundColor: Colors.cyan,
        elevation: 0,
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
      body: Container(
        color: isDarkMode ? Colors.black : Colors.white,
        padding: const EdgeInsets.all(20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "AGHSALNIII LAVAGE SANS EAU",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF00BCD0),
                ),
                textAlign: TextAlign.center,
              ),
              _buildSubtitle("ÉCONOMIQUE DE 8H À 22H", isDarkMode),
              const SizedBox(height: 30),
              _buildSectionTitle(
                  "N'hésitez pas à nous contacter !", isDarkMode),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildContactItem(Icons.call, "Appelez-nous", phoneNumber,
                      Colors.green, isDarkMode, screenWidth,
                      onTap: () =>
                          _makePhoneCall(phoneNumber.replaceAll(" ", ""))),
                  _buildContactItem(Icons.email, "Écrivez-nous", email,
                      Colors.yellow, isDarkMode, screenWidth,
                      onTap: () => _launchEmail(email)),
                ],
              ),
              const SizedBox(height: 30),
              _buildSectionTitle(
                  "Suivez-nous sur les réseaux sociaux", isDarkMode),
              const SizedBox(height: 15),
              _buildSocialMediaItem(FontAwesomeIcons.instagram, "Instagram",
                  "Suivez-nous sur Instagram", Colors.pink, isDarkMode,
                  onTap: () => _launchUrl(instagramUrl)),
              _buildSocialMediaItem(FontAwesomeIcons.facebook, "Facebook",
                  "Rejoignez notre communauté", Colors.blue, isDarkMode,
                  onTap: () => _launchUrl(facebookUrl)),
              _buildSocialMediaItem(FontAwesomeIcons.whatsapp, "WhatsApp",
                  "Contactez-nous: $phoneNumber", Colors.green, isDarkMode,
                  onTap: () => _launchWhatsApp(
                      phoneNumber.replaceAll(" ", "").replaceAll("+", ""))),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Footer(
        currentIndex: 2,
        isDarkMode: isDarkMode,
        toggleTheme: () => themeProvider.toggleTheme(),
        onTap: (index) {
          if (index != 2) {
            _navigateToScreen(context, index);
          }
        },
      ),
    );
  }

  Widget _buildTitle(String title) {
    return Center(
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 28,
          fontWeight: FontWeight.bold,
          color: Colors.blueAccent,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSubtitle(String subtitle, bool isDarkMode) {
    return Center(
      child: Text(
        subtitle,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDarkMode) {
    return Text(
      title,
      style: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.w600,
        color: isDarkMode ? Colors.white : Colors.grey[800],
      ),
    );
  }

  Widget _buildContactItem(IconData icon, String title, String subtitle,
      Color color, bool isDarkMode, double screenWidth,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: screenWidth * 0.43, // Ajuster la largeur en fonction de l'écran
        child: Card(
          color: isDarkMode ? Colors.grey[900] : Colors.white,
          elevation: 6,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(15),
          ),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Icon(icon, color: color, size: 45),
                const SizedBox(height: 8),
                Text(
                  title,
                  style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      color: isDarkMode ? Colors.white : Colors.black),
                ),
                const SizedBox(height: 5),
                Text(
                  subtitle,
                  style: TextStyle(
                      color: isDarkMode ? Colors.grey[400] : Colors.grey[600],
                      fontSize: 14),
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSocialMediaItem(IconData icon, String title, String subtitle,
      Color color, bool isDarkMode,
      {VoidCallback? onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Card(
        color: isDarkMode ? Colors.grey[900] : Colors.white,
        elevation: 8,
        margin: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        child: ListTile(
          leading: Icon(icon, color: color, size: 35),
          title: Text(
            title,
            style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 18,
                color: isDarkMode ? Colors.white : Colors.black),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(
                color: isDarkMode ? Colors.grey[400] : Colors.grey[600]),
          ),
        ),
      ),
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
