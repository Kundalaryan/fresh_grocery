import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import '../storage/secure_storage.dart';
import '../../main.dart';
import '../../features/auth/presentation/login_screen.dart';

class DioClient {
  static final DioClient _instance = DioClient._internal();
  factory DioClient() => _instance;

  late Dio _dio;

  // Use 10.0.2.2 for Android Emulator
  final String _baseUrl = 'http://192.168.29.57:8080/api/';

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
        // 1. REQUEST: Attach Token
        onRequest: (options, handler) async {
          final token = await StorageService().getToken();
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
            // Print last 5 chars to confirm it's sending
            final suffix = token.length > 5 ? token.substring(token.length - 5) : token;
          }
          return handler.next(options);
        },

        // 2. RESPONSE: Check for Hidden Errors
        onResponse: (response, handler) {
          // DEBUG PRINT: See exactly what the server sends back

          // Check for "Soft" 200 Errors
          if (response.data is Map<String, dynamic>) {
            final data = response.data as Map<String, dynamic>;
            if (data['success'] == false) {
              final msg = data['message'].toString().toLowerCase();
              if (_isAuthError(msg)) {
                print("--> 🚨 Soft Auth Error detected in 200 OK. Logging out.");
                _forceLogout();
                return; // Stop here
              }
            }
          }
          return handler.next(response);
        },

        // 3. ERROR: Check for 401, 403, and 500 (JWT Exceptions)
        onError: (DioException e, handler) async {

          final int status = e.response?.statusCode ?? 0;

          // Convert body to lowercase string to search for keywords
          // e.response?.data is usually a Map, so toString() makes it "{success: false, message: ...}"
          final String body = e.response?.data.toString().toLowerCase() ?? '';

          // CONDITION 1: Standard Auth Codes
          if (status == 401 || status == 403) {
            _forceLogout();
            return handler.next(e);
          }

          // CONDITION 2: Backend returns 400 for Auth Issues (YOUR SPECIFIC CASE)
          if (status == 400) {
            // Check for specific keywords found in your logs
            if (body.contains('access denied') ||
                body.contains('expired') ||
                body.contains('token')) {
              _forceLogout();
              return handler.next(e);
            }
          }

          // CONDITION 3: Spring Boot 500 (ExpiredJwtException)
          if (status == 500 && (body.contains('jwt') || body.contains('expired'))) {
            _forceLogout();
            return handler.next(e);
          }

          return handler.next(e);
        },
      ),
    );
  }

  bool _isAuthError(String msg) {
    return msg.contains('expired') ||
        msg.contains('unauthorized') ||
        msg.contains('invalid token') ||
        msg.contains('forbidden');
  }

  void _forceLogout() async {
    // Prevent multiple triggers
    await StorageService().deleteToken();

    if (navigatorKey.currentState != null) {
      // Use addPostFrameCallback to ensure we aren't mid-render
      WidgetsBinding.instance.addPostFrameCallback((_) {
        navigatorKey.currentState!.pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => const LoginScreen()),
              (route) => false,
        );
      });
    }
  }

  Dio get dio => _dio;
}