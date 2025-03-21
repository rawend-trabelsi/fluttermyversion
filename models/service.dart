class Service {
  final int id;
  final String titre;
  final String description;
  final double prix;
  final String duree;
  String? imageName;
  String imageUrl;
  double? discountedPrice;
  String? promotion;
  Service({
    required this.id,
    required this.titre,
    required this.description,
    required this.prix,
    required this.duree,
    this.imageName,
    required this.imageUrl,
    this.discountedPrice,
    this.promotion,
  });

  factory Service.fromJson(Map<String, dynamic> json) {
    return Service(
      id: json['id'] ?? 0,
      titre: json['titre'] ?? '',
      description: json['description'] ?? '',
      prix: (json['prix'] ?? 0.0).toDouble(),
      duree: json['duree'] ?? '',
      imageName: json['imageName'],
      imageUrl: json['image'] ?? '',
      discountedPrice: json['discountedPrice']?.toDouble(), // Nouveau champ
      promotion: json['promotion'], // Nouveau champ
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'description': description,
      'prix': prix,
      'duree': duree,
      'imageName': imageName,
      'image': imageUrl,
      'discountedPrice': discountedPrice,
      'promotion': promotion,
    };
  }
}