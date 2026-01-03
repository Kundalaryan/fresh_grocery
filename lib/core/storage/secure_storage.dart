import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  // Create a singleton instance
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final _storage = const FlutterSecureStorage();
  final String _tokenKey = 'jwt_token';

  // Save Token
  Future<void> saveToken(String token) async {
    await _storage.write(key: _tokenKey, value: token);
  }

  // Get Token
  Future<String?> getToken() async {
    return await _storage.read(key: _tokenKey);
  }

  // Delete Token (Logout)
  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
  }
}