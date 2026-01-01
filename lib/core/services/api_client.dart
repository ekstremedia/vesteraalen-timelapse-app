import 'package:dio/dio.dart';
import 'package:vesteraalen_timelapse/core/config/env_config.dart';

/// HTTP client for API requests using Dio.
class ApiClient {
  late final Dio _dio;

  ApiClient() {
    _dio = Dio(
      BaseOptions(
        baseUrl: EnvConfig.apiBaseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 30),
        headers: {
          'Accept': 'application/json',
          'Content-Type': 'application/json',
        },
      ),
    );

    // Add logging interceptor for debug builds
    _dio.interceptors.add(
      LogInterceptor(
        requestBody: false,
        responseBody: false,
        error: true,
        logPrint: (object) {
          // Only log in debug mode
          assert(() {
            // ignore: avoid_print
            print(object);
            return true;
          }());
        },
      ),
    );
  }

  /// GET request
  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// POST request
  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// PUT request
  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// DELETE request
  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) async {
    return _dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  /// Get the underlying Dio instance for advanced usage.
  Dio get dio => _dio;
}

/// Exception thrown when an API request fails.
class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic data;

  ApiException({required this.message, this.statusCode, this.data});

  factory ApiException.fromDioException(DioException e) {
    String message;
    int? statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        message = 'Connection timeout. Please check your internet connection.';
        break;
      case DioExceptionType.connectionError:
        message = 'No internet connection.';
        break;
      case DioExceptionType.badResponse:
        statusCode = e.response?.statusCode;
        message =
            _extractErrorMessage(e.response) ??
            'Server error (${e.response?.statusCode})';
        break;
      case DioExceptionType.cancel:
        message = 'Request was cancelled.';
        break;
      default:
        message = 'An unexpected error occurred.';
    }

    return ApiException(
      message: message,
      statusCode: statusCode,
      data: e.response?.data,
    );
  }

  static String? _extractErrorMessage(Response? response) {
    if (response?.data is Map) {
      final data = response!.data as Map;
      return data['message'] as String? ?? data['error'] as String?;
    }
    return null;
  }

  @override
  String toString() => 'ApiException: $message (status: $statusCode)';
}
