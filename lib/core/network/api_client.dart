import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;

import '../config/app_config.dart';
import '../session/session_store.dart';
import 'api_exception.dart';

class ApiClient {
  ApiClient({required SessionStore sessionStore}) : _sessionStore = sessionStore;

  static const _publicPaths = {
    '/auth/login',
    '/auth/register',
    '/auth/refresh',
  };

  static const _requestTimeout = Duration(seconds: 25);

  final http.Client _client = http.Client();
  final SessionStore _sessionStore;
  String? _accessToken;
  Future<void>? _refreshFuture;

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    return _send(
      'GET',
      path,
      queryParameters: queryParameters,
    );
  }

  Future<Map<String, dynamic>> post(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    return _send('POST', path, data: data);
  }

  Future<Map<String, dynamic>> patch(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    return _send('PATCH', path, data: data);
  }

  Future<Map<String, dynamic>> delete(
    String path, {
    Map<String, dynamic>? data,
  }) async {
    return _send('DELETE', path, data: data);
  }

  void setAccessToken(String? token) {
    _accessToken = token;
  }

  Future<void> clearSession() async {
    _accessToken = null;
    await _sessionStore.clear();
  }

  Future<Map<String, dynamic>> _send(
    String method,
    String path, {
    Map<String, dynamic>? data,
    Map<String, dynamic>? queryParameters,
    bool retried = false,
  }) async {
    final normalizedPath = _normalizePath(path);
    final uri = _buildUri(normalizedPath, queryParameters);
    final headers = <String, String>{'Content-Type': 'application/json'};

    if (!_publicPaths.contains(normalizedPath)) {
      final token = _accessToken ?? await _sessionStore.readAccessToken();
      if (token != null && token.isNotEmpty) {
        headers['Authorization'] = 'Bearer $token';
        _accessToken = token;
      }
    }

    if (kDebugMode) {
      debugPrint('API $method $uri');
    }

    try {
      final response = await _executeRequest(
        method,
        uri,
        headers: headers,
        data: data,
      );
      final responseData = _decodeResponseBody(response.body);
      final isUnauthorized = response.statusCode == 401;
      final canRefresh =
          isUnauthorized &&
          !_publicPaths.contains(normalizedPath) &&
          !retried;

      if (canRefresh) {
        try {
          await _refreshSession();
          return _send(
            method,
            path,
            data: data,
            queryParameters: queryParameters,
            retried: true,
          );
        } catch (_) {
          await clearSession();
        }
      }

      if (response.statusCode >= 400) {
        throw _mapResponseError(
          method: method,
          uri: uri,
          response: response,
          responseData: responseData,
        );
      }

      if (responseData is! Map<String, dynamic>) {
        throw const ApiException('Invalid response format');
      }

      return _unwrap(responseData);
    } on ApiException {
      rethrow;
    } on TimeoutException catch (error) {
      if (kDebugMode) {
        _debugLogError(
          method: method,
          uri: uri,
          errorType: 'TimeoutException',
          message: 'Request timed out',
          error: error,
        );
      }
      throw const ApiException('Request timed out');
    } on SocketException catch (error) {
      if (kDebugMode) {
        _debugLogError(
          method: method,
          uri: uri,
          errorType: 'SocketException',
          message: error.message,
          error: error,
        );
      }
      throw ApiException(error.message);
    } on http.ClientException catch (error) {
      if (kDebugMode) {
        _debugLogError(
          method: method,
          uri: uri,
          errorType: 'ClientException',
          message: error.message,
          error: error,
        );
      }
      throw ApiException(error.message);
    } on FormatException catch (error) {
      if (kDebugMode) {
        _debugLogError(
          method: method,
          uri: uri,
          errorType: 'FormatException',
          message: 'Invalid response format',
          error: error,
        );
      }
      throw const ApiException('Invalid response format');
    } catch (error) {
      if (kDebugMode) {
        _debugLogError(
          method: method,
          uri: uri,
          errorType: error.runtimeType.toString(),
          message: error.toString(),
          error: error,
        );
      }
      throw ApiException(error.toString());
    }
  }

  Future<http.Response> _executeRequest(
    String method,
    Uri uri, {
    required Map<String, String> headers,
    Map<String, dynamic>? data,
  }) async {
    final request = http.Request(method, uri);
    request.headers.addAll(headers);

    if (data != null) {
      request.body = jsonEncode(data);
    }

    final streamed = await _client.send(request).timeout(_requestTimeout);
    return http.Response.fromStream(streamed);
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

    final response = await _executeRequest(
      'POST',
      _buildUri(_normalizePath('/auth/refresh'), null),
      headers: {'Content-Type': 'application/json'},
      data: {'refreshToken': refreshToken},
    );
    final responseData = _decodeResponseBody(response.body);

    if (response.statusCode >= 400) {
      throw _mapResponseError(
        method: 'POST',
        uri: _buildUri(_normalizePath('/auth/refresh'), null),
        response: response,
        responseData: responseData,
      );
    }

    if (responseData is! Map<String, dynamic>) {
      throw const ApiException('Invalid response format');
    }

    final data = _unwrap(responseData);
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
        _errorMessage(error),
        code: error is Map<String, dynamic> ? error['code'] as String? : null,
      );
    }

    final data = response['data'];
    if (data is Map<String, dynamic>) {
      return data;
    }

    return {'items': data};
  }

  ApiException _mapResponseError({
    required String method,
    required Uri uri,
    required http.Response response,
    required Object? responseData,
  }) {
    if (kDebugMode) {
      _debugLogError(
        method: method,
        uri: uri,
        errorType: 'HttpStatus',
        message: 'Request failed with status ${response.statusCode}',
        statusCode: response.statusCode,
        responseBody: responseData,
      );
    }

    if (responseData is Map<String, dynamic>) {
      final body = responseData['error'];
      if (body is Map<String, dynamic>) {
        return ApiException(
          _errorMessage(body),
          code: body['code'] as String?,
          statusCode: response.statusCode,
        );
      }
    }

    return ApiException(
      'Request failed',
      statusCode: response.statusCode,
    );
  }

  Object? _decodeResponseBody(String body) {
    if (body.isEmpty) {
      return null;
    }

    return jsonDecode(body);
  }

  String _errorMessage(Object? errorBody) {
    if (errorBody is Map<String, dynamic>) {
      final message = errorBody['message'];
      if (message is String && message.isNotEmpty) {
        return message;
      }
      if (message is List) {
        final messages = message
            .where((item) => item != null)
            .map((item) => item.toString())
            .toList();
        if (messages.isNotEmpty) {
          return messages.join(', ');
        }
      }
    }

    return 'Request failed';
  }

  void _debugLogError({
    required String method,
    required Uri uri,
    required String errorType,
    required String message,
    Object? error,
    int? statusCode,
    Object? responseBody,
  }) {
    debugPrint('API error $method $uri');
    debugPrint('HTTP type: $errorType');
    debugPrint('Message: $message');

    if (error != null) {
      debugPrint('Inner error: ${error.runtimeType}: $error');
    }

    if (statusCode != null) {
      debugPrint('Status: $statusCode');
    }

    if (responseBody != null) {
      debugPrint('Response: $responseBody');
    }
  }

  Uri _buildUri(String normalizedPath, Map<String, dynamic>? queryParameters) {
    return Uri.parse(AppConfig.apiBaseUrl).resolve(normalizedPath).replace(
      queryParameters: _normalizeQueryParameters(queryParameters),
    );
  }

  Map<String, dynamic>? _normalizeQueryParameters(
    Map<String, dynamic>? queryParameters,
  ) {
    if (queryParameters == null || queryParameters.isEmpty) {
      return null;
    }

    final normalized = <String, dynamic>{};
    queryParameters.forEach((key, value) {
      if (value == null) {
        return;
      }
      if (value is Iterable) {
        normalized[key] = value.map((item) => item.toString()).toList();
        return;
      }
      normalized[key] = value.toString();
    });

    return normalized.isEmpty ? null : normalized;
  }

  String _normalizePath(String path) {
    return path.startsWith('/') ? path.substring(1) : path;
  }
}
