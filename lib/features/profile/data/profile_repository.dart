import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';

class ProfileRepository {
  final Dio _dio = DioClient().dio;

  // POST /user/suggestions
  Future<ApiResponse<bool>> submitSuggestion(String message) async {
    try {
      final response = await _dio.post(
        '/user/suggestions',
        data: {'message': message},
      );

      // If successful (Status 200/201)
      return ApiResponse<bool>(
        success: response.data['success'] ?? true,
        message: response.data['message'] ?? 'Feedback sent successfully',
        data: true,
      );
    } on DioException catch (e) {
      // Handle Error (e.g., Rate Limit / One per day)
      String userMessage = "Failed to send feedback";

      if (e.response?.data != null && e.response!.data is Map) {
        // Extract the backend message: "You can submit only one suggestion per day"
        userMessage = e.response!.data['message'] ?? userMessage;
      }

      return ApiResponse(success: false, message: userMessage);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
  Future<ApiResponse<String>> getUserName() async {
    try {
      final response = await _dio.get('/user/profile/fetchName');

      return ApiResponse<String>.fromJson(
        response.data,
            (data) {
          // JSON: { "data": { "name": "test" } }
          if (data is Map<String, dynamic>) {
            return data['name']?.toString() ?? 'User';
          }
          return 'User';
        },
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // PATCH /user/name (Assuming endpoint based on context)
  Future<ApiResponse<bool>> updateUserName(String newName) async {
    try {
      final response = await _dio.patch(
        '/user/profile/name', // Use your specific PATCH path here
        data: {
          "name": newName
        },
      );

      return ApiResponse<bool>(
        success: response.data['success'] ?? true,
        message: response.data['message'] ?? 'Name updated successfully',
        data: true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
  Future<ApiResponse<bool>> updatePassword(String currentPassword, String newPassword) async {
    try {
      final response = await _dio.patch(
        '/user/password',
        data: {
          "currentPassword": currentPassword,
          "newPassword": newPassword,
        },
      );

      return ApiResponse<bool>(
        success: response.data['success'] ?? true,
        message: response.data['message'] ?? 'Password updated successfully',
        data: true,
      );
    } on DioException catch (e) {
      String errorMessage = "Failed to update password";
      if (e.response?.data != null && e.response!.data is Map) {
        errorMessage = e.response!.data['message'] ?? errorMessage;
      }
      return ApiResponse(success: false, message: errorMessage);
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}