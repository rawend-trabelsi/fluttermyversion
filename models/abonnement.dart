class Abonnement {
  final int id;
  final String titre;
  final double prix;
  String? imageName; // Nom de l'image (peut être null)
  String imageUrl;   // URL de l'image (ne peut pas être null)

  Abonnement({
    required this.id,
    required this.titre,
    required this.prix,
    this.imageName,
    required this.imageUrl,
  });

  // Convertir en format JSON
  factory Abonnement.fromJson(Map<String, dynamic> json) {
    return Abonnement(
      id: json['id'] ?? 0, // Si 'id' est null, utiliser une valeur par défaut 0
      titre: json['titre'] ?? '', // Assurer que titre n'est jamais null
      prix: (json['prix'] ?? 0.0).toDouble(), // Assurer que prix n'est jamais null
      imageName: json['imageName'], // imageName peut être null
      imageUrl: json['image'] ?? '', // imageUrl ne peut pas être null
    );
  }

  // Convertir en format JSON pour l'envoi à l'API
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'titre': titre,
      'prix': prix,
      'imageName': imageName, // imageName peut être null
      'image': imageUrl, // imageUrl ne doit jamais être null
    };
  }
}
