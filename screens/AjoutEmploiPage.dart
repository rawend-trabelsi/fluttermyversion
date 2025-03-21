import 'package:flutter/material.dart';
import '../models/TechnicienEmploi.dart';
import '../services/auth_service.dart';
import '../services/emploi_service.dart';
import 'admin_screen.dart';

class AjoutEmploiPage extends StatefulWidget {
  @override
  _AjoutEmploiPageState createState() => _AjoutEmploiPageState();
}

class _AjoutEmploiPageState extends State<AjoutEmploiPage> {
  final EmploiService _emploiService = EmploiService();
  List<String> _emails = [];
  String? _selectedEmail;
  String? _selectedJourRepos;
  TimeOfDay? _heureDebut;
  TimeOfDay? _heureFin;
  bool _isLoading = true;

  final List<String> _joursRepos = [
    "LUNDI",
    "MARDI",
    "MERCREDI",
    "JEUDI",
    "VENDREDI",
    "SAMEDI",
    "DIMANCHE"
  ];

  @override
  void initState() {
    super.initState();
    _fetchEmails();
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

  Future<void> _fetchEmails() async {
    try {
      String? token = await AuthService.getToken();
      if (token != null) {
        List<String> emails = await _emploiService.getEmailsTechniciens();
        setState(() {
          _emails = emails;
          _isLoading = false;
        });
      } else {
        throw Exception("Token introuvable");
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text(
                'Erreur lors de la récupération des emails: ${e.toString()}')),
      );
    }
  }

  Future<void> _ajouterEmploi() async {
    if (_selectedEmail == null ||
        _selectedJourRepos == null ||
        _heureDebut == null ||
        _heureFin == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Tous les champs sont obligatoires")),
      );
      return;
    }

    try {
      bool emailExiste =
          await _emploiService.emailTechnicienExiste(_selectedEmail!);
      if (emailExiste) {
        _showErrorDialog("Ce technicien possède déjà un emploi");

        return;
      }

      TechnicienEmploi emploiRequest = TechnicienEmploi(
        id: 0,
        email: _selectedEmail!,
        username: '',
        phone: '',
        jourRepos: _selectedJourRepos!,
        heureDebut: _formatTime(_heureDebut!),
        heureFin: _formatTime(_heureFin!),
      );

      bool success =
          await _emploiService.ajouterEmploiTechnicien(emploiRequest);
      if (success) {
        _showSuccessDialog();
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Erreur lors de l'ajout de l'emploi")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur: ${e.toString()}")),
      );
    }
  }

  // Convertir TimeOfDay en format "HH:mm:ss"
  String _formatTime(TimeOfDay time) {
    int hour = time
        .hourOfPeriod; // Utilisation de `hourOfPeriod` pour obtenir l'heure au format 12 heures
    if (time.period == DayPeriod.pm && hour != 12) {
      hour += 12; // Convertir l'heure PM en format 24 heures, sauf pour 12 PM
    }
    if (time.period == DayPeriod.am && hour == 12) {
      hour = 0; // Convertir 12 AM en 00:00
    }
    String formattedHour = hour.toString().padLeft(2, '0');
    String formattedMinute = time.minute.toString().padLeft(2, '0');
    return "$formattedHour:$formattedMinute"; // Retourne l'heure au format "HH:mm"
  }

  // Dialog de succès après ajout
  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: Padding(
            padding: const EdgeInsets.all(20.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.check_circle_outline,
                  color: Color(0xFF00BCD0),
                  size: 80,
                ),
                SizedBox(height: 20),
                Text(
                  'Succès',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF00BCD0),
                  ),
                ),
                SizedBox(height: 10),
                Text(
                  "L'emploi a été ajouté avec succès!",
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Ferme le dialog
                    Navigator.pop(
                        context, true); // Retourne à la page précédente
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ajouter un emploi'),
        backgroundColor: Color(0xFF00BCD0).withOpacity(0.88),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: Builder(
          builder: (context) => IconButton(
            icon: Icon(Icons.menu, color: Colors.black),
            onPressed: () => Scaffold.of(context).openDrawer(),
          ),
        ),
      ),
      drawer: Sidebar(
        authService: AuthService(),
        onSelectPage: (index) {},
        isDarkMode: false,
        toggleTheme: () {},
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_isLoading) CircularProgressIndicator(),
            if (!_isLoading)
              DropdownButtonFormField<String>(
                value: _selectedEmail,
                items: _emails.isEmpty
                    ? [
                        DropdownMenuItem(
                            value: null, child: Text("Aucun email disponible"))
                      ]
                    : _emails.map((email) {
                        return DropdownMenuItem(
                            value: email, child: Text(email));
                      }).toList(),
                onChanged: (value) => setState(() => _selectedEmail = value),
                decoration: InputDecoration(
                  labelText: "Email du technicien",
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                  enabledBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(
                            0xFF00BCD0)), // Couleur de la ligne quand désactivé
                  ),
                  focusedBorder: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xFF00BCD0),
                        width: 2), // Couleur de la ligne quand en focus
                  ),
                  border: UnderlineInputBorder(
                    borderSide: BorderSide(
                        color: Color(0xFF00BCD0)), // Bordure par défaut
                  ),
                ),
              ),
            SizedBox(height: 10),
            DropdownButtonFormField<String>(
              value: _selectedJourRepos,
              items: _joursRepos.map((jour) {
                return DropdownMenuItem(value: jour, child: Text(jour));
              }).toList(),
              onChanged: (value) => setState(() => _selectedJourRepos = value),
              decoration: InputDecoration(
                labelText: "Jour de repos",
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(
                          0xFF00BCD0)), // Couleur de la ligne quand désactivé
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF00BCD0),
                      width: 2), // Couleur de la ligne quand en focus
                ),
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                      color: Color(0xFF00BCD0)), // Bordure par défaut
                ),
              ),
            ),
            SizedBox(height: 10),
            ListTile(
              title: Text(_heureDebut != null
                  ? "Heure début: ${_formatTime(_heureDebut!)}"
                  : "Sélectionner heure début"),
              trailing: Icon(
                Icons.access_time,
                color: Color(0xFF00BCD0), // Icône turquoise
              ),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData(
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor:
                              Colors.white, // Couleur de fond du picker
                          hourMinuteColor: Color(
                              0xFF00BCD0), // Couleur de l'heure sélectionnée
                          dialHandColor:
                              Color(0xFF00BCD0), // Couleur de l'aiguille
                          dialTextColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? Colors.white
                                : Colors.black,
                          ),
                          entryModeIconColor:
                              Color(0xFF00BCD0), // Couleur de l'icône clavier
                          confirmButtonStyle: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(
                                Colors.black), // Texte du bouton "OK"
                          ),
                          cancelButtonStyle: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(
                                Colors.black), // Texte du bouton "Cancel"
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) setState(() => _heureDebut = picked);
              },
            ),
            ListTile(
              title: Text(_heureFin != null
                  ? "Heure fin: ${_formatTime(_heureFin!)}"
                  : "Sélectionner heure fin"),
              trailing: Icon(
                Icons.access_time,
                color: Color(0xFF00BCD0), // Icône turquoise
              ),
              onTap: () async {
                TimeOfDay? picked = await showTimePicker(
                  context: context,
                  initialTime: TimeOfDay.now(),
                  builder: (BuildContext context, Widget? child) {
                    return Theme(
                      data: ThemeData(
                        timePickerTheme: TimePickerThemeData(
                          backgroundColor:
                              Colors.white, // Couleur de fond du picker
                          hourMinuteColor: Color(
                              0xFF00BCD0), // Couleur de l'heure sélectionnée
                          dialHandColor:
                              Color(0xFF00BCD0), // Couleur de l'aiguille
                          dialTextColor: MaterialStateColor.resolveWith(
                            (states) => states.contains(MaterialState.selected)
                                ? Colors.white
                                : Colors.black,
                          ),
                          entryModeIconColor:
                              Color(0xFF00BCD0), // Couleur de l'icône clavier
                          confirmButtonStyle: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(
                                Colors.black), // Texte du bouton "OK"
                          ),
                          cancelButtonStyle: ButtonStyle(
                            foregroundColor: MaterialStateProperty.all(
                                Colors.black), // Texte du bouton "Cancel"
                          ),
                        ),
                      ),
                      child: child!,
                    );
                  },
                );
                if (picked != null) setState(() => _heureFin = picked);
              },
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed:
                  _ajouterEmploi, // Keep your existing function for adding the job
              style: ElevatedButton.styleFrom(
                backgroundColor:
                    Color(0xFF00BCD0), // Your desired background color
                minimumSize:
                    Size(double.infinity, 50), // Full width and height of 50
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                      30), // Rounded corners with radius 30
                ),
              ),
              child: Text(
                "Ajouter", // Text on the button
                style: TextStyle(
                  fontSize: 18, // Text size
                  color: Colors.white, // White text color
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
