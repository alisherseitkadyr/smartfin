import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? avatarUrl;

  const User({
    required this.id,
    required this.email,
    this.name,
    this.avatarUrl,
  });

  @override
  List<Object?> get props => [id, email];
}

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthState extends Equatable {
  final AuthStatus status;
  final User? user;

  const AuthState({required this.status, this.user});

  const AuthState.unknown()
      : status = AuthStatus.unknown,
        user = null;

  const AuthState.authenticated(User u)
      : status = AuthStatus.authenticated,
        user = u;

  const AuthState.unauthenticated()
      : status = AuthStatus.unauthenticated,
        user = null;

  bool get isAuthenticated => status == AuthStatus.authenticated;

  @override
  List<Object?> get props => [status, user];
}