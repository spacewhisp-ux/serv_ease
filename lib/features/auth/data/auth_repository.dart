import '../../../core/network/api_client.dart';
import '../../../core/session/session_store.dart';

class AuthRepository {
  AuthRepository({
    required ApiClient apiClient,
    required SessionStore sessionStore,
  }) : _apiClient = apiClient,
       _sessionStore = sessionStore;

  final ApiClient _apiClient;
  final SessionStore _sessionStore;

  Future<Map<String, dynamic>> login({
    required String account,
    required String password,
  }) async {
    final response = await _apiClient.post(
      '/auth/login',
      data: {
        'account': account,
        'password': password,
        'deviceName': 'flutter-app',
      },
    );
    await _persistAuthResponse(response);
    return response['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> register({
    String? email,
    String? phone,
    required String password,
    required String displayName,
  }) async {
    final response = await _apiClient.post(
      '/auth/register',
      data: {
        if (email != null && email.isNotEmpty) 'email': email,
        if (phone != null && phone.isNotEmpty) 'phone': phone,
        'password': password,
        'displayName': displayName,
        'deviceName': 'flutter-app',
      },
    );
    await _persistAuthResponse(response);
    return response['user'] as Map<String, dynamic>;
  }

  Future<Map<String, dynamic>> fetchCurrentUser() async {
    final response = await _apiClient.get('/users/me');
    final user = Map<String, dynamic>.from(response);
    await _sessionStore.updateUser(user);
    return user;
  }

  Future<void> logout() async {
    final refreshToken = await _sessionStore.readRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _apiClient.post(
          '/auth/logout',
          data: {'refreshToken': refreshToken},
        );
      } catch (_) {
        // Keep local cleanup as the source of truth.
      }
    }

    await clearSession();
  }

  Future<void> clearSession() async {
    await _apiClient.clearSession();
  }

  Future<void> _persistAuthResponse(Map<String, dynamic> response) async {
    final accessToken = response['accessToken'] as String;
    final refreshToken = response['refreshToken'] as String;
    final user = response['user'] as Map<String, dynamic>;
    _apiClient.setAccessToken(accessToken);
    await _sessionStore.saveSession(
      accessToken: accessToken,
      refreshToken: refreshToken,
      user: user,
    );
  }
}
