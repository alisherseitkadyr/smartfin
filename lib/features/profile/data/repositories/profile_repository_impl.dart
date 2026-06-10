import 'package:afine/features/profile/domain/entities/userProfile.dart';

import '../datasource/profile_remote_datasource.dart';
import '../../domain/repositories/profileRepo.dart';
import '../models/profile_model.dart';

class ProfileRepositoryImpl implements ProfileRepository {
  final ProfileRemoteDataSource _remoteDataSource;
  const ProfileRepositoryImpl({
    required ProfileRemoteDataSource remoteDataSource,
  }) : _remoteDataSource = remoteDataSource;

  @override
  Future<void> updateUserProfile(UserProfile userProfile) async {
    final modelProfile = ProfileModel(
      name: userProfile.name,
      email: userProfile.email,
      status: userProfile.status,
      xp: userProfile.xp,
      topicsCompleted: userProfile.topicsCompleted,
    );
    await _remoteDataSource.updateUserProfile(modelProfile);
  }

   @override
  Future<UserProfile> getUserProfile() async {
    final profileModel = await _remoteDataSource.fetchUserProfile();
    
    return _toEntity(profileModel);
  }

  @override
  Future<void> changeUserPassword(String currentPassword, String newPassword, String refreshToken) async {
    await _remoteDataSource.changeUserPassword(currentPassword, newPassword, refreshToken);
  }

  @override
  Future<void> setlanguage(String language) async {
    // Simulate a network call with a delay
    await Future.delayed(const Duration(seconds: 1));
    // Here you would normally make an API call to set the language
  }
  
  @override
  Future<void> setTheme(String theme) async {
    // Simulate a network call with a delay
    await Future.delayed(const Duration(seconds: 1));
    // Here you would normally make an API call to set the theme  
  }

  @override
  Future<void> deleteUserAccount() async {
    // Simulate a network call with a delay
    await Future.delayed(const Duration(seconds: 2));
    // Here you would normally make an API call to delete the user account
  }

  @override
  Future<void> logout() async {
    // Simulate a network call with a delay
    await Future.delayed(const Duration(seconds: 1));
    // Here you would normally make an API call to log the user out
  }

 
  UserProfile _toEntity(ProfileModel profileModel) {
    return UserProfile(
      name: profileModel.name,
      email: profileModel.email,
      status: profileModel.status,
      xp: profileModel.xp,
      topicsCompleted: profileModel.topicsCompleted,
    );
  }
}

