import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../../../core/storage/secure_storage.dart';
import '../models/login_request.dart';
import '../models/signup_request.dart';

class AuthRepository {
  final Dio _dio = DioClient().dio;
  final StorageService _storage = StorageService();

  // POST /login
  Future<ApiResponse<String>> login(LoginRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      final apiResponse = ApiResponse<String>.fromJson(
        response.data,
            (json) {
          if (json is Map<String, dynamic>) {
            // Robust check for token key
            return json['token'] ?? json['accessToken'] ?? '';
          }
          return json.toString();
        },
      );

      if (apiResponse.success && apiResponse.data != null && apiResponse.data!.isNotEmpty) {
        await _storage.saveToken(apiResponse.data!);
      }

      return apiResponse;
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