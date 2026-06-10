import '../repositories/profileRepo.dart';
import '../entities/userProfile.dart';
class GetProfileUseCase {
  // Implement the logic to get the user's profile
  final ProfileRepository _profileRepository;
  const GetProfileUseCase(this._profileRepository);
  Future<UserProfile> call() {
    return _profileRepository.getUserProfile();
  }
}

class UpdateProfileUseCase {
  // Implement the logic to update the user's profile
  final ProfileRepository _profileRepository;
  const UpdateProfileUseCase(this._profileRepository);
  Future<void> call(UserProfile updatedProfile) {
    return _profileRepository.updateUserProfile(updatedProfile);
  }
}

class ChangeUserPasswordUseCase {
  // Implement the logic to change the user's password
  final ProfileRepository _profileRepository;
  const ChangeUserPasswordUseCase(this._profileRepository);
  Future<void> call(String currentPassword, String newPassword, String refreshToken) {
    return _profileRepository.changeUserPassword(currentPassword, newPassword, refreshToken);
  }
}

class SetLanguageUseCase {
  // Implement the logic to set the user's language preference
  final ProfileRepository _profileRepository;
  const SetLanguageUseCase(this._profileRepository);
  Future<void> call(String language) {  
    return _profileRepository.setlanguage(language);
  } 
}

class SetThemeUseCase {
  // Implement the logic to set the user's theme preference
  final ProfileRepository _profileRepository;
  const SetThemeUseCase(this._profileRepository);
  Future<void> call(String theme) {
    return _profileRepository.setTheme(theme);
  }
}

class DeleteAccountUseCase {
  // Implement the logic to delete the user's account
  final ProfileRepository _profileRepository;
  const DeleteAccountUseCase(this._profileRepository);
  Future<void> call() {
    return _profileRepository.deleteUserAccount();
  }
}

class LogoutUseCase {
  // Implement the logic to log the user out
  final ProfileRepository _profileRepository;
  const LogoutUseCase(this._profileRepository);
  Future<void> call() {
    return _profileRepository.logout();
  }
}