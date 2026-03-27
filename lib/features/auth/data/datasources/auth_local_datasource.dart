import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

abstract class AuthLocalDataSource {
  Future<String?> getAccessToken();
  Future<void> saveAccessToken(String token);
  Future<void> clearTokens();
  Future<Map<String, dynamic>?> getSavedUser();       // ← NEW
  Future<void> saveUser(Map<String, dynamic> user);   // ← NEW
}

class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  final FlutterSecureStorage _storage;

  static const _kAccessToken = 'access_token';
  static const _kUser = 'saved_user';               // ← NEW

  const AuthLocalDataSourceImpl(this._storage);

  @override
  Future<String?> getAccessToken() => _storage.read(key: _kAccessToken);

  @override
  Future<void> saveAccessToken(String token) =>
      _storage.write(key: _kAccessToken, value: token);

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