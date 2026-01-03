import 'package:dio/dio.dart';
import 'package:uuid/uuid.dart'; // REQUIRED: Make sure this is imported
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../models/cart_item_model.dart';

class CartRepository {
  final Dio _dio = DioClient().dio;

  // 1. DEFINE UUID HERE (This was missing causing the error)
  final Uuid _uuid = const Uuid();

  // POST /orders
  Future<ApiResponse<int>> createOrder(List<CartItemModel> items) async {
    try {
      final requestBody = {
        "items": items.map((item) => {
          "productId": item.productId,
          "quantity": item.quantity
        }).toList(),
      };

      // 2. USE IT HERE
      final String idempotencyKey = _uuid.v4();

      final response = await _dio.post(
        '/orders',
        data: requestBody,
        options: Options(headers: {'Idempotency-Key': idempotencyKey}),
      );

      // HAPPY PATH (Status 200 OK)
      return ApiResponse<int>.fromJson(
        response.data,
            (data) {
          final map = data as Map<String, dynamic>;
          return map['id'] as int;
        },
      );

    } on DioException catch (e) {
      // ERROR PATH (Status 400, 404, 500)
      String userReadableMessage = "Something went wrong";

      if (e.response != null && e.response?.data != null) {
        try {
          final errorData = e.response!.data;

          if (errorData is Map<String, dynamic>) {
            // Extract "message" from backend response
            userReadableMessage = errorData['message'] ?? "Unknown Server Error";
          } else {
            userReadableMessage = errorData.toString();
          }
        } catch (_) {
          userReadableMessage = e.response?.statusMessage ?? "Server Error";
        }
      } else {
        userReadableMessage = "Connection failed. Please check your internet.";
      }

      return ApiResponse(success: false, message: userReadableMessage);

    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}