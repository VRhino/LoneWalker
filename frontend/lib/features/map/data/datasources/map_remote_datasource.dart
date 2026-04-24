import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/map_models.dart';

class MapRemoteDataSource {
  final ApiClient apiClient;

  MapRemoteDataSource({required this.apiClient});

  Future<ExplorationStatsModel> registerExploration({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.explorationRegister,
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'accuracy_meters': accuracy,
          'speed_kmh': speed,
          'timestamp': DateTime.now().toIso8601String(),
        },
      );

      return ExplorationStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<ExplorationStatsModel> getExplorationProgress() async {
    try {
      final response = await apiClient.get(ApiEndpoints.explorationProgress);
      return ExplorationStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> getMapWithFog({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.explorationMap,
        queryParameters: {
          'lat': latitude,
          'lng': longitude,
          'radius': radius.toInt(),
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<Map<String, dynamic>> getLastExploration() async {
    try {
      final response = await apiClient.get(ApiEndpoints.explorationLast);
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    final url = '${e.requestOptions.baseUrl}${e.requestOptions.path}';
    final status = e.response?.statusCode;
    final body = e.response?.data;

    debugPrint('[MapDS] $status $url | type=${e.type.name} | body=$body');

    switch (e.type) {
      case DioExceptionType.connectionError:
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return Exception('Cannot reach server at $url — check backend is running and API_BASE_URL is correct');
      default:
        break;
    }

    switch (status) {
      case 400:
        final rawMsg = body is Map ? body['message'] : null;
        final msg = rawMsg is List
            ? rawMsg.join(', ')
            : rawMsg as String?;
        return Exception('[400] ${msg ?? 'Invalid exploration data'} ($url)');
      case 401:
        final serverMsg = body is Map ? body['message'] : null;
        return Exception('[401] ${serverMsg ?? 'Unauthorized'} — token may be missing or expired ($url)');
      case 403:
        return Exception('[403] Forbidden ($url)');
      case 404:
        return Exception('[404] Endpoint not found ($url)');
      case 500:
        return Exception('[500] Internal server error ($url)');
      default:
        return Exception('[${status ?? 'ERR'}] ${e.message ?? 'Unknown error'} ($url)');
    }
  }
}
