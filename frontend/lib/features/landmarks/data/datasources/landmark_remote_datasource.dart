import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/network/api_client.dart';
import '../../domain/entities/landmark.dart';
import '../models/landmark_model.dart';

class LandmarkRemoteDataSource {
  final ApiClient apiClient;

  LandmarkRemoteDataSource({required this.apiClient});

  Future<Landmark> proposeLandmark({
    required String title,
    required String description,
    required LandmarkCategory category,
    required double latitude,
    required double longitude,
    required double userLatitude,
    required double userLongitude,
    String? photoUrl,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.landmarks,
        data: {
          'title': title,
          'description': description,
          'category': category.name.toUpperCase(),
          'latitude': latitude,
          'longitude': longitude,
          'user_latitude': userLatitude,
          'user_longitude': userLongitude,
          if (photoUrl != null) 'photo_url': photoUrl,
        },
      );
      return LandmarkModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Landmark>> getLandmarksForVoting() async {
    try {
      final response = await apiClient.get(ApiEndpoints.landmarks);
      return (response.data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(LandmarkModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<List<Landmark>> getApprovedLandmarks({
    required double lat,
    required double lng,
    double radius = 5000,
  }) async {
    try {
      final response = await apiClient.get(
        ApiEndpoints.landmarksApproved,
        queryParameters: {'lat': lat, 'lng': lng, 'radius': radius.toInt()},
      );
      return (response.data as List<dynamic>)
          .cast<Map<String, dynamic>>()
          .map(LandmarkModel.fromJson)
          .toList();
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Landmark> getLandmarkById(String id) async {
    try {
      final response = await apiClient.get(ApiEndpoints.landmarkById(id));
      return LandmarkModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Future<Landmark> voteLandmark({
    required String id,
    required int vote,
    required String comment,
  }) async {
    try {
      final response = await apiClient.post(
        ApiEndpoints.landmarkVotes(id),
        data: {'vote': vote, 'comment': comment},
      );
      return LandmarkModel.fromJson(response.data as Map<String, dynamic>);
    } on DioException catch (e) {
      throw _handleError(e);
    }
  }

  Exception _handleError(DioException e) {
    final status = e.response?.statusCode;
    final body = e.response?.data;
    debugPrint('[LandmarkDS] $status ${e.requestOptions.path}');
    final rawMsg = body is Map ? body['message'] : null;
    final msg = rawMsg is List ? rawMsg.join(', ') : rawMsg as String?;
    return Exception(
        '[${status ?? 'ERR'}] ${msg ?? e.message ?? 'Landmark error'}');
  }
}
