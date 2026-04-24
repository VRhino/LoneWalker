import 'package:dio/dio.dart';
import '../../../../core/constants/api_endpoints.dart';
import '../../../../core/constants/storage_keys.dart';
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
        ApiEndpoints.authRegister,
        data: {
          'username': username,
          'email': email,
          'password': password,
          'passwordConfirm': passwordConfirm,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data[ApiResponseKeys.user]);
      final tokens = data[ApiResponseKeys.tokens] as Map<String, dynamic>;

      return (
        user: user,
        accessToken: tokens[ApiResponseKeys.accessToken] as String,
        refreshToken: tokens[ApiResponseKeys.refreshToken] as String,
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
        ApiEndpoints.authLogin,
        data: {
          'email': email,
          'password': password,
        },
      );

      final data = response.data as Map<String, dynamic>;
      final user = UserModel.fromJson(data[ApiResponseKeys.user]);
      final tokens = data[ApiResponseKeys.tokens] as Map<String, dynamic>;

      return (
        user: user,
        accessToken: tokens[ApiResponseKeys.accessToken] as String,
        refreshToken: tokens[ApiResponseKeys.refreshToken] as String,
      );
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  Future<void> logout() async {
    try {
      await apiClient.post(ApiEndpoints.authLogout);
      await apiClient.logout();
    } on DioException catch (e) {
      throw _handleDioException(e);
    }
  }

  /// Returns true if the token is valid, false if both access and refresh
  /// tokens are expired (server returned 401 after auto-refresh attempt).
  /// Throws on network errors so callers can distinguish auth failure from
  /// connectivity issues.
  Future<bool> verifyToken() async {
    try {
      await apiClient.get(ApiEndpoints.authVerify);
      return true;
    } on DioException catch (e) {
      if (e.response?.statusCode == 401) return false;
      throw _handleDioException(e);
    }
  }

  Exception _handleDioException(DioException e) {
    switch (e.response?.statusCode) {
      case 401:
        return Exception('Invalid email or password');
      case 409:
        return Exception('Email or username already exists');
      case 400:
        final rawMessage = e.response?.data['message'];
        final String? message = rawMessage is List<dynamic>
            ? rawMessage.join(', ')
            : rawMessage as String?;
        return Exception(message ?? 'Invalid input');
      default:
        return Exception(e.message ?? 'An error occurred');
    }
  }
}
