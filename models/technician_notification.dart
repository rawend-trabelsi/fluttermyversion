class TechnicianNotification {
  final int id;
  final String userEmail;
  final String message;
  final DateTime dateEnvoi;
  final bool isRead;

  TechnicianNotification({
    required this.id,
    required this.userEmail,
    required this.message,
    required this.dateEnvoi,
    required this.isRead,
  });

  // Conversion depuis JSON
  factory TechnicianNotification.fromJson(Map<String, dynamic> json) {
    return TechnicianNotification(
      id: json['id'],
      userEmail: json['userEmail'],
      message: json['message'],
      dateEnvoi: DateTime.parse(json['dateEnvoi']),
      isRead: json['read'], // Correspondance avec "read" de l'API
    );
  }

  // Conversion vers JSON (si nécessaire)
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'userEmail': userEmail,
      'message': message,
      'dateEnvoi': dateEnvoi.toIso8601String(),
      'read': isRead,
    };
  }
}
