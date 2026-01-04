import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/login_request.dart';
import '../models/signup_request.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;
  final StorageService _storage = StorageService();

  Future<ApiResponse<String>> login(LoginRequest request) async {
    try {
      final response = await _dio.post('/auth/login', data: request.toJson());

      return ApiResponse<String>.fromJson(
        response.data,
            (json) {
          String token = '';
          if (json is Map<String, dynamic>) {
            token = json['token'] ?? json['accessToken'] ?? '';
          } else {
            token = json.toString();
          }

          // FIX: Sanitize the token.
          // If backend sends "Bearer eyJ...", remove "Bearer " so we store ONLY the code.
          if (token.startsWith("Bearer ")) {
            token = token.substring(7);
          }

          if (token.isNotEmpty) {
            // Await is crucial here!
            _storage.saveToken(token).then((_) {
              print("✅ Login Success: Token sanitized and saving initiated.");
            });
          }

          return token;
        },
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }


  // POST /auth/register
  Future<ApiResponse<String>> register(SignUpRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: request.toJson(),
      );

      return ApiResponse<String>.fromJson(
        response.data,
            (json) {
          if (json is Map<String, dynamic>) {
            return json['token'] ?? json['accessToken'] ?? '';
          }
          return json as String;
        },
      );
    } on DioException catch (e) {
      // Apply same safety check for Register
      String errorMessage = "Registration failed";
      if (e.response != null && e.response?.data != null) {
        if (e.response!.data is Map<String, dynamic>) {
          errorMessage = e.response!.data['message'] ?? e.message;
        } else {
          errorMessage = e.response!.data.toString();
        }
      }
      return ApiResponse(success: false, message: errorMessage);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}