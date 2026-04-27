import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../models/ranking_model.dart';

class RankingRemoteDataSource {
  final ApiClient apiClient;

  RankingRemoteDataSource({required this.apiClient});

  Future<List<RankingEntryModel>> getGlobalRanking({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.rankingGlobal,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data as Map<String, dynamic>;
      final entries = data['entries'] as List<dynamic>;
      return entries
          .cast<Map<String, dynamic>>()
          .map(RankingEntryModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<RankingEntryModel>> getWeeklyRanking({
    int page = 1,
    int limit = 50,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.rankingWeekly,
        queryParameters: {'page': page, 'limit': limit},
      );
      final data = response.data as Map<String, dynamic>;
      final entries = data['entries'] as List<dynamic>;
      return entries
          .cast<Map<String, dynamic>>()
          .map(RankingEntryModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<UserPositionModel> getUserPosition() async {
    try {
      final response = await apiClient.get(ApiEndpoints.rankingPosition);
      return UserPositionModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final status = e.response?.statusCode;
    debugPrint('[RankingDS] $status ${e.requestOptions.path}');
    return Exception('[${status ?? 'ERR'}] ${e.message ?? 'Ranking error'}');
  }
}
