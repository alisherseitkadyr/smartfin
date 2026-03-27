import 'package:dio/dio.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../models/user_model.dart';

abstract class AuthRemoteDataSource {
  Future<({UserModel user, String token})> loginWithEmail({
    required String email,
    required String password,
  });

  Future<({UserModel user, String token})> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<({UserModel user, String token})> loginWithGoogle({
    required String googleIdToken,
  });

  Future<UserModel> getMe(String accessToken);
}

class AuthRemoteDataSourceImpl implements AuthRemoteDataSource {
  final Dio _dio;
  final GoogleSignIn _googleSignIn;

  AuthRemoteDataSourceImpl({
    required Dio dio,
    required GoogleSignIn googleSignIn,
  })  : _dio = dio,
        _googleSignIn = googleSignIn;

  @override
  Future<({UserModel user, String token})> loginWithEmail({
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/login',
      data: {'email': email, 'password': password},
    );
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<({UserModel user, String token})> registerWithEmail({
    required String name,
    required String email,
    required String password,
  }) async {
    final response = await _dio.post(
      '/auth/register',
      data: {'name': name, 'email': email, 'password': password},
    );
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<({UserModel user, String token})> loginWithGoogle({
    required String googleIdToken,
  }) async {
    final response = await _dio.post(
      '/auth/google',
      data: {'id_token': googleIdToken},
    );
    return _parseAuthResponse(response.data as Map<String, dynamic>);
  }

  @override
  Future<UserModel> getMe(String accessToken) async {
    final response = await _dio.get(
      '/auth/me',
      options: Options(
        headers: {'Authorization': 'Bearer $accessToken'},
      ),
    );
    return UserModel.fromJson(response.data as Map<String, dynamic>);
  }

  // Helper — expects { "user": {...}, "token": "..." }
  ({UserModel user, String token}) _parseAuthResponse(
      Map<String, dynamic> data) {
    return (
      user: UserModel.fromJson(data['user'] as Map<String, dynamic>),
      token: data['token'] as String,
    );
  }
}