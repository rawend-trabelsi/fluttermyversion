import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart'; // Importez Google Maps
import '../models/reservation_model.dart';
import '../services/ReservationService.dart';
import '../services/auth_service.dart';
import '../services/emploi_service.dart';
import 'admin_screen.dart';

class ReservationsScreen extends StatefulWidget {
  @override
  _ReservationsScreenState createState() => _ReservationsScreenState();
}

class _ReservationsScreenState extends State<ReservationsScreen> {
  final ReservationService _reservationService = ReservationService();
  final EmploiService _emploiService = EmploiService();
  late Future<List<Reservation>> _reservations;

  @override
  void initState() {
    super.initState();
    _reservations = _reservationService.fetchReservations();
  }

  void _showTechnicienSelectionDialog(int reservationId, String? currentTechnicienEmail) async {
    try {
      List<String> emails = await _emploiService.getEmailsTechniciens();

      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: Text(
              "Sélectionner un technicien",
              style: TextStyle(
                color: Color(0xFF00BCD0),
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            content: SingleChildScrollView(
              child: Column(
                children: emails.map((email) {
                  return ListTile(
                    title: Text(email),
                    onTap: () async {
                      if (email != currentTechnicienEmail) {
                        try {
                          if (currentTechnicienEmail == null) {
                            await _reservationService.affecterTechnicien(reservationId, email, context);
                          } else {
                            await _reservationService.updateTechnicienReservation(reservationId, email, context);
                          }

                          setState(() {
                            _reservations = _reservationService.fetchReservations();
                          });
                          Navigator.of(context).pop();
                        } catch (error) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(content: Text("Erreur lors de l'affectation : $error")),
                          );
                        }
                      } else {
                        Navigator.of(context).pop();
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text("Le technicien est déjà affecté à cette réservation.")),
                        );
                      }
                    },
                  );
                }).toList(),
              ),
            ),
          );
        },
      );
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Erreur lors de la récupération des techniciens")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Liste des réservations'),
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
      body: FutureBuilder<List<Reservation>>(
        future: _reservations,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text("Erreur: ${snapshot.error}"));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return Center(child: Text("Aucune réservation disponible"));
          }

          return ListView.builder(
            itemCount: snapshot.data!.length,
            itemBuilder: (context, index) {
              Reservation reservation = snapshot.data![index];
              // Extraire les coordonnées de la localisation
              List<String> coords = reservation.localisation.split(',');
              double latitude = double.parse(coords[0]);
              double longitude = double.parse(coords[1]);

              return Card(
                elevation: 3,
                margin: EdgeInsets.all(8),
                child: Padding(
                  padding: const EdgeInsets.all(10.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        decoration: BoxDecoration(
                          border: Border.all(color: Color(0xFF00BCD0), width: 2),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(reservation.titreService,
                                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                              SizedBox(height: 5),
                              Text("📅 Date Réservation: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(reservation.dateReservation))}"),
                              Text("🕒 Date Création: ${DateFormat('dd/MM/yyyy HH:mm').format(DateTime.parse(reservation.dateCreation))}"),
                              Text("💰 Prix:  ${reservation.prix % 1 == 0 ? reservation.prix.toInt() : reservation.prix} DT "),
                              Text("📧 Email: ${reservation.email}"),
                              Text("📞 Téléphone: ${reservation.phone}"),
                              Text("⏳ Durée: ${reservation.duree}"),
                              Text("💳 Mode de Paiement: ${reservation.modePaiement}"),
                              SizedBox(height: 10),
                              // Afficher les coordonnées (latitude et longitude)
                              Text(
                                "📍 Coordonnées: Latitude: $latitude, Longitude: $longitude",
                                style: TextStyle(fontSize: 16),
                              ),
                              SizedBox(height: 10),
                              // Afficher la carte Google Maps directement
                              Container(
                                height: 200, // Hauteur de la carte
                                child: GoogleMap(
                                  initialCameraPosition: CameraPosition(
                                    target: LatLng(latitude, longitude),
                                    zoom: 14,
                                  ),
                                  markers: {
                                    Marker(
                                      markerId: MarkerId("selectedLocation"),
                                      position: LatLng(latitude, longitude),
                                    ),
                                  },
                                ),
                              ),
                              SizedBox(height: 10),
                              if (reservation.usernameTechnicien == null || reservation.emailTechnicien == null) ...[
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () => _showTechnicienSelectionDialog(reservation.id, null),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF00BCD0),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text("Affecter Technicien"),
                                  ),
                                ),
                              ] else ...[
                                Text("👨‍🔧 Technicien: ${reservation.usernameTechnicien}"),
                                Text("📩 Email Technicien: ${reservation.emailTechnicien}"),
                                SizedBox(height: 10),
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: ElevatedButton(
                                    onPressed: () => _showTechnicienSelectionDialog(reservation.id, reservation.emailTechnicien),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Color(0xFF00BCD0),
                                      foregroundColor: Colors.white,
                                    ),
                                    child: Text("Modifier Affectation"),
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}