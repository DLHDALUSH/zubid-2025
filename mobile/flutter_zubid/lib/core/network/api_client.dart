import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:pretty_dio_logger/pretty_dio_logger.dart';

import '../config/app_config.dart';
import '../services/storage_service.dart';
import '../utils/logger.dart';

final apiClientProvider = Provider<ApiClient>((ref) {
  return ApiClient();
});

class ApiClient {
  late final Dio _dio;
  late final CookieJar _cookieJar;

  ApiClient() {
    _dio = Dio();
    _cookieJar = CookieJar();
    _setupBaseOptions();
    _setupCookieManager();
    _setupInterceptors();
  }

  Dio get dio => _dio;
  CookieJar get cookieJar => _cookieJar;

  void _setupBaseOptions() {
    _dio.options = BaseOptions(
      baseUrl: AppConfig.apiUrl,
      connectTimeout: Duration(milliseconds: AppConfig.connectTimeoutMs),
      receiveTimeout: Duration(milliseconds: AppConfig.receiveTimeoutMs),
      sendTimeout: Duration(milliseconds: AppConfig.apiTimeout),
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
      },
      // Important for session-based auth
      extra: {'withCredentials': true},
    );
  }

  void _setupCookieManager() {
    // Add cookie manager for session-based authentication
    _dio.interceptors.add(CookieManager(_cookieJar));
  }

  /// Clear all cookies (useful for logout)
  Future<void> clearCookies() async {
    await _cookieJar.deleteAll();
  }

  void _setupInterceptors() {
    // Request/Response Logging
    if (AppConfig.enableLogging) {
      _dio.interceptors.add(
        PrettyDioLogger(
          requestHeader: true,
          requestBody: true,
          responseBody: true,
          responseHeader: false,
          error: true,
          compact: true,
          maxWidth: 90,
        ),
      );
    }

    // Auth Token Interceptor
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          // Add auth token to requests
          final token = await StorageService.getAuthToken();
          if (token != null) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          
          AppLogger.network(
            options.method,
            '${options.baseUrl}${options.path}',
          );
          
          handler.next(options);
        },
        onResponse: (response, handler) {
          AppLogger.network(
            response.requestOptions.method,
            '${response.requestOptions.baseUrl}${response.requestOptions.path}',
            statusCode: response.statusCode,
          );
          handler.next(response);
        },
        onError: (error, handler) async {
          AppLogger.apiError(
            '${error.requestOptions.baseUrl}${error.requestOptions.path}',
            error.response?.statusCode ?? 0,
            error.message ?? 'Unknown error',
          );

          // Handle DNS/Connection errors with retry
          if (error.type == DioExceptionType.connectionError ||
              error.type == DioExceptionType.unknown ||
              (error.message?.contains('Failed host lookup') ?? false)) {

            AppLogger.warning('Network connectivity issue detected, attempting retry...');

            // Wait a bit before retry
            await Future.delayed(const Duration(seconds: 2));

            try {
              final response = await _dio.fetch(error.requestOptions);
              handler.resolve(response);
              return;
            } catch (retryError) {
              AppLogger.error('Retry failed', error: retryError);
              // Continue with original error handling
            }
          }

          // Handle token refresh for 401 errors
          if (error.response?.statusCode == 401) {
            final refreshed = await _handleTokenRefresh();
            if (refreshed) {
              // Retry the original request
              final options = error.requestOptions;
              final token = await StorageService.getAuthToken();
              if (token != null) {
                options.headers['Authorization'] = 'Bearer $token';
              }

              try {
                final response = await _dio.fetch(options);
                handler.resolve(response);
                return;
              } catch (e) {
                // If retry fails, continue with original error
              }
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  Future<bool> _handleTokenRefresh() async {
    try {
      final refreshToken = await StorageService.getRefreshToken();
      if (refreshToken == null) {
        AppLogger.warning('No refresh token available');
        return false;
      }

      AppLogger.info('Attempting token refresh...');

      // Note: Backend doesn't have a dedicated refresh-token endpoint yet
      // For now, return false to force re-login when token expires
      // TODO: Implement refresh-token endpoint in backend
      AppLogger.warning('Token refresh not implemented in backend - user will need to re-login');
      return false;
    } catch (e) {
      AppLogger.error('Token refresh error', error: e);
      return false;
    }
  }

  // HTTP Methods
  Future<Response> get(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.get(
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
  }) async {
    return await _dio.post(
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
  }) async {
    return await _dio.put(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  Future<Response> patch(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return await _dio.patch(
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
  }) async {
    return await _dio.delete(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // File Upload
  Future<Response> uploadFile(
    String path,
    String filePath, {
    String fieldName = 'file',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    final formData = FormData.fromMap({
      fieldName: await MultipartFile.fromFile(filePath),
      ...?data,
    });

    return await _dio.post(
      path,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
      onSendProgress: onSendProgress,
    );
  }

  // Multiple File Upload
  Future<Response> uploadFiles(
    String path,
    List<String> filePaths, {
    String fieldName = 'files',
    Map<String, dynamic>? data,
    ProgressCallback? onSendProgress,
  }) async {
    final files = <MultipartFile>[];
    for (final filePath in filePaths) {
      files.add(await MultipartFile.fromFile(filePath));
    }

    final formData = FormData.fromMap({
      fieldName: files,
      ...?data,
    });

    return await _dio.post(
      path,
      data: formData,
      options: Options(
        headers: {'Content-Type': 'multipart/form-data'},
      ),
      onSendProgress: onSendProgress,
    );
  }

  // Download File
  Future<Response> downloadFile(
    String path,
    String savePath, {
    ProgressCallback? onReceiveProgress,
    Map<String, dynamic>? queryParameters,
  }) async {
    return await _dio.download(
      path,
      savePath,
      queryParameters: queryParameters,
      onReceiveProgress: onReceiveProgress,
    );
  }

  // Cancel Token
  CancelToken createCancelToken() {
    return CancelToken();
  }

  // Update base URL (for environment switching)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl;
    AppLogger.info('API base URL updated to: $newBaseUrl');
  }

  // Add custom header
  void addHeader(String key, String value) {
    _dio.options.headers[key] = value;
  }

  // Remove header
  void removeHeader(String key) {
    _dio.options.headers.remove(key);
  }

  // Clear all custom headers
  void clearHeaders() {
    _dio.options.headers.clear();
    _dio.options.headers.addAll({
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    });
  }
}
