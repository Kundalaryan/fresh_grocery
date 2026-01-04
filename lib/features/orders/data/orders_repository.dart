import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../models/order_model.dart';
import '../models/order_details_model.dart';

class OrdersRepository {
  final Dio _dio = DioClient().dio;

  // GET /orders/my
  Future<ApiResponse<List<OrderModel>>> getMyOrders() async {
    try {
      final response = await _dio.get('/orders/my');

      return ApiResponse<List<OrderModel>>.fromJson(
        response.data,
            (data) {
          final list = data as List;
          return list.map((e) => OrderModel.fromJson(e)).toList();
        },
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
  // GET /orders/{orderId}
  Future<ApiResponse<OrderDetailsModel>> getOrderDetails(int orderId) async {
    try {
      final response = await _dio.get('/orders/$orderId');

      return ApiResponse<OrderDetailsModel>.fromJson(
        response.data,
            (data) => OrderDetailsModel.fromJson(data as Map<String, dynamic>),
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
  // PATCH /orders/{orderId}/cancel
  Future<ApiResponse<bool>> cancelOrder(int orderId) async {
    try {
      final response = await _dio.patch('/orders/$orderId/cancel');

      // The API returns { "success": true, "message": "...", "data": null }
      return ApiResponse<bool>(
        success: response.data['success'] ?? false,
        message: response.data['message'] ?? '',
        data: true, // Just return true to indicate it worked
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
