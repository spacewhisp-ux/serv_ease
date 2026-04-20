import 'package:dio/dio.dart';
import 'package:flutter/foundation.dart';

import '../config/app_config.dart';
import '../session/session_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({required SessionStore sessionStore})
    : _sessionStore = sessionStore,
      _dio = Dio(
        BaseOptions(
          baseUrl: AppConfig.apiBaseUrl,
          connectTimeout: const Duration(seconds: 10),
          receiveTimeout: const Duration(seconds: 15),
          headers: {'Content-Type': 'application/json'},
        ),
      ) {
    _dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final normalizedPath = _normalizePath(options.path);
          options.path = normalizedPath;

          if (kDebugMode) {
            debugPrint('API ${options.method} ${options.uri}');
          }

          if (!_publicPaths.contains(normalizedPath)) {
            final token = _accessToken ?? await _sessionStore.readAccessToken();
            if (token != null && token.isNotEmpty) {
              options.headers['Authorization'] = 'Bearer $token';
              _accessToken = token;
            }
          }
          handler.next(options);
        },
        onError: (error, handler) async {
          final requestOptions = error.requestOptions;
          final normalizedPath = _normalizePath(requestOptions.path);
          final isUnauthorized = error.response?.statusCode == 401;
          final canRefresh =
              isUnauthorized &&
              !_publicPaths.contains(normalizedPath) &&
              requestOptions.extra['retried'] != true;

          if (canRefresh) {
            try {
              await _refreshSession();
              final cloned = await _retryRequest(requestOptions);
              handler.resolve(cloned);
              return;
            } catch (_) {
              await clearSession();
            }
          }

          handler.next(error);
        },
      ),
    );
  }

  static const _publicPaths = {
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
  };

  final Dio _dio;
  final SessionStore _sessionStore;
  String? _accessToken;
  Future<void>? _refreshFuture;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await _dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      return _unwrap(response.data);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.post<Map<String, dynamic>>(path, data: data);
      return _unwrap(response.data);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.patch<Map<String, dynamic>>(path, data: data);
      return _unwrap(response.data);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    try {
      final response = await _dio.delete<Map<String, dynamic>>(
        path,
        data: data,
      );
      return _unwrap(response.data);
    } on DioException catch (error) {
      throw _mapException(error);
    }
  }

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Future<void> clearSession() async {
    _accessToken = null;
    await _sessionStore.clear();
  }

  Future<Response<dynamic>> _retryRequest(RequestOptions requestOptions) async {
    final updated = requestOptions.copyWith(
      path: _normalizePath(requestOptions.path),
      headers: {
        ...requestOptions.headers,
        if (_accessToken != null) 'Authorization': 'Bearer $_accessToken',
      },
      extra: {...requestOptions.extra, 'retried': true},
    );

    return _dio.fetch(updated);
  }

  Future<void> _refreshSession() async {
    if (_refreshFuture != null) {
      return _refreshFuture;
    }

    final completer = _refreshTokensInternal();
    _refreshFuture = completer;

    try {
      await completer;
    } finally {
      _refreshFuture = null;
    }
  }

  Future<void> _refreshTokensInternal() async {
    final refreshToken = await _sessionStore.readRefreshToken();
    if (refreshToken == null || refreshToken.isEmpty) {
      throw const ApiException('Session expired');
    }

    final response = await _dio.post<Map<String, dynamic>>(
      '/auth/refresh',
      data: {'refreshToken': refreshToken},
    );
    final data = _unwrap(response.data);
    final accessToken = data['accessToken'] as String;
    final nextRefreshToken = data['refreshToken'] as String;
    _accessToken = accessToken;
    await _sessionStore.updateTokens(
      accessToken: accessToken,
      refreshToken: nextRefreshToken,
    );
  }

  Map<String, dynamic> _unwrap(Map<String, dynamic>? response) {
    if (response == null) {
      throw const ApiException('Empty response');
    }

    final success = response['success'];
    if (success == false) {
      final error = response['error'];
      throw ApiException(
        error is Map<String, dynamic>
            ? (error['message'] as String? ?? 'Request failed')
            : 'Request failed',
        code: error is Map<String, dynamic> ? error['code'] as String? : null,
      );
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    return {'items': data};
  }

  ApiException _mapException(DioException error) {
    final responseData = error.response?.data;
    if (responseData is Map<String, dynamic>) {
      final body = responseData['error'];
      if (body is Map<String, dynamic>) {
        return ApiException(
          body['message'] as String? ?? 'Request failed',
          code: body['code'] as String?,
          statusCode: error.response?.statusCode,
        );
      }
    }

    if (kDebugMode) {
      debugPrint(error.message);
    }

    return ApiException(
      error.message ?? 'Network request failed',
      statusCode: error.response?.statusCode,
    );
  }

  String _normalizePath(String path) {
    return path.startsWith('/') ? path.substring(1) : path;
  }
}
