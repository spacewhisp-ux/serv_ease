import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class SessionStore {
  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userJsonKey = 'user_json';
  static const _preferredLocaleCodeKey = 'preferred_locale_code';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  Future<String?> readAccessToken() async {
    final preferences = await _preferences;
    return preferences.getString(_accessTokenKey);
  }

  Future<String?> readRefreshToken() async {
    final preferences = await _preferences;
    return preferences.getString(_refreshTokenKey);
  }

  Future<String?> readPreferredLocaleCode() async {
    final preferences = await _preferences;
    return preferences.getString(_preferredLocaleCodeKey);
  }

  Future<Map<String, dynamic>?> readUser() async {
    final preferences = await _preferences;
    final raw = preferences.getString(_userJsonKey);
    if (raw == null) {
      return null;
    }

    return jsonDecode(raw) as Map<String, dynamic>;
  }

  Future<void> savePreferredLocaleCode(String? code) async {
    final preferences = await _preferences;
    if (code == null) {
      await preferences.remove(_preferredLocaleCodeKey);
      return;
    }

    await preferences.setString(_preferredLocaleCodeKey, code);
  }

  Future<void> saveSession({
    required String accessToken,
    required String refreshToken,
    required Map<String, dynamic> user,
  }) async {
    final preferences = await _preferences;
    await Future.wait([
      preferences.setString(_accessTokenKey, accessToken),
      preferences.setString(_refreshTokenKey, refreshToken),
      preferences.setString(_userJsonKey, jsonEncode(user)),
    ]);
  }

  Future<void> updateTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    final preferences = await _preferences;
    await Future.wait([
      preferences.setString(_accessTokenKey, accessToken),
      preferences.setString(_refreshTokenKey, refreshToken),
    ]);
  }

  Future<void> updateUser(Map<String, dynamic> user) async {
    final preferences = await _preferences;
    await preferences.setString(_userJsonKey, jsonEncode(user));
  }

  Future<void> clear() async {
    final preferences = await _preferences;
    await Future.wait([
      preferences.remove(_accessTokenKey),
      preferences.remove(_refreshTokenKey),
      preferences.remove(_userJsonKey),
    ]);
  }
}
