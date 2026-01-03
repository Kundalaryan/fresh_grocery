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
      final response = await _dio.post(
        '/auth/login',
        data: request.toJson(),
      );

      // UPDATED PARSING LOGIC:
      // We accept that 'data' is a Map, and we extract 'token' from it.
      final apiResponse = ApiResponse<String>.fromJson(
        response.data,
            (json) {
          // 1. Cast the generic 'data' to a Map
          final map = json as Map<String, dynamic>;

          // 2. Return ONLY the token string
          return map['token'] as String;
        },
      );

      // If successful, save the token
      if (apiResponse.success && apiResponse.data != null) {
        await _storage.saveToken(apiResponse.data!);

        // Optional: If you need to save the role later, we can do that here too.
        // print("User Role: ${ (response.data['data'] as Map)['role'] }");
      }

      return apiResponse;
    } on DioException catch (e) {
      String errorMessage = "Something went wrong";
      if (e.response != null) {
        errorMessage = e.response?.data['message'] ?? e.message;
      }
      return ApiResponse(success: false, message: errorMessage);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
  Future<ApiResponse<String>> register(SignUpRequest request) async {
    try {
      final response = await _dio.post(
        '/auth/register', // Replace with your actual register endpoint
        data: request.toJson(),
      );

      // Assuming registration returns a token immediately (like login)
      // If it only returns "Success", change <String> to <void> or <bool>
      return ApiResponse<String>.fromJson(
        response.data,
            (json) => json as String,
      );
    } catch (e) {
      // Basic error handling wrapper
      return ApiResponse(success: false, message: e.toString());
    }
  }
}