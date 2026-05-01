import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

class AuthRemoteException implements Exception {
  final String message;
  const AuthRemoteException(this.message);

  @override
  String toString() => message;
}

abstract class AuthRemoteDataSource {
  Future<({UserModel user, String accessToken, String refreshToken})>
  loginWithEmail({required String email, required String password});

  Future<({UserModel user, String accessToken, String refreshToken})>
  registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<({UserModel user, String accessToken, String refreshToken})>
  loginWithGoogle({required String googleIdToken});

  Future<({UserModel user, String accessToken, String refreshToken})> refresh({
    required String refreshToken,
  });

  Future<void> logout({required String refreshToken});

  Future<UserModel> getMe(String accessToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;

  AuthRemoteDataSourceImpl({
    required Dio dio,
    required GoogleSignIn googleSignIn,
  }) : _dio = dio;

  @override
  Future<({UserModel user, String accessToken, String refreshToken})>
  loginWithEmail({required String email, required String password}) async {
    final response = await _send(
      () => _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      ),
    );
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<({UserModel user, String accessToken, String refreshToken})>
  registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _send(
      () => _dio.post(
        '/auth/register',
        data: {'username': name, 'email': email, 'password': password},
      ),
    );
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<({UserModel user, String accessToken, String refreshToken})>
  loginWithGoogle({required String googleIdToken}) async {
    final response = await _send(
      () => _dio.post('/auth/google', data: {'id_token': googleIdToken}),
    );
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<({UserModel user, String accessToken, String refreshToken})> refresh({
    required String refreshToken,
  }) async {
    final response = await _send(
      () => _dio.post('/auth/refresh', data: {'refresh_token': refreshToken}),
    );
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<void> logout({required String refreshToken}) async {
    await _send(
      () => _dio.post('/auth/logout', data: {'refresh_token': refreshToken}),
    );
  }

  @override
  Future<UserModel> getMe(String accessToken) async {
    final response = await _send(
      () => _dio.get(
        '/auth/me',
        options: Options(headers: {'Authorization': 'Bearer $accessToken'}),
      ),
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  Future<Response<dynamic>> _send(
    Future<Response<dynamic>> Function() request,
  ) async {
    try {
      return await request();
    } on DioException catch (e) {
      throw AuthRemoteException(_errorMessage(e));
    }
  }

  String _errorMessage(DioException error) {
    final data = error.response?.data;
    final code = data is Map<String, dynamic>
        ? ((data['error'] as Map<String, dynamic>?)?['code']) as String?
        : null;

    switch (code) {
      case 'INVALID_CREDENTIALS':
        return 'Invalid email or password';
      case 'EMAIL_ALREADY_EXISTS':
        return 'An account with this email already exists';
      case 'TOO_MANY_LOGIN_ATTEMPTS':
        return 'Too many login attempts. Try again later';
      case 'PASSWORD_TOO_SHORT':
        return 'Password is too short';
      case 'PASSWORD_MUST_HAVE_DIGIT':
        return 'Password must include at least one digit';
      case 'PASSWORD_INVALID_CHARS':
        return 'Password contains unsupported characters';
      case 'USERNAME_TOO_SHORT':
        return 'Name is too short';
      case 'USERNAME_TOO_LONG':
        return 'Name is too long';
      case 'INVALID_EMAIL_FORMAT':
        return 'Enter a valid email address';
      case 'INACTIVE_USER':
        return 'This account is inactive';
      case 'INVALID_GOOGLE_TOKEN':
        return 'Google sign-in failed';
      case 'GOOGLE_EMAIL_ALREADY_EXISTS':
        return 'This email is already registered with another sign-in method';
      case 'INVALID_REFRESH_TOKEN':
      case 'REFRESH_TOKEN_EXPIRED':
      case 'REFRESH_TOKEN_REVOKED':
      case 'INVALID_TOKEN':
      case 'MISSING_TOKEN':
        return 'Session expired. Please sign in again';
      default:
        return code ?? 'Could not connect to the server';
    }
  }

  // Helper expects backend auth response: { "user": {...}, "access_token": "...", "refresh_token": "..." }.
  ({UserModel user, String accessToken, String refreshToken})
  _parseAuthResponse(Map<String, dynamic> data) {
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      accessToken: data['access_token'] as String,
      refreshToken: data['refresh_token'] as String,
    );
  }
}
