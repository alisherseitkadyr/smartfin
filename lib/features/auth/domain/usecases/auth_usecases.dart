import '../entities/user.dart';
import '../repositories/auth_repository.dart';

class GetCurrentUser {
  final AuthRepository _repo;
  GetCurrentUser(this._repo);
  Future<User?> call() => _repo.getCurrentUser();
}

class LoginWithEmail {
  final AuthRepository _repo;
  LoginWithEmail(this._repo);
  Future<User> call({required String email, required String password}) =>
      _repo.loginWithEmail(email: email, password: password);
}

class RegisterWithEmail {
  final AuthRepository _repo;
  RegisterWithEmail(this._repo);
  Future<User> call({
    required String name,
    required String email,
    required String password,
  }) =>
      _repo.registerWithEmail(name: name, email: email, password: password);
}

class LoginWithGoogle {
  final AuthRepository _repo;
  LoginWithGoogle(this._repo);
  Future<User> call() => _repo.loginWithGoogle();
}

class Logout {
  final AuthRepository _repo;
  Logout(this._repo);
  Future<void> call() => _repo.logout();
}