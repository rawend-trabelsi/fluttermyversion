class Reservation {
  final int id;
  final String titreService;
  final double prix;
  final String localisation;
  final String dateReservation;
  final String dateCreation;
  final String email;
  final String phone;
  final String duree;
  final String modePaiement;
  final String? usernameTechnicien;
  final String? emailTechnicien;

  Reservation({
    required this.id,
    required this.titreService,
    required this.prix,
    required this.localisation,
    required this.dateReservation,
    required this.dateCreation,
    required this.email,
    required this.phone,
    required this.duree,
    required this.modePaiement,
    this.usernameTechnicien,
    this.emailTechnicien,
  });

  factory Reservation.fromJson(Map<String, dynamic> json) {
    return Reservation(
      id: json['id'],
      titreService: json['titreService'],
      prix: json['prix'],
      localisation: json['localisation'],
      dateReservation: json['dateReservation'],
      dateCreation: json['dateCreation'],
      email: json['email'],
      phone: json['phone'],
      duree: json['duree'],
      modePaiement: json['modePaiement'],
      // Vérifie si les valeurs sont nulles avant de les affecter
      usernameTechnicien: json['usernameTechnicien'] ?? null,
      emailTechnicien: json['emailTechnicien'] ?? null,
    );
  }
}
