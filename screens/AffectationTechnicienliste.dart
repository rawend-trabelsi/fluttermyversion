import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:projectlavage/models/AffectationTechnicien.dart';

import '../services/AffectationService.dart';
import '../services/auth_service.dart';
import 'admin_screen.dart';

class AffectationTechnicienliste extends StatefulWidget {
  @override
  _AffectationTechnicienlisteState createState() =>
      _AffectationTechnicienlisteState();
}

class _AffectationTechnicienlisteState
    extends State<AffectationTechnicienliste> {
  late Future<List<AffectationTechnicien>> futureAffectations;
  List<AffectationTechnicien> allAffectations = [];
  List<AffectationTechnicien> filteredAffectations = [];
  DateTime? selectedDate;

  @override
  void initState() {
    super.initState();
    futureAffectations = AffectationService().fetchAffectations();
    futureAffectations.then((affectations) {
      setState(() {
        allAffectations = affectations;
        filteredAffectations = affectations;
      });
    });
  }

  String formatDateTime(DateTime? dateTime) {
    return dateTime == null
        ? 'Non spécifié'
        : DateFormat('yyyy-MM-dd HH:mm').format(dateTime);
  }

  void _filterByDate() {
    setState(() {
      filteredAffectations = selectedDate != null
          ? allAffectations
              .where((affectation) =>
                  affectation.dateDebutReservation != null &&
                  affectation.dateDebutReservation!.year ==
                      selectedDate!.year &&
                  affectation.dateDebutReservation!.month ==
                      selectedDate!.month &&
                  affectation.dateDebutReservation!.day == selectedDate!.day)
              .toList()
          : allAffectations;
    });
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? DateTime.now(),
      firstDate: DateTime(2000),
      lastDate: DateTime(2101),
      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            primaryColor: Color(0xFF00BCD0),
            hintColor: Color(0xFF00BCD0),
            colorScheme: ColorScheme.light(primary: Color(0xFF00BCD0)),
            buttonTheme: ButtonThemeData(textTheme: ButtonTextTheme.primary),
          ),
          child: child!,
        );
      },
    );
    if (picked != null && picked != selectedDate) {
      setState(() {
        selectedDate = picked;
      });
      _filterByDate();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Planification des Techniciens'),
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
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  selectedDate == null
                      ? 'Sélectionne une date'
                      : 'Date sélectionnée: ${DateFormat('yyyy-MM-dd').format(selectedDate!)}',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
                ),
                OutlinedButton.icon(
                  onPressed: () => _selectDate(context),
                  icon: Icon(Icons.calendar_today, color: Color(0xFF00BCD0)),
                  label: Text("Choisir",
                      style: TextStyle(color: Color(0xFF00BCD0))),
                  style: OutlinedButton.styleFrom(
                    side: BorderSide(color: Color(0xFF00BCD0)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: FutureBuilder<List<AffectationTechnicien>>(
              future: futureAffectations,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(
                      child:
                          CircularProgressIndicator(color: Color(0xFF00BCD0)));
                } else if (snapshot.hasError) {
                  return Center(child: Text('Erreur: ${snapshot.error}'));
                } else if (snapshot.hasData) {
                  if (filteredAffectations.isEmpty) {
                    return _buildNoDataView();
                  }
                  return ListView.builder(
                    itemCount: filteredAffectations.length,
                    itemBuilder: (context, index) {
                      final affectation = filteredAffectations[index];
                      return Card(
                        margin:
                            EdgeInsets.symmetric(vertical: 8, horizontal: 12),
                        elevation: 4,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                          side: BorderSide(color: Color(0xFF00BCD0), width: 2),
                        ),
                        child: ListTile(
                          contentPadding: EdgeInsets.symmetric(
                              horizontal: 16, vertical: 12),
                          title: Row(
                            children: [
                              Icon(Icons.email,
                                  color: Color(0xFF00BCD0)), // Icon for email
                              SizedBox(width: 8),
                              Text(
                                affectation.emailTechnicien,
                                style: TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                            ],
                          ),
                          subtitle: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: 4),
                              Row(
                                children: [
                                  Icon(Icons.date_range,
                                      color: Color(
                                          0xFF00BCD0)), // Icon for start date
                                  SizedBox(width: 4),
                                  Text(
                                    'Début: ${formatDateTime(affectation.dateDebutReservation)}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Icon(Icons.timer,
                                      color: Color(
                                          0xFF00BCD0)), // Icon for end time
                                  SizedBox(width: 4),
                                  Text(
                                    'Fin: ${formatDateTime(affectation.dateFinReservation)}',
                                    style: TextStyle(
                                        fontSize: 14, color: Colors.black87),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          trailing: Icon(Icons.arrow_forward_ios,
                              color: Color(0xFF00BCD0)),
                          onTap: () {
                            // Action lors du clic sur un élément
                          },
                        ),
                      );
                    },
                  );
                } else {
                  return _buildNoDataView();
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNoDataView() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Icon(Icons.calendar_today, size: 60, color: Colors.grey),
          SizedBox(height: 16),
          Text(
            'Aucune planification pour cette date',
            style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: Colors.black54),
          ),
        ],
      ),
    );
  }
}
