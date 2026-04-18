import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/map_models.dart';

class MapRemoteDataSource {
  final ApiClient apiClient;

  MapRemoteDataSource({required this.apiClient});

  /// Register exploration point
  Future<ExplorationStatsModel> registerExploration({
    required double latitude,
    required double longitude,
    required double accuracy,
    required double speed,
  }) async {
    try {
      final response = await apiClient.post(
        '/exploration',
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

  /// Get exploration progress
  Future<ExplorationStatsModel> getExplorationProgress() async {
    try {
      final response = await apiClient.get('/exploration/progress');
      return ExplorationStatsModel.fromJson(response.data);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Get map with fog of war
  Future<Map<String, dynamic>> getMapWithFog({
    required double latitude,
    required double longitude,
    required double radius,
  }) async {
    try {
      final response = await apiClient.get(
        '/exploration/map',
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

  /// Get last exploration point
  Future<Map<String, dynamic>> getLastExploration() async {
    try {
      final response = await apiClient.get('/exploration/last');
      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    if (e.response?.statusCode == 400) {
      final message = e.response?.data['message'] as String?;
      return Exception(message ?? 'Invalid exploration data');
    } else if (e.response?.statusCode == 401) {
      return Exception('Unauthorized');
    } else {
      return Exception(e.message ?? 'An error occurred');
    }
  }
}
