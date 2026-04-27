import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/medal_model.dart';

class MedalsRemoteDataSource {
  final ApiClient apiClient;

  MedalsRemoteDataSource({required this.apiClient});

  Future<List<MedalModel>> getAllMedals() async {
    try {
      final response = await apiClient.get(ApiEndpoints.medals);
      return (response.data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(MedalModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final status = e.response?.statusCode;
    debugPrint('[MedalsDS] $status ${e.requestOptions.path}');
    return Exception('[${status ?? 'ERR'}] ${e.message ?? 'Medals error'}');
  }
}
