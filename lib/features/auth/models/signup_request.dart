class SignUpRequest {
  final String name;
  final String phone;
  final String email; // 1. Add Email Field
  final String password;
  final String address;

  SignUpRequest({
    required this.name,
    required this.phone,
    required this.email, // 2. Add to Constructor
    required this.password,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'email': email, // 3. Add to JSON
      'password': password,
      'address': address,
    };
  }
}