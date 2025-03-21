import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectlavage/screens/ListerPromotionsScreen.dart';
import '../models/PromotionDTO.dart';
import '../models/ServiceDTO.dart';
import '../services/ServiceService.dart';
import '../services/PromotionService.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart';

class AjouterPromotionScreen extends StatefulWidget {
  @override
  _AjouterPromotionScreenState createState() => _AjouterPromotionScreenState();
}

class _AjouterPromotionScreenState extends State<AjouterPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  final _codePromoController = TextEditingController();
  final _valeurReductionController = TextEditingController();

  DateTime _dateDebut =
      DateTime.now().toLocal().copyWith(hour: 22, minute: 59, second: 0);
  DateTime _dateFin = DateTime.now()
      .toLocal()
      .add(Duration(days: 1))
      .copyWith(hour: 22, minute: 59, second: 0);
  String _typeReduction = 'POURCENTAGE';
  List<ServiceDTO> _services = [];
  List<int> _selectedServiceIds = [];
  bool selectAll = false;

  final PromotionService _promotionService = PromotionService();

  get hintText => null;

  @override
  void initState() {
    super.initState();
    _fetchServices();
  }

  Future<void> _fetchServices() async {
    try {
      List<ServiceDTO> services = await ServiceService().getServicesDTO();
      setState(() {
        _services = services;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur: Impossible de récupérer les services')),
      );
    }
  }

  Future<DateTime?> _selectDateTime(BuildContext context,
      {bool isStartDate = true}) async {
    DateTime now = DateTime.now().toLocal(); // Heure locale

    // Définir les dates limites
    DateTime initialDate =
        isStartDate ? now : _dateDebut.add(Duration(days: 1));
    DateTime firstDate = isStartDate ? now : _dateDebut.add(Duration(days: 1));
    DateTime lastDate = DateTime(2101);

    // Affichage du sélecteur de date
    DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary: Color(0xFF00BCD0),
              secondary: Color(0xFF00BCD0),
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (pickedDate == null) return null;

    // Toujours retourner la date avec l'heure fixée à 23:00:00
    return DateTime(pickedDate.year, pickedDate.month, pickedDate.day, 22, 59);
  }

  Future<void> _submitPromotion() async {
    List<ServiceDTO> selectedServices = _services
        .where((service) => _selectedServiceIds.contains(service.id))
        .map((service) => ServiceDTO(id: service.id, titre: service.titre))
        .toList();

    if (selectedServices.isEmpty) {
      _showErrorDialog('Veuillez sélectionner au moins un service.');
      return;
    }

    final promotionDTO = PromotionDTO(
      id: 0,
      actif: true,
      typeReduction: _typeReduction,
      valeurReduction: double.parse(_valeurReductionController.text),
      dateDebut: _dateDebut,
      dateFin: _dateFin,
      codePromo:
          _codePromoController.text.isEmpty ? null : _codePromoController.text,
      servicesDTO: selectedServices,
    );

    try {
      String message = await _promotionService.addPromotion(promotionDTO);
      if (message == "Promotion ajoutée avec succès") {
        _showConfirmationDialog('La promotion a été ajoutée avec succès !');
      }
    } catch (e) {
      _showErrorDialog('Erreur: $e');
    }
  }

  void _showConfirmationDialog(String message) {
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
                  message,
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context); // Ferme la boîte de dialogue
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                              ListerPromotionsScreen()), // Redirige vers la liste des promotions
                    );
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
                Icon(Icons.error_outline, color: Colors.red, size: 80),
                SizedBox(height: 20),
                Text('Erreur',
                    style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.red)),
                SizedBox(height: 10),
                Text(message,
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 16)),
                SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding:
                          EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30))),
                  child: Text('OK',
                      style: TextStyle(fontSize: 18, color: Colors.white)),
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
        title: Text('Ajouter promotion'),
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
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              TextFormField(
                controller: _valeurReductionController,
                decoration: InputDecoration(
                  labelText: 'Valeur de réduction',
                  hintText: hintText,
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
                keyboardType: TextInputType.number,
                validator: (value) =>
                    value!.isEmpty ? 'Veuillez entrer une valeur' : null,
              ),
              TextFormField(
                controller: _codePromoController,
                decoration: InputDecoration(
                  labelText: 'Code Promo (optionnel)',
                  hintText: hintText,
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
              DropdownButtonFormField<String>(
                value: _typeReduction,
                items: ['POURCENTAGE', 'MONTANT_FIXE']
                    .map((type) =>
                        DropdownMenuItem(value: type, child: Text(type)))
                    .toList(),
                onChanged: (value) => setState(() => _typeReduction = value!),
                decoration: InputDecoration(
                  labelText: 'Type de réduction',
                  hintText: hintText,
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
              ListTile(
                title: Text(
                  "Date de début: ${DateFormat('dd/MM/yyyy ').format(_dateDebut)}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(
                  Icons.calendar_today,
                  color: Color(0xFF00BCD0),
                ),
                onTap: () async {
                  DateTime? picked =
                      await _selectDateTime(context, isStartDate: true);
                  if (picked != null) {
                    setState(() {
                      _dateDebut =
                          picked; // Déjà à 23:00 grâce à _selectDateTime
                      if (_dateFin.isBefore(_dateDebut)) {
                        _dateFin = _dateDebut.add(Duration(
                            days:
                                1)); // Assurer que _dateFin est après _dateDebut
                      }
                    });
                  }
                },
              ),
              ListTile(
                title: Text(
                  "Date de fin: ${DateFormat('dd/MM/yyyy ').format(_dateFin)}",
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                trailing: Icon(
                  Icons.calendar_today,
                  color: Color(0xFF00BCD0),
                ),
                onTap: () async {
                  DateTime? picked =
                      await _selectDateTime(context, isStartDate: false);
                  if (picked != null) {
                    setState(() {
                      _dateFin = picked; // Déjà à 23:00 grâce à _selectDateTime
                    });
                  }
                },
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Sélectionnez les services :",
                    style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF00BCD0)),
                  ),
                  CheckboxListTile(
                    title: Text("Tous les services"),

                    value: selectAll,
                    activeColor: Color(0xFF00BCD0), // Couleur de la case cochée
                    checkColor: Colors.white, // Couleur de la coche
                    onChanged: (value) {
                      setState(() {
                        selectAll = value ?? false;
                        _selectedServiceIds = selectAll
                            ? _services.map((s) => s.id).toList()
                            : [];
                      });
                    },
                  ),
                  ..._services.map((service) => CheckboxListTile(
                        title: Text(service.titre),
                        value: _selectedServiceIds.contains(service.id),
                        activeColor:
                            Color(0xFF00BCD0), // Couleur de la case cochée
                        checkColor: Colors.white, // Couleur de la coche
                        onChanged: (isSelected) {
                          setState(() {
                            isSelected == true
                                ? _selectedServiceIds.add(service.id)
                                : _selectedServiceIds.remove(service.id);
                          });
                        },
                      )),
                ],
              ),
              ElevatedButton(
                onPressed: _submitPromotion,
                child: Text(
                  'Ajouter la Promotion',
                  style:
                      TextStyle(color: Colors.white), // Set text color to white
                ),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFF00BCD0),
                  padding: EdgeInsets.symmetric(vertical: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
