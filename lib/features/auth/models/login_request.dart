class LoginRequest {
  final String phone;
  final String password;

  LoginRequest({required this.phone, required this.password});

  // Convert to JSON for the API
  Map<String, dynamic> toJson() {
    return {
      'phone': phone,
      'password': password,
    };
  }
}