import 'package:google_sign_in/google_sign_in.dart';

import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../datasources/auth_local_datasource.dart';
import '../datasources/auth_remote_datasource.dart';

class AuthRepositoryImpl implements AuthRepository {
  final AuthRemoteDataSource _remote;
  final AuthLocalDataSource _local;
  final GoogleSignIn _googleSignIn;

  const AuthRepositoryImpl({
    required AuthRemoteDataSource remote,
    required AuthLocalDataSource local,
    required GoogleSignIn googleSignIn,
  })  : _remote = remote,
        _local = local,
        _googleSignIn = googleSignIn;

  @override
  Future<User?> getCurrentUser() async {
    final token = await _local.getAccessToken();
    if (token == null) return null;
    try {
      final model = await _remote.getMe(token);
      return model.toEntity();
    } catch (_) {
      await _local.clearTokens();
      return null;
    }
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
    await _local.saveAccessToken(result.token);
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
    await _local.saveAccessToken(result.token);
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
    await _local.saveAccessToken(result.token);
    return result.user.toEntity();
  }

  @override
  Future<void> logout() async {
    await Future.wait([
      _local.clearTokens(),
      _googleSignIn.signOut(),
    ]);
  }
}