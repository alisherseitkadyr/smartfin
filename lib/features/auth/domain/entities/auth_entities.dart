import 'package:equatable/equatable.dart';

class User extends Equatable {
  final String id;
  final String email;
  final String name;

  const User({
    required this.id,
    required this.email,
    required this.name,
  });

  @override
  List<Object?> get props => [id, email, name];
}

class AuthState extends Equatable {
  final bool isAuthenticated;
  final User? user;
  final String? error;

  const AuthState({
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  @override
  List<Object?> get props => [isAuthenticated, user, error];
}
