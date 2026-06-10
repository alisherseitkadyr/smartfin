import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
import '../../data/models/profile_model.dart';
import '../../domain/entities/userProfile.dart';

final userProfileProvider = AsyncNotifierProvider<UserProfileNotifier, UserProfile>(
  () => UserProfileNotifier(),
);

class UserProfileNotifier extends AsyncNotifier<UserProfile> {
  @override
  Future<UserProfile> build() async {
    final auth = await ref.watch(authNotifierProvider.future);
    final user = auth.user;
    return UserProfile(
      name: user?.name ?? 'User',
      email: user?.email ?? '',
      status: '',
      xp: 0,
      topicsCompleted: 0,
    );
  }

  Future<void> updateProfile(UserProfile updated) async {
    final ds = ref.read(profileRemoteDataSourceProvider);
    await ds.updateUserProfile(ProfileModel(
      name: updated.name,
      email: updated.email,
      status: updated.status,
      xp: updated.xp,
      topicsCompleted: updated.topicsCompleted,
    ));
    state = AsyncData(updated);
  }

  Future<void> changePassword(String currentPassword, String newPassword) async {
    final local = ref.read(authLocalDataSourceProvider);
    final refreshToken = await local.getRefreshToken() ?? '';
    final ds = ref.read(profileRemoteDataSourceProvider);
    await ds.changeUserPassword(currentPassword, newPassword, refreshToken);
  }
}
