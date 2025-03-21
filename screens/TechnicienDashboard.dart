import 'package:flutter/material.dart';
import 'package:projectlavage/screens/signin_screen.dart';
import 'package:projectlavage/services/auth_service.dart';
import '../services/NotificationsService.dart';
import 'EditProfilePageTechnicien.dart';
import 'EquipeListScreen.dart';
import 'NotificationTechicien.dart'; // Importez NotificationScreen
 // Importez NotificationService

void main() {
  bool isDarkMode = false; // Valeur par défaut pour isDarkMode

  void toggleTheme() {
    isDarkMode = !isDarkMode;
    print("Thème basculé !");
  }

  runApp(
    MyApp(
      isDarkMode: isDarkMode, // Passez isDarkMode
      toggleTheme: toggleTheme, // Passez toggleTheme
    ),
  );
}

class MyApp extends StatefulWidget {
  final bool isDarkMode; // Déclarez isDarkMode
  final VoidCallback toggleTheme; // Déclarez toggleTheme

  const MyApp({
    Key? key,
    required this.isDarkMode, // Ajoutez cette ligne
    required this.toggleTheme, // Ajoutez cette ligne
  }) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: widget.isDarkMode
          ? ThemeData.dark() // Appliquer le thème sombre
          : ThemeData.light(), // Appliquer le thème clair
      home: TechnicienDashboard(
        isDarkMode: widget.isDarkMode, // Utilisez widget.isDarkMode
        toggleTheme: widget.toggleTheme, // Utilisez widget.toggleTheme
      ),
      routes: {
        '/EditProfilePageTechnicien': (context) => EditProfilePageTechnicien(
          isDarkMode: widget.isDarkMode, // Utilisez widget.isDarkMode
          toggleTheme: widget.toggleTheme, // Utilisez widget.toggleTheme
        ),
      },
    );
  }
}

class TechnicienDashboard extends StatefulWidget {
  final bool isDarkMode; // Ajoutez cette propriété
  final VoidCallback toggleTheme; // Ajoutez cette propriété

  const TechnicienDashboard({
    Key? key,
    required this.isDarkMode, // Ajoutez cette ligne
    required this.toggleTheme, // Ajoutez cette ligne
  }) : super(key: key);

  @override
  _TechnicienDashboardState createState() => _TechnicienDashboardState();
}

class _TechnicienDashboardState extends State<TechnicienDashboard> {
  int _selectedPageIndex = 0;
  final AuthService authService = AuthService();
  final NotificationService notificationService = NotificationService('http://10.0.2.2:8085');

  final List<Widget> _pages = [
    Center(child: Text('Accueil')), // Index 0
    Center(child: Text('Réservations')), // Index 1
    NotificationScreen(email: '',), // Index 2 : Page des notifications
    EditProfilePageTechnicien( // Index 3 : Page de profil
      isDarkMode: false,
      toggleTheme: () {},
    ),
    EquipeListScreen(), // Index 4 : Liste des équipes
  ];

  void _onSelectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
        actions: [
          StreamBuilder<int>(
            stream: notificationService.getUnreadNotificationsCountStream(),
            builder: (context, snapshot) {
              if (snapshot.hasData) {
                return Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: CircleAvatar(
                    radius: 12,
                    backgroundColor: Colors.red,
                    child: Text(
                      snapshot.data.toString(),
                      style: TextStyle(color: Colors.white, fontSize: 12),
                    ),
                  ),
                );
              } else {
                return SizedBox();
              }
            },
          ),
        ],
      ),
      drawer: TechnicienSidebar(
        authService: authService,
        onSelectPage: _onSelectPage,
        isDarkMode: widget.isDarkMode,
        toggleTheme: widget.toggleTheme,
      ),
      body: _pages[_selectedPageIndex],
    );
  }
}

class TechnicienSidebar extends StatefulWidget {
  final AuthService authService;
  final Function(int) onSelectPage;
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  TechnicienSidebar({
    required this.authService,
    required this.onSelectPage,
    required this.isDarkMode,
    required this.toggleTheme,
  });

  @override
  _TechnicienSidebarState createState() => _TechnicienSidebarState();
}

class _TechnicienSidebarState extends State<TechnicienSidebar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: widget.isDarkMode ? Colors.black : Colors.cyan[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: widget.isDarkMode ? Colors.black : Colors.cyan[300],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Technicien',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white : Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Welcome to Technicien Dashboard',
                    style: TextStyle(
                      color: widget.isDarkMode ? Colors.white70 : Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, 'assets/images/home.png', 'Accueil', 0),
            _buildDrawerItem(context, 'assets/images/reservations.png', 'Réservations', 1),
            _buildDrawerItem(context, 'assets/images/notifications.png', 'Notifications', 2),
            _buildDrawerItem(context, 'assets/images/profile.png', 'Profile', 3),
            _buildDrawerItem(context, 'assets/images/logout.png', 'Se déconnecter', 4),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(BuildContext context, String iconPath, String title, int index) {
    return ListTile(
      leading: Image.asset(
        iconPath,
        width: 30,
        height: 30,
      ),
      title: Text(
        title,
        style: TextStyle(fontSize: 16),
      ),
      onTap: () async {
        if (index == 4) {
          // Déconnexion
          await widget.authService.signOut();
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => SignInScreen(
                isDarkMode: widget.isDarkMode,
                toggleTheme: widget.toggleTheme,
              ),
            ),
          );
        } else if (index == 3) {
          // Navigation vers EditProfilePageTechnicien
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePageTechnicien(
                isDarkMode: widget.isDarkMode,
                toggleTheme: widget.toggleTheme,
              ),
            ),
          );
        } else if (index == 2) {
          // Navigation vers NotificationScreen
          Navigator.pop(context); // Fermer le drawer
          widget.onSelectPage(index); // Naviguer vers la page des notifications
        } else {
          // Navigation vers les autres pages (Accueil, Réservations, etc.)
          Navigator.pop(context); // Fermer le drawer
          widget.onSelectPage(index); // Naviguer vers la page sélectionnée
        }
      },
    );
  }
}