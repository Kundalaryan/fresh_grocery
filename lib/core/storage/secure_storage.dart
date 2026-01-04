import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  // FIX: Explicitly set AndroidOptions to ensure data persists correctly
  final _storage = const FlutterSecureStorage(
    aOptions: AndroidOptions(
      encryptedSharedPreferences: true,
    ),
  );

  final String _tokenKey = 'jwt_token';

  Future<void> saveToken(String token) async {
    try {
      await _storage.write(key: _tokenKey, value: token);
      print("🔐 STORAGE: Token saved successfully."); // Debug
    } catch (e) {
      print("🔐 STORAGE ERROR: Could not save token -> $e");
    }
  }

  Future<String?> getToken() async {
    try {
      final token = await _storage.read(key: _tokenKey);
      return token;
    } catch (e) {
      print("🔐 STORAGE READ ERROR: $e");
      return null;
    }
  }

  Future<void> deleteToken() async {
    await _storage.delete(key: _tokenKey);
    print("🔐 STORAGE: Token deleted.");
  }
}