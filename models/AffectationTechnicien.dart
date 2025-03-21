import 'package:intl/intl.dart';

class AffectationTechnicien {
  final int? id;
  final DateTime? dateDebutReservation;
  final DateTime? dateFinReservation;
  final String emailTechnicien;

  AffectationTechnicien({
    this.id,
    this.dateDebutReservation,
    this.dateFinReservation,
    required this.emailTechnicien,
  });

  factory AffectationTechnicien.fromJson(Map<String, dynamic> json) {
    print('Parsing Affectation: $json'); // Debugging

    // Function to parse date with a specific format
    DateTime? parseDate(String? dateStr) {
      if (dateStr == null) return null;
      try {
        print('Raw Date String: $dateStr'); // Debugging
        return DateFormat("yyyy-MM-dd HH:mm").parse(dateStr);
      } catch (e) {
        print('Error parsing date: $dateStr');
        return null;
      }
    }

    return AffectationTechnicien(
      id: json['id'],
      dateDebutReservation: parseDate(json['dateDebutReservation']),
      dateFinReservation: parseDate(json['dateFinReservation']),
      emailTechnicien: json['Email Technicien'],
    );
  }
}
