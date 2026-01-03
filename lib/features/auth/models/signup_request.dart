class SignUpRequest {
  final String name;
  final String phone;
  final String password;
  final String address;

  SignUpRequest({
    required this.name,
    required this.phone,
    required this.password,
    required this.address,
  });

  Map<String, dynamic> toJson() {
    return {
      'name': name,
      'phone': phone,
      'password': password,
      'address': address,
    };
  }
}