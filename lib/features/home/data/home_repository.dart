import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart'; // 1. Required for 'compute'
import '../../../core/network/dio_client.dart';
import '../../../core/network/api_response.dart';
import '../models/product_model.dart';

// 2. TOP-LEVEL FUNCTION (Must be outside the class)
// This function will run on a separate background thread (Isolate).
// It takes the raw JSON data and converts it into your Model list.
ApiResponse<List<ProductModel>> _parseProductsResponse(dynamic responseData) {
  return ApiResponse<List<ProductModel>>.fromJson(
    responseData,
        (data) {
      // The heavy work happens here (looping through list)
      final list = data as List;
      return list.map((e) => ProductModel.fromJson(e)).toList();
    },
  );
}

class HomeRepository {
  final Dio _dio = DioClient().dio;

  // GET /products?search=abc&category=dairy
  Future<ApiResponse<List<ProductModel>>> getProducts({
    String? search,
    String? category,
  }) async {
    try {
      // Build Query Parameters
      final Map<String, dynamic> queryParams = {};
      if (search != null && search.isNotEmpty) queryParams['search'] = search;
      if (category != null && category != 'All') queryParams['category'] = category;

      final response = await _dio.get(
        '/products',
        queryParameters: queryParams,
      );

      // 3. USE COMPUTE
      // Instead of parsing on the main thread, we send 'response.data'
      // to the background function '_parseProductsResponse'.
      return await compute(_parseProductsResponse, response.data);

    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
  Future<ApiResponse<String>> getUserAddress() async {
    try {
      final response = await _dio.get('/user/profile/fetchAddress');

      return ApiResponse<String>.fromJson(
        response.data,
            (data) {
          // The JSON is: { "data": { "address": "Bishna" } }
          if (data is Map<String, dynamic>) {
            // Extract the 'address' field safely
            return data['address']?.toString() ?? '';
          }
          return '';
        },
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }

  // PATCH /user/address
  // Update address
  Future<ApiResponse<bool>> updateAddress(String newAddress) async {
    try {
      final response = await _dio.patch(
        '/user/profile/address',
        data: {
          "address": newAddress // Matches your request body requirements
        },
      );

      return ApiResponse<bool>(
        success: response.data['success'] ?? true,
        message: response.data['message'] ?? 'Address updated successfully',
        data: true,
      );
    } catch (e) {
      return ApiResponse(success: false, message: e.toString());
    }
  }
}