import 'package:flutter/material.dart';
import 'package:projectlavage/models/abonnement.dart';
import 'package:projectlavage/screens/ListerPromotionsScreen.dart';
import 'package:projectlavage/screens/ReservationScreen.dart';
import 'package:projectlavage/screens/signin_screen.dart'; // Assurez-vous que vous importez la page de connexion
import 'package:projectlavage/services/auth_service.dart';
import '../models/user.dart';
import '../services/AbonnementService.dart';
import '../services/AvisService.dart';
import '../services/PromotionService.dart';
import '../services/ServiceService.dart';
import 'AbonnementPage.dart';
import 'AddAbonnementPage.dart';
import 'AddEquipeScreen.dart';
import 'AddServicePage.dart';
import '../models/service.dart';
import 'EditProfilePageAdmin.dart';
import 'EditProfilePageTechnicien.dart';
import 'AffectationTechnicienliste.dart';
import 'ListeAvisPage.dart';

import 'ServicePage.dart';
import 'UpdateAbonnementPage.dart';
import 'UpdateServicePage.dart';
import 'EquipeListScreen.dart';
import 'editEquipeScreen.dart';
import 'ListeUsers.dart';
import 'emplois_page.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: AdminScreen(
        isDarkMode: false, // Valeur par défaut pour isDarkMode
        toggleTheme: () {}, // Fonction vide par défaut pour toggleTheme
      ),
    );
  }
}

class AdminScreen extends StatefulWidget {
  final bool isDarkMode; // Ajoutez cette propriété
  final VoidCallback toggleTheme; // Ajoutez cette propriété

  const AdminScreen({
    Key? key,
    required this.isDarkMode, // Ajoutez cette ligne
    required this.toggleTheme, // Ajoutez cette ligne
  }) : super(key: key);

  @override
  _AdminScreenState createState() => _AdminScreenState();
}

class _AdminScreenState extends State<AdminScreen> {
  int _selectedPageIndex = 0;

  // Variables de comptage
  int utilisateurCount = 0;
  int serviceCount = 0;
  int avisCount = 0;
  int abonnementCount = 0;
  int promotionCount = 0;
  int reservationCount = 0;

  // Instance du service AuthService
  final AuthService authService = AuthService();

  final List<Widget> _pages = [
    AdminScreen(isDarkMode: false, toggleTheme: () {}), // Page d'accueil
    Center(child: Text('Services')),
    Center(child: Text('Equipe')),
    Center(child: Text('Promotion')),
    Center(child: Text('Abonnements')),
    Center(child: Text('Réservations')),
    Center(child: Text('FAQ')),
  ];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  void _loadData() async {
    int tempUtilisateurCount = 0;
    int tempServiceCount = 0;
    int tempAvisCount = 0;
    int tempAbonnementCount = 0;
    int tempPromotionCount = 0;
    int tempReservationCount = 0;

    try {
      tempUtilisateurCount = await AuthService().getUtilisateurCount();
    } catch (e) {
      print("Erreur lors du chargement du nombre d'utilisateurs: $e");
    }

    try {
      tempServiceCount = (await ServiceService().getServices()).length;
    } catch (e) {
      print("Erreur lors du chargement des services: $e");
    }

    try {
      tempAvisCount = (await AvisService().getAllAvis()).length;
    } catch (e) {
      print("Erreur lors du chargement des avis: $e");
    }

    try {
      tempAbonnementCount = await AbonnementService().getAbonnementCount();
    } catch (e) {
      print("Erreur lors du chargement des abonnements: $e");
    }

    try {
      tempPromotionCount = await PromotionService().getPromotionCount();
    } catch (e) {
      print("Erreur lors du chargement des promotions: $e");
    }

    try {
      tempReservationCount =
          0; // Remplacez par votre logique de comptage des réservations
    } catch (e) {
      print("Erreur lors du chargement des réservations: $e");
    }

    // Mettre à jour l'état une seule fois après avoir récupéré toutes les données
    setState(() {
      utilisateurCount = tempUtilisateurCount;
      serviceCount = tempServiceCount;
      avisCount = tempAvisCount;
      abonnementCount = tempAbonnementCount;
      promotionCount = tempPromotionCount;
      reservationCount = tempReservationCount;
    });
  }

  void _onSelectPage(int index) {
    setState(() {
      _selectedPageIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Statistiques', style: TextStyle(fontSize: 22)),
        centerTitle: true,
        backgroundColor: Color(0xFF00BCD0).withOpacity(0.88),
        elevation: 0,
        automaticallyImplyLeading: false,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Sidebar(
        authService: authService,
        onSelectPage: _onSelectPage,
        isDarkMode: widget.isDarkMode, // Passez isDarkMode
        toggleTheme: widget.toggleTheme, // Passez toggleTheme
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16),
        child: GridView.count(
          crossAxisCount: 2,
          crossAxisSpacing: 16,
          mainAxisSpacing: 16,
          childAspectRatio: 0.85,
          children: [
            _buildStatCard('Utilisateurs', utilisateurCount.toString(),
                'assets/images/user.png', Colors.teal),
            _buildStatCard('Services', serviceCount.toString(),
                'assets/images/services.png', Colors.deepPurple),
            _buildStatCard('Évaluations', avisCount.toString(),
                'assets/images/avis-client.png', Colors.amber),
            _buildStatCard('Abonnements', abonnementCount.toString(),
                'assets/images/subscriptions.png', Colors.green),
            _buildStatCard('Promotions', promotionCount.toString(),
                'assets/images/promotion.png', Colors.red),
            _buildStatCard('Réservations', reservationCount.toString(),
                'assets/images/reservations.png', Colors.blue),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, String imagePath, Color color) {
    return GestureDetector(
      onTap: () {
        print('$title tapped');
      },
      child: Container(
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.2),
              spreadRadius: 4,
              blurRadius: 15,
              offset: Offset(0, 6),
            ),
          ],
          gradient: LinearGradient(
            colors: [color.withOpacity(0.2), color.withOpacity(0.5)],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AnimatedOpacity(
              opacity: 1.0,
              duration: Duration(milliseconds: 500),
              child: Image.asset(
                imagePath,
                height: 70,
                width: 70,
              ),
            ),
            SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                value,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: color,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Sidebar extends StatefulWidget {
  final AuthService authService;
  final Function(int) onSelectPage;
  final bool isDarkMode;
  final VoidCallback toggleTheme;

  const Sidebar({
    required this.authService,
    required this.onSelectPage,
    required this.isDarkMode,
    required this.toggleTheme,
    Key? key,
  }) : super(key: key);

  @override
  _SidebarState createState() => _SidebarState();
}

class _SidebarState extends State<Sidebar> {
  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        color: Colors.cyan[50],
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.cyan[300],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Admin',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    "Bienvenue sur le tableau de bord de l'administrateur",
                    style: TextStyle(
                      color: Colors.black54,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerItem(context, 'assets/images/home.png', 'Accueil', 0),
            _buildDrawerItem(
                context, 'assets/images/services.png', 'Services', 1),
            _buildDrawerItem(context, 'assets/images/team.png', 'Equipe', 2),
            _buildDrawerItem(context, 'assets/images/user.png', 'Clients', 3),
            _buildDrawerItem(
                context, 'assets/images/avis-client.png', 'Avis', 4),
            _buildDrawerItem(
                context, 'assets/images/promotion.png', 'Promotion', 5),
            _buildDrawerItem(
                context, 'assets/images/subscriptions.png', 'Abonnements', 6),
            _buildDrawerItem(
                context, 'assets/images/reservations.png', 'Réservations', 7),
            _buildDrawerItem(context, 'assets/images/job.png', 'Emplois', 8),
            _buildDrawerItem(context, 'assets/images/planification.jpg',
                'Planification des Techniciens', 11),
            _buildDrawerItem(
                context, 'assets/images/profile.png', 'Profile', 9),
            _buildDrawerItem(
                context, 'assets/images/logout.png', 'Se déconnecter', 10),
          ],
        ),
      ),
    );
  }

  Widget _buildDrawerItem(
      BuildContext context, String iconPath, String title, int index) {
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
        if (index == 10) {
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
        } else if (index == 1) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ServicePage()),
          );
        } else if (index == 6) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AbonnementPage()),
          );
        } else if (index == 2) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EquipeListScreen()),
          );
        } else if (index == 9) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => EditProfilePageAdmin(
                isDarkMode: false,
                toggleTheme: () {},
              ),
            ),
          );
        } else if (index == 3) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListeUsers()),
          );
        } else if (index == 4) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListeAvisPage()),
          );
        } else if (index == 5) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => ListerPromotionsScreen()),
          );
        } else if (index == 0) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AdminScreen(
                      isDarkMode: widget.isDarkMode,
                      toggleTheme: widget.toggleTheme,
                    )),
          );
        } else if (index == 8) {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => EmploisPage()),
          );
        } else if (index == 7) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    ReservationsScreen()), // Remplacez "NouvellePage" par votre page
          );
        } else if (index == 11) {
          Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    AffectationTechnicienliste()), // Remplacez "NouvellePage" par votre page
          );
        } else {
          Navigator.pop(context);
          widget.onSelectPage(index);
        }
      },
    );
  }
}
