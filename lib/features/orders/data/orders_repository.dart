import 'dart:io';

import 'package:dio/dio.dart';
import 'package:path_provider/path_provider.dart';
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
  // GET /user/orders/{orderId}/reciept
  // Returns the String path where the file was saved
  Future<String?> downloadReceipt(int orderId) async {
    try {
      // 1. Get the directory to save the file
      // We use ApplicationDocumentsDirectory so we don't need complex permissions
      final Directory dir = await getApplicationDocumentsDirectory();
      final String savePath = '${dir.path}/receipt_$orderId.pdf';

      // 2. Download the file using Dio
      // We use the specific path you provided
      await _dio.download(
        '/user/orders/$orderId/receipt',
        savePath,
        onReceiveProgress: (received, total) {
          if (total != -1) {
            print("Downloading: ${(received / total * 100).toStringAsFixed(0)}%");
          }
        },
      );

      return savePath;
    } catch (e) {
      print("Download Error: $e");
      return null;
    }
  }
  Future<ApiResponse<bool>> reportIssue(int orderId, String issueType, String description) async {
    try {
      final response = await _dio.post(
        '/user/issues/$orderId', // Check if it is 'users' or 'user' in your backend
        data: {
          "issueType": issueType,
          "description": description
        },
      );

      return ApiResponse<bool>(
        success: response.data['success'] ?? true,
        message: response.data['message'] ?? 'Issue reported successfully',
        data: true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}
