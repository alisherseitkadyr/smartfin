import '../entities/user.dart';

abstract class AuthRepository {
  /// Returns the currently logged-in user, or null if not logged in.
  Future<User?> getCurrentUser();

  Future<User> loginWithEmail({
    required String email,
    required String password,
  });

  Future<User> registerWithEmail({
    required String name,
    required String email,
    required String password,
  });

  Future<User> loginWithGoogle();

  Future<void> logout();
}