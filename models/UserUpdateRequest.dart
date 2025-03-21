class UserUpdateRequest {
  final String id;
  final String username;
  final String email;
  final String phone;
  final String role;

  UserUpdateRequest({
    required this.id,
    required this.username,
    required this.email,
    required this.phone,
    required this.role,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'role': role,
    };
  }
}


