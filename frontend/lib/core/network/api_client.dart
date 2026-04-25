import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';
import '../../config/app_config.dart';
import '../constants/api_endpoints.dart';
import '../constants/storage_keys.dart';
import 'token_manager.dart';

class ApiClient {
  late final Dio _dio;
  final TokenManager _tokenManager;

  ApiClient({TokenManager? tokenManager})
      : _tokenManager = tokenManager ?? TokenManager() {
    _dio = Dio(
      BaseOptions(
        baseUrl: AppConfig.apiBaseUrl,
        connectTimeout: AppConfig.apiTimeout,
        receiveTimeout: AppConfig.apiTimeout,
        contentType: Headers.jsonContentType,
      ),
    );

    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          final token = _tokenManager.accessToken;
          debugPrint(
              '[ApiClient] → ${options.method} ${options.path} | token=${token != null ? "present" : "NULL (not authenticated)"}');
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final isRefreshRequest =
              error.requestOptions.path.contains(ApiEndpoints.authRefresh);

          if (error.response?.statusCode == 401 && !isRefreshRequest) {
            try {
              final refreshToken = _tokenManager.refreshToken;
              if (refreshToken != null) {
                final refreshResponse = await _dio.post(
                  ApiEndpoints.authRefresh,
                  data: {StorageKeys.refreshToken: refreshToken},
                );

                final newToken =
                    refreshResponse.data[ApiResponseKeys.accessToken] as String;
                await _tokenManager.saveAccessToken(newToken);

                final orig = error.requestOptions;
                return handler.resolve(
                  await _dio.request(
                    orig.path,
                    data: orig.data,
                    queryParameters: orig.queryParameters,
                    options: Options(
                      method: orig.method,
                      headers: {
                        ...orig.headers,
                        'Authorization': 'Bearer $newToken',
                      },
                      contentType: orig.contentType,
                      responseType: orig.responseType,
                    ),
                  ),
                );
              }
            } catch (e) {
              debugPrint('[ApiClient] Token refresh failed: $e');
            }
          }
          handler.next(error);
        },
      ),
    );

    if (kDebugMode) {
      _dio.interceptors.add(LogInterceptor(
        requestBody: true,
        responseBody: true,
        requestHeader: true,
        logPrint: (o) => debugPrint('[Dio] $o'),
      ));
    }
  }

  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return _dio.get(path, queryParameters: queryParameters, options: options);
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

  // Delegate token operations to TokenManager
  Future<void> saveTokens(String accessToken, String refreshToken) =>
      _tokenManager.saveTokens(accessToken, refreshToken);

  String? getToken() => _tokenManager.accessToken;

  Future<void> logout() => _tokenManager.clearTokens();

  bool isAuthenticated() => _tokenManager.isAuthenticated;

  Future<void> saveUserData(Map<String, dynamic> json) =>
      _tokenManager.saveUserData(json);

  Map<String, dynamic>? getUserData() => _tokenManager.getUserData();

  Future<void> clearUserData() => _tokenManager.clearUserData();
}
