import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';

import '../../../../core/services/api_client.dart';
import '../../../../core/services/safe_storage.dart';
import '../../data/datasources/auth_local_datasource.dart';
import '../../data/datasources/auth_remote_datasource.dart';
import '../../data/repositories/auth_repository_impl.dart';
import '../../domain/entities/user.dart';
import '../../domain/repositories/auth_repository.dart';
import '../../domain/usecases/auth_usecases.dart';

// ── Infrastructure ────────────────────────────────────────────

final dioProvider = Provider<Dio>((ref) {
  return ApiClient.createDio(storage: ref.watch(secureStorageProvider));
});

final googleSignInProvider = Provider<GoogleSignIn>(
  (_) => GoogleSignIn(scopes: ['email', 'profile']),
);

final secureStorageProvider = Provider<SafeStorage>((_) => const SafeStorage());

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
  AuthLocalDataSource get _local => ref.read(authLocalDataSourceProvider);

  @override
  Future<AuthState> build() async {
    try {
      final user = await ref.read(getCurrentUserProvider).call();
      if (user != null) {
        await _saveUser(user);
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
      final user = await ref
          .read(loginWithEmailProvider)
          .call(email: email, password: password);
      await _saveUser(user);
      return AuthState.authenticated(user);
    });
  }

  Future<void> registerWithEmail(
    String name,
    String email,
    String password,
  ) async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      if (name.isEmpty || email.isEmpty || password.isEmpty) {
        throw Exception('All fields required');
      }
      final user = await ref
          .read(registerWithEmailProvider)
          .call(name: name, email: email, password: password);
      await _saveUser(user);
      return AuthState.authenticated(user);
    });
  }

  Future<void> loginWithGoogle() async {
    state = const AsyncLoading();
    state = await AsyncValue.guard(() async {
      final user = await ref.read(loginWithGoogleProvider).call();
      await _saveUser(user);
      return AuthState.authenticated(user);
    });
  }

  Future<void> logout() async {
    await ref.read(logoutProvider).call();
    state = const AsyncData(AuthState.unauthenticated());
  }

  Future<void> _saveUser(User user) {
    return _local.saveUser({
      'id': user.id,
      'email': user.email,
      'name': user.name,
    });
  }
}

final authNotifierProvider = AsyncNotifierProvider<AuthNotifier, AuthState>(
  AuthNotifier.new,
);
