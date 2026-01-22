import 'package:dio/dio.dart';

class ApiErrorHandler {
  static String getMessage(Object error) {
    if (error is DioException) {
      switch (error.type) {
        case DioExceptionType.cancel:
          return "Request to server was cancelled";
        case DioExceptionType.connectionTimeout:
          return "Connection timed out";
        case DioExceptionType.receiveTimeout:
          return "Receive timeout in connection with server";
        case DioExceptionType.sendTimeout:
          return "Send timeout in connection with server";
        case DioExceptionType.connectionError:
          return "No internet connection";
        case DioExceptionType.badCertificate:
          return "Server certificate error";
        case DioExceptionType.badResponse:
          return _handleBadResponse(error.response);
        case DioExceptionType.unknown:
          return "Unexpected error occurred";
      }
    } else {
      return "An unexpected error occurred";
    }
  }

  // Helper to extract the specific message sent by your Spring Boot Backend
  static String _handleBadResponse(Response? response) {
    try {
      if (response != null && response.data != null) {
        final data = response.data;

        // Check if data is a Map and has a 'message' key
        // Your backend format: { "success": false, "message": "ACTUAL ERROR", ... }
        if (data is Map<String, dynamic>) {
          if (data.containsKey('message') && data['message'] != null) {
            return data['message'].toString();
          }
          if (data.containsKey('error') && data['error'] != null) {
            return data['error'].toString();
          }
        }
      }
      return "Server returned error: ${response?.statusCode}";
    } catch (e) {
      return "Server error";
    }
  }
}