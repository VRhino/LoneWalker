import 'package:dio/dio.dart';
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
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          if (error.response?.statusCode == 401) {
            try {
              final refreshToken = _tokenManager.refreshToken;
              if (refreshToken != null) {
                final response = await _dio.post(
                  ApiEndpoints.authRefresh,
                  data: {StorageKeys.refreshToken: refreshToken},
                );

                final newToken =
                    response.data[ApiResponseKeys.accessToken] as String;
                await _tokenManager.saveAccessToken(newToken);

                final requestOptions = error.requestOptions;
                requestOptions.headers['Authorization'] = 'Bearer $newToken';
                final retryOptions = Options(
                  method: requestOptions.method,
                  headers: requestOptions.headers,
                  contentType: requestOptions.contentType,
                  responseType: requestOptions.responseType,
                );
                return handler.resolve(
                  await _dio.request(requestOptions.path,
                      options: retryOptions),
                );
              }
            } catch (_) {
              await _tokenManager.clearTokens();
            }
          }
          handler.next(error);
        },
      ),
    );
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
}
