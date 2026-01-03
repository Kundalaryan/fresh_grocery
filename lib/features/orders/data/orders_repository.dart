import 'package:dio/dio.dart';
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../models/order_model.dart';

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
}