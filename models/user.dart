class User {
  int? id;
  String username;
  String email;
  String phone;
  String role;
  String? verificationCode;

  User({
    this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
    this.verificationCode,
  });

  // Convertir de JSON à un objet User
  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      username: json['username'],
      email: json['email'],
      phone: json['phone'],
      role: json['role'],
      verificationCode: json['verificationCode'],
    );
  }

  // Convertir un objet User en JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
      'verificationCode': verificationCode,
    };
  }
}
