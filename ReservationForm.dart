import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../services/PromotionService.dart'; // Importez le service

class ReservationForm extends StatefulWidget {
  final Service service;

  const ReservationForm({Key? key, required this.service}) : super(key: key);

  @override
  _ReservationFormState createState() => _ReservationFormState();
}

class _ReservationFormState extends State<ReservationForm> {
  final _formKey = GlobalKey<FormState>();
  DateTime selectedDate = DateTime.now();
  TimeOfDay selectedTime = TimeOfDay.now();
  String selectedVehicle = 'Voiture';
  LatLng? selectedLocation;
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();
  final TextEditingController _manualAddressController =
      TextEditingController();
  final TextEditingController _promoCodeController = TextEditingController();
  String selectedPaymentMode = 'EN_LIGNE'; // Mode de paiement par défaut

  final List<String> vehicleTypes = ['Voiture', 'SUV', 'Van', 'Camion'];
  bool isLoading = true;
  String? errorMessage;
  bool useMapForLocation = true;
  GoogleMapController? mapController;
  Set<Marker> markers = {};
  bool isApplyingPromo = false;
  String? promoErrorMessage;
  double? discountedPrice;

  @override
  void initState() {
    super.initState();
    _fetchUserInfo();
    _checkLocationPermission();
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
            'http://192.168.1.14:8085/api/services/${widget.service.id}/reserver'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _emailController.text = data['email'] ?? 'Non disponible';
          _phoneController.text = data['phone'] ?? 'Non disponible';
          _addressController.text =
              data['location'] ?? 'Emplacement non spécifié';
          errorMessage = null;
          isLoading = false;
        });
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

  Future<void> _checkLocationPermission() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      setState(() {
        errorMessage =
            "Veuillez activer la localisation pour utiliser la carte.";
      });
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        setState(() {
          errorMessage = "La permission de localisation est refusée.";
        });
        return;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      setState(() {
        errorMessage =
            "La permission de localisation est définitivement refusée.";
      });
      return;
    }

    _selectLocation();
  }

  Future<void> _selectLocation() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
    setState(() {
      selectedLocation = LatLng(position.latitude, position.longitude);
      _addressController.text =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    });
  }

  void _toggleLocationMethod() {
    setState(() {
      useMapForLocation = !useMapForLocation;
    });
  }

  void _onMapTap(LatLng location) {
    setState(() {
      selectedLocation = location;
      _addressController.text =
          "Latitude: ${location.latitude}, Longitude: ${location.longitude}";
      markers.clear();
      markers.add(Marker(
        markerId: MarkerId('selected_location'),
        position: location,
      ));
    });
  }

  void _confirmLocation() {
    if (selectedLocation != null) {
      _showSuccessAlert("Emplacement confirmé : ${_addressController.text}");
      print(
          "Emplacement confirmé : ${selectedLocation!.latitude}, ${selectedLocation!.longitude}");
    } else {
      _showErrorAlert("Veuillez sélectionner un emplacement sur la carte.");
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
                  child:
                      Text(errorMessage!, style: TextStyle(color: Colors.red)))
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
                                  style: GoogleFonts.poppins(
                                    fontSize: 18,
                                    color: Colors.grey[700],
                                  ),
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
                        SizedBox(height: 24),
                        // Champ pour le code promo
                        TextFormField(
                          controller: _promoCodeController,
                          decoration: InputDecoration(
                            labelText: 'Code Promo',
                            prefixIcon: Icon(Icons.local_offer),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                        ),
                        SizedBox(height: 16),
                        // Bouton pour appliquer le code promo
                        ElevatedButton(
                          onPressed: isApplyingPromo ? null : _applyPromoCode,
                          child: isApplyingPromo
                              ? CircularProgressIndicator()
                              : Text('Appliquer le code promo'),
                        ),
                        SizedBox(height: 16),
                        // Champ pour l'email
                        TextFormField(
                          controller: _emailController,
                          decoration: InputDecoration(
                              labelText: 'Email',
                              prefixIcon: Icon(Icons.email),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          readOnly: true,
                        ),
                        SizedBox(height: 16),
                        // Champ pour le téléphone
                        TextFormField(
                          controller: _phoneController,
                          decoration: InputDecoration(
                              labelText: 'Téléphone',
                              prefixIcon: Icon(Icons.phone),
                              border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(10))),
                          readOnly: true,
                        ),
                        SizedBox(height: 16),
                        // Section pour l'adresse du service
                        Text('Adresse du service',
                            style: GoogleFonts.poppins(
                                fontSize: 20, fontWeight: FontWeight.bold)),
                        SizedBox(height: 16),
                        Row(
                          children: [
                            Text("Utiliser la carte pour l'emplacement"),
                            Switch(
                              value: useMapForLocation,
                              onChanged: (value) {
                                _toggleLocationMethod();
                              },
                            ),
                          ],
                        ),
                        SizedBox(height: 16),
                        if (useMapForLocation)
                          Column(
                            children: [
                              Container(
                                height: 300, // Hauteur de la carte
                                decoration: BoxDecoration(
                                  border: Border.all(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: GoogleMap(
                                  onMapCreated: (controller) {
                                    setState(() {
                                      mapController = controller;
                                    });
                                  },
                                  onTap:
                                      _onMapTap, // Gérer les clics sur la carte
                                  initialCameraPosition: CameraPosition(
                                    target: selectedLocation ??
                                        LatLng(36.8065,
                                            10.1815), // Position initiale (Tunis)
                                    zoom: 12, // Niveau de zoom
                                  ),
                                  markers: markers, // Afficher les marqueurs
                                ),
                              ),
                              SizedBox(height: 16),
                              if (selectedLocation != null)
                                Column(
                                  children: [
                                    Text(
                                      "Emplacement sélectionné: ${_addressController.text}",
                                      style: TextStyle(fontSize: 16),
                                    ),
                                    SizedBox(height: 16),
                                    ElevatedButton(
                                      onPressed: _confirmLocation,
                                      child: Text("Confirmer l'emplacement"),
                                    ),
                                  ],
                                ),
                            ],
                          )
                        else
                          TextFormField(
                            controller: _manualAddressController,
                            decoration: InputDecoration(
                                labelText: 'Adresse manuelle',
                                prefixIcon: Icon(Icons.location_on),
                                border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10))),
                          ),
                        SizedBox(height: 16),
                        // Liste déroulante pour le mode de paiement
                        DropdownButtonFormField<String>(
                          value: selectedPaymentMode,
                          decoration: InputDecoration(
                            labelText: 'Mode de paiement',
                            prefixIcon: Icon(Icons.payment),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          items: ['EN_LIGNE', 'SUR_PLACE'].map((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                          onChanged: (String? newValue) {
                            setState(() {
                              selectedPaymentMode = newValue!;
                            });
                          },
                        ),
                        SizedBox(height: 24),
                        // Bouton de soumission du formulaire
                        Center(
                          child: ElevatedButton(
                            onPressed: () {
                              if (_formKey.currentState!.validate()) {
                                // Traitement de la réservation
                                _showSuccessAlert(
                                    "Réservation effectuée avec succès !");
                              }
                            },
                            child: Text('Réserver'),
                            style: ElevatedButton.styleFrom(
                              backgroundColor: primaryColor,
                              padding: EdgeInsets.symmetric(
                                  horizontal: 50, vertical: 15),
                              textStyle: TextStyle(fontSize: 18),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
    );
  }
}
