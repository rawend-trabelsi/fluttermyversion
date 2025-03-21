class Avis {
  int? id;
  int etoile;
  String commentaire;
  String email;
  int serviceId;
  String titreService;

  Avis({
    this.id,
    required this.etoile,
    required this.commentaire,
    required this.email,
    required this.serviceId,
    required this.titreService,
  });

  factory Avis.fromJson(Map<String, dynamic> json) {
    return Avis(
      id: json['idavis'],
      etoile: json['etoile'] ?? 0, // Valeur par défaut pour les étoiles
      commentaire: json['commentaire'] ?? 'Pas de commentaire', // Valeur par défaut
      email: json['email'] ?? 'Email inconnu',
      serviceId: json['idservice'] ?? -1, // Id de service par défaut
      titreService: json['titreService'] ?? 'Service inconnu', // Valeur par défaut
    );
  }


  Map<String, dynamic> toJson() {
    return {
      "idavis": id,
      "etoile": etoile,
      "commentaire": commentaire,
      "email": email,
      "service": {
        "id": serviceId
      },
      "titreService": titreService,
    };
  }
}

