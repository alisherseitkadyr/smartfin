import '../entities/user_profile.dart';

abstract class ProfileRepository {
  /// Fetches the user's profile information.
  Future<UserProfile> getUserProfile();

  /// Updates the user's profile information.
  Future<void> updateUserProfile(UserProfile updatedProfile);

  Future<void> changeUserPassword(String currentPassword, String newPassword, String refreshToken);

  Future<void> setlanguage(String language);
  Future<void> setTheme(String theme);

  Future<void> deleteUserAccount();
  Future<void> logout();
}
