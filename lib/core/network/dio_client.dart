import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../storage/secure_storage.dart';
import '../../main.dart'; // Import main.dart to access 'navigatorKey'
import '../../features/auth/presentation/login_screen.dart'; // Import Login Screen

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio _dio;

  // Update with your actual IP
  final String _baseUrl = 'http://10.0.2.2:8080/api/v1';

  DioClient._internal() {
    BaseOptions options = BaseOptions(
      baseUrl: _baseUrl,
      connectTimeout: const Duration(seconds: 10),
      receiveTimeout: const Duration(seconds: 10),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
    );

    _dio = Dio(options);

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await StorageService().getToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },

        onResponse: (response, handler) {
          return handler.next(response);
        },

        // --- HERE IS THE FIX ---
        onError: (DioException e, handler) async {
          // Check if the error code is 401 (Unauthorized) / 403 (Forbidden)
          if (e.response?.statusCode == 401 || e.response?.statusCode == 403) {
            print('--> [AUTH] Token Expired. Logging out...');

            // 1. Delete the invalid token
            await StorageService().deleteToken();

            // 2. Redirect to Login Screen using the Global Key
            // "pushNamedAndRemoveUntil" removes all previous screens (Home, etc) from history
            navigatorKey.currentState?.pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
                  (route) => false, // Remove all previous routes
            );
          }

          return handler.next(e);
        },
      ),
    );
  }

  Dio get dio => _dio;
}