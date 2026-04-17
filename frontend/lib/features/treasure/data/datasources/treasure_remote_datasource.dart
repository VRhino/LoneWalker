import 'package:dio/dio.dart';
import '../models/treasure_model.dart';

abstract class TreasureRemoteDataSource {
  Future<List<TreasureModel>> getNearby(
    double latitude,
    double longitude,
    {int radius = 5000},
  );

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
  final Dio _dio;

  TreasureRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<List<TreasureModel>> getNearby(
    double latitude,
    double longitude,
    {int radius = 5000},
  ) async {
    try {
      final response = await _dio.get(
        '/treasures/nearby',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
          'radius': radius,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
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
      final response = await _dio.get(
        '/treasures/radar',
        queryParameters: {
          'latitude': latitude,
          'longitude': longitude,
        },
      );

      if (response.statusCode == 200 && response.data is List) {
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
      final response = await _dio.get('/treasures/$treasureId');

      if (response.statusCode == 200) {
        return TreasureModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to fetch treasure');
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
      final response = await _dio.post(
        '/treasures/$treasureId/claim',
        data: {
          'latitude': latitude,
          'longitude': longitude,
          'accuracy_meters': accuracyMeters,
        },
      );

      if (response.statusCode == 200) {
        return response.data as Map<String, dynamic>;
      }

      throw Exception('Failed to claim treasure');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  @override
  Future<List<TreasureWallOfFameModel>> getWallOfFame(String treasureId) async {
    try {
      final response = await _dio.get('/treasures/$treasureId/wall-of-fame');

      if (response.statusCode == 200 && response.data is List) {
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
      final response = await _dio.get('/treasures/stats/claims');

      if (response.statusCode == 200) {
        return TreasureClaimsStatsModel.fromJson(response.data as Map<String, dynamic>);
      }

      throw Exception('Failed to fetch claims stats');
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    if (e.response?.statusCode == 404) {
      return Exception('Treasure not found');
    } else if (e.response?.statusCode == 400) {
      final message = e.response?.data['message'] ?? 'Bad request';
      return Exception(message);
    } else if (e.type == DioExceptionType.connectionTimeout) {
      return Exception('Connection timeout');
    } else if (e.type == DioExceptionType.unknown) {
      return Exception('Network error');
    }

    return Exception('Error: ${e.message}');
  }
}
