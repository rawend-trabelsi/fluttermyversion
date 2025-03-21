import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectlavage/models/PromotionDTO.dart';
import 'package:projectlavage/models/ServiceDTO.dart';
import '../services/PromotionService.dart';
import '../services/ServiceService.dart';
import '../services/auth_service.dart';
import 'ListerPromotionsScreen.dart';
import 'admin_screen.dart';

class EditPromotionScreen extends StatefulWidget {
  final PromotionDTO promotion;

  const EditPromotionScreen({Key? key, required this.promotion})
      : super(key: key);

  @override
  _EditPromotionScreenState createState() => _EditPromotionScreenState();
}

class _EditPromotionScreenState extends State<EditPromotionScreen> {
  final _formKey = GlobalKey<FormState>();
  late TextEditingController _reductionValueController;
  late TextEditingController _codePromoController;
  late DateTime _startDate;
  late DateTime _endDate;
  String _reductionType = 'POURCENTAGE'; // Valeur par défaut
  List<ServiceDTO> _selectedServices = [];
  List<ServiceDTO> _availableServices = [];

  final PromotionService _promotionService = PromotionService();
  final ServiceService _serviceService = ServiceService();

  final List<String> _reductionTypes = ['POURCENTAGE', 'MONTANT_FIXE'];

  get hintText => null;

  @override
  void initState() {
    super.initState();

    _reductionValueController = TextEditingController(
      text: widget.promotion.valeurReduction?.toString() ?? '0.0',
    );
    _codePromoController = TextEditingController(
      text: widget.promotion.codePromo ?? '',
    );

    _startDate = widget.promotion.dateDebut;
    _endDate = widget.promotion.dateFin;
    _reductionType = widget.promotion.typeReduction ?? 'POURCENTAGE';

    _selectedServices =
        List<ServiceDTO>.from(widget.promotion.servicesDTO ?? []);

    _loadAvailableServices();
  }

  Future<void> _loadAvailableServices() async {
    try {
      final services = await _serviceService.getServicesDTO();
      setState(() {
        _availableServices = services;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erreur lors du chargement des services: $e')),
      );
    }
  }

  Future<void> _selectStartDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _startDate,
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  Color(0xFF00BCD0), // Couleur principale (date sélectionnée)
              secondary: Color(0xFF00BCD0), // Couleur secondaire
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Fixer l'heure à 23:00
      final DateTime startDateWithTime =
          DateTime(picked.year, picked.month, picked.day, 22, 59);
      setState(() => _startDate = startDateWithTime);
    }
  }

  Future<void> _selectEndDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _endDate,
      firstDate: DateTime.now()
          .add(Duration(days: 1))
          .toLocal(), // L'utilisateur ne peut pas sélectionner une date antérieure au lendemain de la date du jour
      lastDate: DateTime(2101),
      builder: (BuildContext context, Widget? child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.light(
              primary:
                  Color(0xFF00BCD0), // Couleur principale (date sélectionnée)
              secondary: Color(0xFF00BCD0), // Couleur secondaire
            ),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      // Fixer l'heure à 23:00
      final DateTime endDateWithTime =
          DateTime(picked.year, picked.month, picked.day, 22, 59);
      setState(() => _endDate = endDateWithTime);
    }
  }

  @override
  void dispose() {
    _reductionValueController.dispose();
    _codePromoController.dispose();
    super.dispose();
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

  void _savePromotion() async {
    // Vérifier si la valeur de réduction est vide
    if (_reductionValueController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Veuillez remplir tous les champs obligatoires')),
      );
      return;
    }

    // Convertir la valeur de réduction en double
    double? valeurReduction = double.tryParse(_reductionValueController.text);
    if (valeurReduction == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Veuillez entrer une valeur numérique valide')),
      );
      return;
    }

    try {
      // Créer l'objet PromotionDTO mis à jour
      PromotionDTO updatedPromotion = PromotionDTO(
        id: widget.promotion.id,
        actif: widget.promotion.actif,
        valeurReduction: valeurReduction,
        typeReduction: _reductionType,
        dateDebut: _startDate,
        dateFin: _endDate,
        servicesDTO: _selectedServices,
        codePromo: _codePromoController.text.isNotEmpty
            ? _codePromoController.text
            : '',
      );

      // Mettre à jour la promotion via le service
      await _promotionService.updatePromotion(updatedPromotion);

      // Afficher un message de succès
      _showConfirmationDialog('La promotion a été mise à jour avec succès.');

      // Rediriger vers l'écran de liste des promotions
      Navigator.of(context).pop(true);
    } catch (e) {
      _showConfirmationDialog('La promotion a été mise à jour avec succès.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modifier promotion'),
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
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: _reductionValueController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: InputDecoration(
                labelText: 'Valeur de Réduction',
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
              onChanged: (value) {
                // Remplace la virgule par un point lorsque l'utilisateur tape une virgule
                if (value.contains(',')) {
                  _reductionValueController.value = TextEditingValue(
                    text: value.replaceAll(',', '.'),
                    selection: TextSelection.collapsed(offset: value.length),
                  );
                }
              },
            ),
            SizedBox(height: 16),
            DropdownButtonFormField<String>(
              value: _reductionType,
              decoration: InputDecoration(
                labelText: 'Type de Réduction',
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
              items: _reductionTypes.map((type) {
                return DropdownMenuItem(
                  value: type,
                  child: Text(type),
                );
              }).toList(),
              onChanged: (value) => setState(() => _reductionType = value!),
            ),
            SizedBox(height: 16),
            SizedBox(height: 16),
            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectStartDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF00BCD0), // Applique la couleur de fond
                    ),
                    child: Text(
                      'Date Début: ${DateFormat('dd/MM/yyyy').format(_startDate)}',
                      style: TextStyle(color: Colors.white), // Texte en blanc
                    ),
                  ),
                ),
                SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () => _selectEndDate(context),
                    style: ElevatedButton.styleFrom(
                      backgroundColor:
                          Color(0xFF00BCD0), // Applique la couleur de fond
                    ),
                    child: Text(
                      'Date Fin: ${DateFormat('dd/MM/yyyy').format(_endDate)}',
                      style: TextStyle(color: Colors.white), // Texte en blanc
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: 16),
            TextField(
              controller: _codePromoController,
              decoration: InputDecoration(
                labelText: 'Code Promo (Optionnel)',
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
            SizedBox(height: 16),
            Text(
              'Services Concernés',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            _availableServices.isEmpty
                ? Center(child: CircularProgressIndicator())
                : Column(
                    children: [
                      // Checkbox pour sélectionner tous les services
                      CheckboxListTile(
                        title: Text(
                          "Tous les services",
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        value: _selectedServices.length ==
                                _availableServices.length &&
                            _availableServices.isNotEmpty,
                        onChanged: (bool? value) {
                          setState(() {
                            if (value == true) {
                              _selectedServices = List.from(
                                  _availableServices); // Tout sélectionner
                            } else {
                              _selectedServices.clear(); // Tout désélectionner
                            }
                          });
                        },
                        activeColor: Color(0xFF00BCD0),
                        // Couleur du check
                        controlAffinity: ListTileControlAffinity
                            .trailing, // Case à cocher à droite
                      ),

                      // Liste des services individuels
                      ..._availableServices.map((service) {
                        return CheckboxListTile(
                          title: Text(service.titre),
                          value:
                              _selectedServices.any((s) => s.id == service.id),
                          onChanged: (bool? value) {
                            setState(() {
                              if (value == true) {
                                _selectedServices.add(service);
                              } else {
                                _selectedServices
                                    .removeWhere((s) => s.id == service.id);
                              }
                            });
                          },
                          activeColor: Color(0xFF00BCD0),
                          // Couleur du check
                          controlAffinity: ListTileControlAffinity
                              .trailing, // Case à cocher à droite
                        );
                      }).toList(),
                    ],
                  ),
            SizedBox(height: 24),
            ElevatedButton(
              onPressed: _savePromotion,
              style: ElevatedButton.styleFrom(
                backgroundColor: Color(0xFF00BCD0),
                padding: EdgeInsets.symmetric(vertical: 16),
              ),
              child: Text(
                'Modifier la promotion',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
