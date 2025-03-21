class SignUpRequest {
  String username;
  String password;
  String confirmPassword;
  String phone;
  String email;  // Ajout du champ email

  SignUpRequest({
    required this.username,
    required this.password,
    required this.confirmPassword,
    required this.phone,
    required this.email,  // Ajout du champ email dans le constructeur
  });

  Map<String, dynamic> toJson() {
    return {
      'username': username,
      'password': password,
      'confirmPassword': confirmPassword,
      'phone': phone,
      'email': email,  // Ajout de l'email dans la conversion en JSON
    };
  }
}

