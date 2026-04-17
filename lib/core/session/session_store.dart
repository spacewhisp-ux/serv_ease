import 'dart:convert';

import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class SessionStore {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userJsonKey = 'user_json';

  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  Future<String?> readAccessToken() => _storage.read(key: _accessTokenKey);

  Future<String?> readRefreshToken() => _storage.read(key: _refreshTokenKey);

  Future<Map<String, dynamic>?> readUser() async {
    final raw = await _storage.read(key: _userJsonKey);
    if (raw == null) {
      return null;
    }

    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
      _storage.write(key: _userJsonKey, value: jsonEncode(user)),
    ]);
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _accessTokenKey, value: accessToken),
      _storage.write(key: _refreshTokenKey, value: refreshToken),
    ]);
  }

  Future<void> updateUser(Map<String, dynamic> user) {
    return _storage.write(key: _userJsonKey, value: jsonEncode(user));
  }

  Future<void> clear() {
    return Future.wait([
      _storage.delete(key: _accessTokenKey),
      _storage.delete(key: _refreshTokenKey),
      _storage.delete(key: _userJsonKey),
    ]);
  }
}
