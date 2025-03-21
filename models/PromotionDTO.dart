import 'package:projectlavage/models/ServiceDTO.dart';

class PromotionDTO {
  final int id;
  final bool actif;
  final String typeReduction;
  final double valeurReduction;
  final DateTime dateDebut;
  final DateTime dateFin;
  final List<ServiceDTO>? servicesDTO;
  final String? codePromo;

  PromotionDTO({
    required this.id,
    required this.actif,
    required this.typeReduction,
    required this.valeurReduction,
    required DateTime dateDebut,
    required DateTime dateFin,
    this.servicesDTO,
    this.codePromo,
  })  : dateDebut =
            DateTime(dateDebut.year, dateDebut.month, dateDebut.day, 22, 59),
        dateFin = DateTime(dateFin.year, dateFin.month, dateFin.day, 22, 59);

  Map<String, dynamic> toJson() {
    return {
      "id": id,
      "actif": actif,
      "typeReduction": typeReduction,
      "valeurReduction": valeurReduction,
      "dateDebut": dateDebut.toIso8601String(),
      "dateFin": dateFin.toIso8601String(),
      "servicesDTO": servicesDTO?.map((service) => service.toJson()).toList(),
      'codePromo': codePromo,
    };
  }

  factory PromotionDTO.fromJson(Map<String, dynamic> json) {
    DateTime parsedDateDebut = DateTime.parse(json["dateDebut"]);
    DateTime parsedDateFin = DateTime.parse(json["dateFin"]);

    return PromotionDTO(
      id: json["id"] ?? 0,
      actif: json["actif"] ?? false,
      typeReduction: json["typeReduction"] ?? "POURCENTAGE",
      valeurReduction: json["valeurReduction"]?.toDouble() ?? 0.0,
      dateDebut: DateTime(parsedDateDebut.year, parsedDateDebut.month,
          parsedDateDebut.day, 22, 59),
      dateFin: DateTime(
          parsedDateFin.year, parsedDateFin.month, parsedDateFin.day, 22, 59),
      servicesDTO: (json["servicesDTO"] as List<dynamic>?)
          ?.map((service) => ServiceDTO.fromJson(service))
          .toList(),
      codePromo: json['codePromo'],
    );
  }
}
