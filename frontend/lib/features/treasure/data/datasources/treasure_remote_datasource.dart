import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/treasure_model.dart';

abstract class TreasureRemoteDataSource {
  Future<List<TreasureModel>> getNearby(
    double latitude,
    double longitude, {
    int radius,
  });

  Future<List<RadarTreasureModel>> getRadarData(
    double latitude,
    double longitude,
  );

  Future<TreasureModel> getTreasureById(String treasureId);

  Future<Map<String, dynamic>> claimTreasure(
    String treasureId,
    double latitude,
    double longitude,
    double accuracyMeters,
  );

  Future<List<TreasureWallOfFameModel>> getWallOfFame(String treasureId);

  Future<TreasureClaimsStatsModel> getClaimsStats();
}

class TreasureRemoteDataSourceImpl implements TreasureRemoteDataSource {
  final ApiClient apiClient;

  TreasureRemoteDataSourceImpl({required this.apiClient});

  @override
  Future<List<TreasureModel>> getNearby(
    double latitude,
    double longitude, {
    int radius = 5000,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.treasuresNearby,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((t) => TreasureModel.fromJson(t as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<RadarTreasureModel>> getRadarData(
    double latitude,
    double longitude,
  ) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.treasuresRadar,
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.data is List) {
        return (response.data as List)
            .map((t) => RadarTreasureModel.fromJson(t as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<TreasureModel> getTreasureById(String treasureId) async {
    try {
      final response = await apiClient.get(ApiEndpoints.treasureById(treasureId));
      return TreasureModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<Map<String, dynamic>> claimTreasure(
    String treasureId,
    double latitude,
    double longitude,
    double accuracyMeters,
  ) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.treasureClaim(treasureId),
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'accuracy_meters': accuracyMeters,
        },
      );

      return response.data as Map<String, dynamic>;
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<TreasureWallOfFameModel>> getWallOfFame(String treasureId) async {
    try {
      final response =
          await apiClient.get(ApiEndpoints.treasureWallOfFame(treasureId));

      if (response.data is List) {
        return (response.data as List)
            .map((t) => TreasureWallOfFameModel.fromJson(t as Map<String, dynamic>))
            .toList();
      }

      return [];
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<TreasureClaimsStatsModel> getClaimsStats() async {
    try {
      final response = await apiClient.get(ApiEndpoints.treasuresStatsClaims);
      return TreasureClaimsStatsModel.fromJson(
          response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.response?.statusCode) {
      case 400:
        final message = e.response?.data['message'] ?? 'Bad request';
        return Exception(message);
      case 404:
        return Exception('Treasure not found');
      default:
        if (e.type == DioExceptionType.connectionTimeout) {
          return Exception('Connection timeout');
        }
        if (e.type == DioExceptionType.unknown) {
          return Exception('Network error');
        }
        return Exception('Error: ${e.message}');
    }
  }
}
