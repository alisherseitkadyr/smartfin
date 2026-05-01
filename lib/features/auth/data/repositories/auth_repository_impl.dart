import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';
import '../models/user_model.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final GoogleSignIn _googleSignIn;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required GoogleSignIn googleSignIn,
  }) : _remote = remote,
       _local = local,
       _googleSignIn = googleSignIn;

  @override
  Future<User?> getCurrentUser() async {
    final token = await _local.getAccessToken();
    final refreshToken = await _local.getRefreshToken();
    if (token == null && refreshToken == null) return null;
    if (token == null && refreshToken != null) {
      try {
        final refreshed = await _remote.refresh(refreshToken: refreshToken);
        await _saveAuthResult(refreshed);
        return refreshed.user.toEntity();
      } catch (_) {
        await _local.clearTokens();
        return null;
      }
    }

    try {
      final model = await _remote.getMe(token!);
      return model.toEntity();
    } catch (_) {
      if (refreshToken == null) {
        await _local.clearTokens();
        return null;
      }

      try {
        final refreshed = await _remote.refresh(refreshToken: refreshToken);
        await _saveAuthResult(refreshed);
        return refreshed.user.toEntity();
      } catch (_) {
        await _local.clearTokens();
        return null;
      }
    }
  }

  Future<void> _saveAuthResult(
    ({UserModel user, String accessToken, String refreshToken}) result,
  ) async {
    await _local.saveTokens(
      accessToken: result.accessToken,
      refreshToken: result.refreshToken,
    );
    await _local.saveUser({
      'id': result.user.id,
      'email': result.user.email,
      'name': result.user.name,
    });
  }

  Future<void> _clearTokensAfterBestEffortLogout() async {
    final refreshToken = await _local.getRefreshToken();
    if (refreshToken != null && refreshToken.isNotEmpty) {
      try {
        await _remote.logout(refreshToken: refreshToken);
      } catch (_) {
        // Local sign-out should still succeed if the network/backend is down.
      }
    }
    await Future.wait([_local.clearTokens(), _googleSignIn.signOut()]);
  }

  @override
  Future<User> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final result = await _remote.loginWithEmail(
      email: email,
      password: password,
    );
    await _saveAuthResult(result);
    return result.user.toEntity();
  }

  @override
  Future<User> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final result = await _remote.registerWithEmail(
      name: name,
      email: email,
      password: password,
    );
    await _saveAuthResult(result);
    return result.user.toEntity();
  }

  @override
  Future<User> loginWithGoogle() async {
    final googleUser = await _googleSignIn.signIn();
    if (googleUser == null) throw Exception('Google sign-in cancelled');

    final googleAuth = await googleUser.authentication;
    final idToken = googleAuth.idToken;
    if (idToken == null) throw Exception('Failed to get Google ID token');

    final result = await _remote.loginWithGoogle(googleIdToken: idToken);
    await _saveAuthResult(result);
    return result.user.toEntity();
  }

  @override
  Future<void> logout() => _clearTokensAfterBestEffortLogout();
}
