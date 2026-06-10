import 'package:dio/dio.dart';

import '../models/profile_model.dart';

abstract class ProfileRemoteDataSource {
  Future<ProfileModel> fetchUserProfile();
  Future<void> updateUserProfile(ProfileModel updatedProfile);
  Future<void> changeUserPassword(String currentPassword, String newPassword, String refreshToken);
  Future<void> setLanguage(String language);
  Future<void> setTheme(String theme);
  Future<void> deleteUserAccount();
  Future<void> logout();
}


class ProfileRemoteDataSourceImpl implements ProfileRemoteDataSource {
  final Dio _dio;

  ProfileRemoteDataSourceImpl({required Dio dio}) : _dio = dio;

  @override
  Future<ProfileModel> fetchUserProfile() async {
    final response = await _dio.get('/profile/me');
    return ProfileModel.fromJson(response.data);
  }

  @override
  Future<void> updateUserProfile(ProfileModel updatedProfile) async {
    await _dio.patch('/auth/me/username', data: {
      'new_username': updatedProfile.name,
    });
  }

  @override
  Future<void> changeUserPassword(
    String currentPassword,
    String newPassword,
    String refreshToken,
  ) async {
    await _dio.patch('/auth/me/password', data: {
      'current_password': currentPassword,
      'new_password': newPassword,
      'refresh_token': refreshToken,
    });
  }

  @override
  Future<void> setLanguage(String language) async {
    await _dio.patch('/profile/settings', data: {'language_code': language});
  }

  @override
  Future<void> setTheme(String theme) async {
    await _dio.patch('/profile/settings', data: {'theme': theme});
  }

  @override
  Future<void> deleteUserAccount() async {
    await _dio.delete('/auth/me');
  }

  @override
  Future<void> logout() async {
    await _dio.post('/auth/logout');
  }

  
}