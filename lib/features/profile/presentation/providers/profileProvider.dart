import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../auth/presentation/providers/auth_providers.dart';
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
    state = AsyncData(updated);
  }
}
