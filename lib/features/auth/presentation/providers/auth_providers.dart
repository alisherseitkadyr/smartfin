import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

// ── Infrastructure ────────────────────────────────────────────

final dioProvider = Provider<Dio>((ref) {
  return Dio(BaseOptions(
    // Replace with your API base URL
    baseUrl: 'https://api.yourapp.com/v1',
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 10),
  ));
});

final googleSignInProvider = Provider<GoogleSignIn>(
  (_) => GoogleSignIn(scopes: ['email', 'profile']),
);

final secureStorageProvider = Provider<FlutterSecureStorage>(
  (_) => const FlutterSecureStorage(),
);

// ── Datasources ───────────────────────────────────────────────

final authLocalDataSourceProvider = Provider<AuthLocalDataSource>((ref) {
  return AuthLocalDataSourceImpl(ref.watch(secureStorageProvider));
});

final authRemoteDataSourceProvider = Provider<AuthRemoteDataSource>((ref) {
  return AuthRemoteDataSourceImpl(
    dio: ref.watch(dioProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

// ── Repository ────────────────────────────────────────────────

final authRepositoryProvider = Provider<AuthRepository>((ref) {
  return AuthRepositoryImpl(
    remote: ref.watch(authRemoteDataSourceProvider),


    local: ref.watch(authLocalDataSourceProvider),
    googleSignIn: ref.watch(googleSignInProvider),
  );
});

// ── Use cases ─────────────────────────────────────────────────

final getCurrentUserProvider = Provider(
  (ref) => GetCurrentUser(ref.watch(authRepositoryProvider)),
);
final loginWithEmailProvider = Provider(
  (ref) => LoginWithEmail(ref.watch(authRepositoryProvider)),
);
final registerWithEmailProvider = Provider(
  (ref) => RegisterWithEmail(ref.watch(authRepositoryProvider)),
);
final loginWithGoogleProvider = Provider(
  (ref) => LoginWithGoogle(ref.watch(authRepositoryProvider)),
);
final logoutProvider = Provider(
  (ref) => Logout(ref.watch(authRepositoryProvider)),
);

// ── Auth state notifier ───────────────────────────────────────
class AuthNotifier extends AsyncNotifier<AuthState> {
  // Grab the local datasource to read/write persisted user
  AuthLocalDataSource get _local =>
      ref.read(authLocalDataSourceProvider);

  @override
  Future<AuthState> build() async {
    // On app start: check if a user was saved from a previous session
    try {
      final savedUser = await _local.getSavedUser();
      if (savedUser != null) {
        final user = User(
          id: savedUser['id'] as String,
          email: savedUser['email'] as String,
          name: savedUser['name'] as String?,
        );
        return AuthState.authenticated(user);
      }
    } catch (_) {}
    return const AuthState.unauthenticated();
  }

  Future<void> loginWithEmail(String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (email.isEmpty || password.isEmpty) {
        throw Exception('Email and password required');
      }
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: email.split('@').first,
      );
      // Persist so session survives restarts
      await _local.saveUser({
        'id': user.id,
        'email': user.email,
        'name': user.name,
      });
      return AuthState.authenticated(user);
    });
  }

  Future<void> registerWithEmail(
      String name, String email, String password) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('All fields required');
      }
      final user = User(
        id: 'user_${DateTime.now().millisecondsSinceEpoch}',
        email: email,
        name: name,
      );
      await _local.saveUser({
        'id': user.id,
        'email': user.email,
        'name': user.name,
      });
      return AuthState.authenticated(user);
    });
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = User(
        id: 'user_google_${DateTime.now().millisecondsSinceEpoch}',
        email: 'user@gmail.com',
        name: 'Google User',
      );
      await _local.saveUser({
        'id': user.id,
        'email': user.email,
        'name': user.name,
      });
      return AuthState.authenticated(user);
    });
  }

  Future<void> logout() async {
    // Clear everything from secure storage
    await _local.clearTokens();
    state = const AsyncData(AuthState.unauthenticated());
  }
}

final authNotifierProvider =
    AsyncNotifierProvider<AuthNotifier, AuthState>(AuthNotifier.new);