import 'package:flutter/material.dart';
import '../models/TechnicienEmploi.dart';
import '../services/emploi_service.dart';
import '../services/auth_service.dart';
import 'AjoutEmploiPage.dart';
import 'admin_screen.dart';

class EmploisPage extends StatefulWidget {
  @override
  _EmploisPageState createState() => _EmploisPageState();
}

class _EmploisPageState extends State<EmploisPage> {
  final EmploiService _emploiService = EmploiService();
  late Future<List<TechnicienEmploi>> _emploisFuture;

  @override
  void initState() {
    super.initState();
    _loadEmplois();
  }

  Future<void> _loadEmplois() async {
    String? token = await AuthService.getToken();
    if (token != null) {
      setState(() {
        _emploisFuture = _emploiService.getTechniciensEmplois(token);
      });
    } else {
      print("Erreur : Aucun token trouvé !");
    }
  }

  String _formatTime(String time) {
    if (time == null || time.isEmpty) return 'Non défini';
    final hours = int.parse(time.split(':')[0]);
    final minutes = int.parse(time.split(':')[1]);
    return '${hours.toString().padLeft(2, '0')}:${minutes.toString().padLeft(
        2, '0')}';
  }

  Future<void> _editEmploi(BuildContext context,
      TechnicienEmploi emploi) async {
    String? jourRepos = emploi.jourRepos;
    String? heureDebut = emploi.heureDebut;
    String? heureFin = emploi.heureFin;

    // Liste des jours de la semaine
    List<String> jours = [
      "LUNDI",
      "MARDI",
      "MERCREDI",
      "JEUDI",
      "VENDREDI",
      "SAMEDI",
      "DIMANCHE"
    ];

    // Convertir TimeOfDay en format "HH:mm"
    // Fonction pour formater l'heure en hh:mm
    String _formatTimeForPicker(TimeOfDay time) {
      // Récupère l'heure et les minutes en format 24h
      int hour = time.hour;
      String formattedHour = hour.toString().padLeft(2, '0');
      String formattedMinute = time.minute.toString().padLeft(2, '0');

      // Retourne l'heure au format HH:mm
      return "$formattedHour:$formattedMinute";
    }


    // Ouvrir la boîte de dialogue pour éditer les informations
    await showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            'Modifier l\'emploi de ${emploi.username}',
            style: TextStyle(color: Color(0xFF00BCD0)), // Couleur turquoise
          ),

          content: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // DropdownButton pour le jour de repos
                  DropdownButton<String>(
                    value: jourRepos,
                    onChanged: (String? newValue) {
                      setState(() {
                        jourRepos = newValue!;
                      });
                    },
                    items: jours.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList(),
                  ),
                  // Sélection de l'heure de début avec TimePicker
                  ListTile(
                    title: Text('Heure Début'),
                    subtitle: Text(heureDebut ?? 'Non défini'),
                    onTap: () async {
                      TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData(
                              timePickerTheme: TimePickerThemeData(
                                backgroundColor: Colors.white, // Couleur de fond du picker
                                hourMinuteColor: Color(0xFF00BCD0), // Couleur de l'heure sélectionnée
                                dialHandColor: Color(0xFF00BCD0), // Couleur de l'aiguille
                                dialTextColor: MaterialStateColor.resolveWith(
                                      (states) => states.contains(MaterialState.selected) ? Colors.white : Colors.black,
                                ),
                                entryModeIconColor: Color(0xFF00BCD0), // Couleur de l'icône clavier
                                confirmButtonStyle: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(Colors.black), // Texte du bouton "OK"
                                ),
                                cancelButtonStyle: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(Colors.black), // Texte du bouton "Cancel"
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (selectedTime != null) {
                        setState(() {
                          heureDebut = _formatTimeForPicker(selectedTime);
                        });
                      }
                    },
                  ),

                  // Sélection de l'heure de fin avec TimePicker
                  // Sélection de l'heure de fin avec TimePicker
                  ListTile(
                    title: Text('Heure Fin'),
                    subtitle: Text(heureFin ?? 'Non défini'), // Afficher l'heure de fin
                    onTap: () async {
                      TimeOfDay? selectedTime = await showTimePicker(
                        context: context,
                        initialTime: TimeOfDay.now(),
                        builder: (BuildContext context, Widget? child) {
                          return Theme(
                            data: ThemeData(
                              timePickerTheme: TimePickerThemeData(
                                backgroundColor: Colors.white, // Couleur de fond du picker
                                hourMinuteColor: Color(0xFF00BCD0), // Couleur de l'heure sélectionnée
                                dialHandColor: Color(0xFF00BCD0), // Couleur de l'aiguille
                                dialTextColor: MaterialStateColor.resolveWith(
                                      (states) => states.contains(MaterialState.selected) ? Colors.white : Colors.black,
                                ),
                                entryModeIconColor: Color(0xFF00BCD0), // Couleur de l'icône clavier
                                confirmButtonStyle: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(Colors.black), // Texte du bouton "OK"
                                ),
                                cancelButtonStyle: ButtonStyle(
                                  foregroundColor: MaterialStateProperty.all(Colors.black), // Texte du bouton "Cancel"
                                ),
                              ),
                            ),
                            child: child!,
                          );
                        },
                      );

                      if (selectedTime != null) {
                        setState(() {
                          // Mettez à jour heureFin au lieu de heureDebut ici
                          heureFin = _formatTimeForPicker(selectedTime);
                        });
                      }
                    },
                  ),

                ],
              );
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text(
                'Annuler',
                style: TextStyle(color: Colors.grey), // Texte gris
              ),
            ),
            TextButton(
              onPressed: () async {
                if (jourRepos != null && heureDebut != null && heureFin != null) {
                  try {
                    // Appeler la fonction du service pour mettre à jour l'emploi
                    bool success = await _emploiService.updateEmploiTechnicien(
                      emploi.id,
                      TechnicienEmploi(
                        id: emploi.id,
                        username: emploi.username,
                        email: emploi.email,
                        phone: emploi.phone,
                        jourRepos: jourRepos ?? '',
                        heureDebut: heureDebut ?? '',
                        heureFin: heureFin ?? '',
                      ),
                    );

                    if (success) {
                      // Recharger la liste des emplois après mise à jour
                      _loadEmplois();

                      // Afficher la boîte de dialogue de succès
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
                                    "L'emploi e été mises à jour avec succès!",
                                    textAlign: TextAlign.center,
                                    style: TextStyle(fontSize: 16),
                                  ),
                                  SizedBox(height: 20),
                                  ElevatedButton(
                                    onPressed: () {
                                      Navigator.pop(context); // Ferme le dialog
                                      Navigator.pop(context, true); // Retourne à la page précédente
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
                    } else {
                      // Afficher une erreur si la mise à jour a échoué
                      ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Échec de la mise à jour')));
                    }
                  } catch (e) {
                    // Gestion des erreurs
                    ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(content: Text('Erreur : ${e.toString()}')));
                  }
                }
              },
              child: Text(
                'Valider',
                style: TextStyle(color: Color(0xFF00BCD0)), // Texte turquoise
              ),
            ),

          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des emplois'),

        backgroundColor: Color(0xFF00BCD0).withOpacity(0.88),
        centerTitle: true,
        automaticallyImplyLeading: false,
        elevation: 0,
        leading: Builder(
          builder: (context) =>
              IconButton(
                icon: Icon(Icons.menu, color: Colors.black),
                onPressed: () =>
                    Scaffold.of(context).openDrawer(),
              ),
        ),
      ),
      drawer: Sidebar(
        authService: AuthService(),
        onSelectPage: (index) {},
        isDarkMode: false,
        toggleTheme: () {},
      ),
      body: FutureBuilder<List<TechnicienEmploi>>(
        future: _emploisFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Erreur: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text('Aucun emploi trouvé'));
          }

          List<TechnicienEmploi> emplois = snapshot.data!;
          return ListView.builder(
            itemCount: emplois.length,
            itemBuilder: (context, index) {
              final emploi = emplois[index];
              return Container(
                margin: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
                decoration: BoxDecoration(
                  border: Border.all(color: Color(0xFF00BCD0), width: 2),
                  // Bordure de couleur
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Card(
                  elevation: 5, // Ajout d'une légère ombre
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: ListTile(
                    title: Text(
                      emploi.username,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors
                            .blueGrey, // Changement de la couleur du texte
                      ),
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        _buildInfoRow(Icons.email, emploi.email),
                        _buildInfoRow(Icons.weekend,
                            " ${emploi.jourRepos}", isRestDay: true),
                        // Icône modifiée pour le repos
                        _buildInfoRow(
                          Icons.schedule,
                          " ${_formatTime(
                              emploi.heureDebut)} - ${_formatTime(
                              emploi.heureFin)}",
                        ),
                        _buildInfoRow(Icons.phone, emploi.phone),
                      ],
                    ),
                    trailing: ElevatedButton.icon(
                      onPressed: () {
                        _editEmploi(context, emploi);
                      },
                      icon: Icon(Icons.edit, color: Colors.white),
                      label: Text('Éditer', style: TextStyle(
                          color: Colors.white)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      ),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => AjoutEmploiPage()),
          );
          _loadEmplois();
        },
        backgroundColor: Color(0xFF00BCD0),
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }

// Widget auxiliaire pour créer des lignes d'information avec des icônes
  Widget _buildInfoRow(IconData icon, String text, {bool isRestDay = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      // Espacement entre les lignes
      child: Row(
        children: [
          Icon(
            isRestDay ? Icons.weekend : icon,
            // Icône spécifique pour le jour de repos
            color: Color(0xFF00BCD0),
            // Utilisation de la couleur définie pour les icônes
            size: 24,
          ),
          SizedBox(width: 10), // Espacement entre l'icône et le texte
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[800], // Changement de couleur pour le texte
                fontWeight: FontWeight
                    .w500, // Poids de police léger pour le texte
              ),
            ),
          ),
        ],
      ),
    );
  }
}
