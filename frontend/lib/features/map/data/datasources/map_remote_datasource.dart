import 'package:dio/dio.dart';
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
    switch (e.response?.statusCode) {
      case 400:
        final message = e.response?.data['message'] as String?;
        return Exception(message ?? 'Invalid exploration data');
      case 401:
        return Exception('Unauthorized');
      default:
        return Exception(e.message ?? 'An error occurred');
    }
  }
}
