import 'package:dio/dio.dart';
import 'package:get_storage/get_storage.dart';
import '../config/app_config.dart';

class ApiClient {
  late Dio _dio;
  final _storage = GetStorage();
  static const String _tokenKey = 'access_token';
  static const String _refreshTokenKey = 'refresh_token';

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        contentType: Headers.jsonContentType,
      ),
    );

    // Add interceptor for auth token
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = _storage.read(_tokenKey);
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          return handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            // Try to refresh token
            try {
              final refreshToken = _storage.read(_refreshTokenKey);
              if (refreshToken != null) {
                final response = await _dio.post(
                  '/auth/refresh',
                  data: {'refresh_token': refreshToken},
                );

                final newToken = response.data['access_token'];
                await saveToken(newToken);

                // Retry original request
                final options = error.requestOptions;
                options.headers['Authorization'] = 'Bearer $newToken';
                return handler.resolve(await _dio.request(
                  options.path,
                  options: options,
                ));
              }
            } catch (e) {
              // Logout user
              await logout();
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> post(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.post(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> put(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> delete(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<void> saveToken(String token) async {
    await _storage.write(_tokenKey, token);
  }

  Future<void> saveTokens(String accessToken, String refreshToken) async {
    await _storage.write(_tokenKey, accessToken);
    await _storage.write(_refreshTokenKey, refreshToken);
  }

  String? getToken() {
    return _storage.read(_tokenKey);
  }

  Future<void> logout() async {
    await _storage.remove(_tokenKey);
    await _storage.remove(_refreshTokenKey);
  }

  bool isAuthenticated() {
    return _storage.read(_tokenKey) != null;
  }
}
