import 'dart:convert';

import '../../../../core/services/safe_storage.dart';

abstract class AuthLocalDataSource {
  Future<String?> getAccessToken();
  Future<String?> getRefreshToken();
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  });
  Future<void> clearTokens();
  Future<Map<String, dynamic>?> getSavedUser();
  Future<void> saveUser(Map<String, dynamic> user);
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final SafeStorage _storage;

  static const _kAccessToken = 'access_token';
  static const _kRefreshToken = 'refresh_token';
  static const _kUser = 'saved_user';

  const AuthLocalDataSourceImpl(this._storage);

  @override
  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  @override
  Future<String?> getRefreshToken() => _storage.read(key: _kRefreshToken);

  @override
  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    await Future.wait([
      _storage.write(key: _kAccessToken, value: accessToken),
      _storage.write(key: _kRefreshToken, value: refreshToken),
    ]);
  }

  @override
  Future<void> clearTokens() => _storage.deleteAll();

  @override
  Future<Map<String, dynamic>?> getSavedUser() async {
    final raw = await _storage.read(key: _kUser);
    if (raw == null) return null;
    return jsonDecode(raw) as Map<String, dynamic>;
  }

  @override
  Future<void> saveUser(Map<String, dynamic> user) =>
      _storage.write(key: _kUser, value: jsonEncode(user));
}
