import 'package:dio/dio.dart';
import '../../../../core/network/api_client.dart';
import '../models/user_model.dart';

class AuthRemoteDataSource {
  final ApiClient apiClient;

  AuthRemoteDataSource({required this.apiClient});

  Future<({UserModel user, String accessToken, String refreshToken})> register({
    required String username,
    required String email,
    required String password,
    required String passwordConfirm,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/register',
        data: {
          'username': username,
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user']);
      final tokens = data['tokens'] as Map<String, dynamic>;

      return (
        user: user,
        accessToken: tokens['access_token'] as String,
        refreshToken: tokens['refresh_token'] as String,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<({UserModel user, String accessToken, String refreshToken})> login({
    required String email,
    required String password,
  }) async {
    try {
      final response = await apiClient.post(
        '/auth/login',
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data['user']);
      final tokens = data['tokens'] as Map<String, dynamic>;

      return (
        user: user,
        accessToken: tokens['access_token'] as String,
        refreshToken: tokens['refresh_token'] as String,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.post('/auth/logout');
      await apiClient.logout();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    if (e.response?.statusCode == 401) {
      return Exception('Invalid email or password');
    } else if (e.response?.statusCode == 409) {
      return Exception('Email or username already exists');
    } else if (e.response?.statusCode == 400) {
      final message = e.response?.data['message'] as String?;
      return Exception(message ?? 'Invalid input');
    } else {
      return Exception(e.message ?? 'An error occurred');
    }
  }
}
