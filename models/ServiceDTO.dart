class ServiceDTO {
final int id;
final String titre;

ServiceDTO({required this.id, required this.titre});

factory ServiceDTO.fromJson(Map<String, dynamic> json) {
return ServiceDTO(
id: json['id'] ?? 0,
titre: json['titre'] ?? '',
);
}

Map<String, dynamic> toJson() {
return {
'id': id,
'titre': titre,
};
}
}