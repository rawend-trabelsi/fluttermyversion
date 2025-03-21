import 'dart:convert';
import 'dart:developer';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_fonts/google_fonts.dart';
import 'dart:convert'; // Pour utiliser json.decode
import '../models/service.dart';
import '../services/PromotionService.dart';

class ReservationForm extends StatefulWidget {
  final Service service;

  ReservationForm({required this.service});

  @override
  _ReservationFormState createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedVehicle = 'Voiture';
  String selectedPaymentMode = 'EN_LIGNE'; // Mode de paiement par défaut

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _promoCodeController = TextEditingController();

  bool isLoading = true;
  String? errorMessage;
  bool isApplyingPromo = false;
  String? promoErrorMessage;
  double? discountedPrice;

  // Variables pour Google Maps
  late GoogleMapController mapController;
  late LatLng _center;
  LatLng _selectedLocation = LatLng(36.8091, 10.1652); // Position par défaut

  @override
  void initState() {
    super.initState();
    _center = LatLng(36.8091, 10.1652); // Latitude et longitude par défaut (exemple)
    _fetchUserInfo();
    _checkForPromotion();
  }

  Future<void> _fetchUserInfo() async {
    setState(() => isLoading = true);
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? token = prefs.getString('jwt_token');

      if (token == null || token.isEmpty) {
        setState(() {
          errorMessage = "Utilisateur non connecté.";
          isLoading = false;
        });
        return;
      }

      final response = await http.get(
        Uri.parse(
            'http://10.0.2.2:8085/api/services/${widget.service.id}/reserver'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        try {
          final data = json.decode(response.body); // Ici, on décode la réponse
          setState(() {
            _emailController.text = data['email'] ?? 'Non disponible';
            _phoneController.text = data['phone'] ?? 'Non disponible';
            _addressController.text =
                data['location'] ?? 'Emplacement non spécifié';
            errorMessage = null;
            isLoading = false;
          });
        } catch (e) {
          setState(() {
            errorMessage = "Erreur de décodage des données.";
            isLoading = false;
          });
        }
      } else {
        setState(() {
          errorMessage = "Erreur: Impossible de récupérer les informations.";
          isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        errorMessage = "Erreur de connexion au serveur.";
        isLoading = false;
      });
    }
  }

  Future<void> _checkForPromotion() async {
    if (widget.service.promotion != null && widget.service.promotion!.isNotEmpty) {
      setState(() {
        discountedPrice = widget.service.discountedPrice;
      });
    }
  }

  Future<void> _applyPromoCode() async {
    setState(() {
      isApplyingPromo = true;
      promoErrorMessage = null;
    });

    try {
      if (_promoCodeController.text.isEmpty) {
        _showErrorAlert("Veuillez entrer un code promo.");
        return;
      }

      final promotionService = PromotionService();
      final response = await promotionService.applyPromoCode(
        _promoCodeController.text,
        widget.service.id,
      );

      if (response.containsKey('error')) {
        _showErrorAlert(response['error']);
      } else {
        setState(() {
          discountedPrice = response['discountedPrice'];
        });
        _showSuccessAlert("Le code promo a été appliqué avec succès !");
      }
    } catch (e) {
      _showErrorAlert("$e");
    } finally {
      setState(() {
        isApplyingPromo = false;
      });
    }
  }

  void _showErrorAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Erreur", style: TextStyle(color: Colors.red)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.cyan)),
            ),
          ],
        );
      },
    );
  }

  void _showSuccessAlert(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Succès", style: TextStyle(color: Colors.cyan)),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('OK', style: TextStyle(color: Colors.cyan)),
            ),
          ],
        );
      },
    );
  }

  // Fonction pour mettre à jour la localisation sélectionnée
  void _onMapTapped(LatLng tappedPoint) {
    setState(() {
      _selectedLocation = tappedPoint;
      _addressController.text = "Latitude: ${tappedPoint.latitude}, Longitude: ${tappedPoint.longitude}";
    });

    // Déplacer la caméra vers le nouvel emplacement sélectionné
    mapController.animateCamera(
      CameraUpdate.newLatLng(tappedPoint),
    );
  }

  @override
  Widget build(BuildContext context) {
    final service = widget.service;
    final bool hasPromotion = discountedPrice != null;
    final Color primaryColor = Color(0xFF00BCD0);

    return Scaffold(
      appBar: AppBar(
        title: Text('Réservation'),
        backgroundColor: primaryColor,
      ),
      body: isLoading
          ? Center(child: CircularProgressIndicator())
          : errorMessage != null
          ? Center(
          child: Text(errorMessage!, style: TextStyle(color: Colors.red)))
          : SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Affichage des informations du service
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        service.titre,
                        style: GoogleFonts.poppins(
                          fontSize: 24,
                          fontWeight: FontWeight.bold,
                          color: primaryColor,
                        ),
                      ),
                      SizedBox(height: 8),
                      Text(
                        "Durée: ${service.duree}",
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      SizedBox(height: 8),
                      Text(
                        hasPromotion
                            ? "Prix avec remise: ${discountedPrice!.toStringAsFixed(2)} DT"
                            : "Prix: ${service.prix.toStringAsFixed(2)} DT",
                        style: GoogleFonts.poppins(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: hasPromotion
                              ? Colors.green
                              : Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: 16),
              // Formulaire de réservation
              TextFormField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextFormField(
                controller: _phoneController,
                decoration: InputDecoration(labelText: 'Numéro de téléphone'),
              ),
              TextFormField(
                controller: _addressController,
                decoration: InputDecoration(labelText: 'Emplacement'),
              ),
              TextFormField(
                controller: _promoCodeController,
                decoration: InputDecoration(labelText: 'Code promo'),
              ),
              SizedBox(height: 16),
              ElevatedButton(
                onPressed: _applyPromoCode,
                child: isApplyingPromo
                    ? CircularProgressIndicator(
                  color: Colors.white,
                )
                    : Text('Appliquer le code promo'),
              ),
              SizedBox(height: 16),
              Text(
                "Mode de paiement:",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              DropdownButton<String>(
                value: selectedPaymentMode,
                onChanged: (String? newValue) {
                  setState(() {
                    selectedPaymentMode = newValue!;
                  });
                },
                items: <String>['EN_LIGNE', 'A_LA_LIVRAISON']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 16),
              // Google Map widget
              Container(
                height: 300.0, // Hauteur de la carte
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: _center,
                    zoom: 12,
                  ),
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                  },
                  onTap: _onMapTapped, // Fonction appelée lors du tap
                  markers: {
                    Marker(
                      markerId: MarkerId('selectedLocation'),
                      position: _selectedLocation,
                    ),
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

}