import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/app_l10n.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/domain/entities/home_entities.dart';
import '../providers/profileProvider.dart';
import '../../domain/entities/userProfile.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: profileAsync.when(
        data: (profile) => _buildContent(context, ref, profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }

  Widget _buildContent(BuildContext context, WidgetRef ref, UserProfile profile) {
    final l10n = ref.watch(appL10nProvider);
    final homeAsync = ref.watch(homeDataProvider);
    final initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U';

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        SliverToBoxAdapter(
          child: SafeArea(
            bottom: false,
            child: Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 8, 20),
              child: Row(
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.green, AppColors.greenDark],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Sora',
                          fontSize: 24,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      profile.name,
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined),
                    onPressed: () => context.push('/settings'),
                    tooltip: l10n.settingsTitle,
                  ),
                  const SizedBox(width: 8),
                ],
              ),
            ),
          ),
        ),
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _LevelXpCard(homeAsync: homeAsync)
                  .animate()
                  .fadeIn(delay: 60.ms, duration: 300.ms),

              const SizedBox(height: 12),

              _StatsGrid(homeAsync: homeAsync)
                  .animate()
                  .fadeIn(delay: 120.ms, duration: 300.ms),

              const SizedBox(height: 100),
            ],
          ),
        ),
      ],
    );
  }
}

// ── Level + XP progress card ───────────────────────────────────
class _LevelXpCard extends StatelessWidget {
  final AsyncValue<HomeData> homeAsync;
  const _LevelXpCard({required this.homeAsync});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return homeAsync.when(
      data: (home) {
        final user = home.user;
        final progress = user.progressToNextLevel;
        final xpToNext = user.xpToNextLevel;
        final greenBg = isDark ? const Color(0xFF0D3320) : AppColors.greenLight;
        final amberBg = isDark ? const Color(0xFF3D2A00) : AppColors.amberLight;

        return Container(
          color: surface,
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  _Badge(
                    label: 'Level ${user.level}',
                    bg: greenBg,
                    fg: AppColors.greenDark,
                  ),
                  const SizedBox(width: 8),
                  _Badge(
                    label: '${user.totalXp} XP',
                    bg: amberBg,
                    fg: const Color(0xFFD97706),
                  ),
                  const Spacer(),
                  Text(
                    '$xpToNext XP to next level',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 14),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 8,
                  backgroundColor: context.borderColor,
                  valueColor: const AlwaysStoppedAnimation(AppColors.green),
                ),
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        color: surface,
        height: 80,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ── Stats 2×2 grid ─────────────────────────────────────────────
class _StatsGrid extends StatelessWidget {
  final AsyncValue<HomeData> homeAsync;
  const _StatsGrid({required this.homeAsync});

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return homeAsync.when(
      data: (home) {
        final user = home.user;
        return Container(
          color: surface,
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(bottom: 16),
                child: Text(
                  'STATISTICS',
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(letterSpacing: 0.6),
                ),
              ),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.6,
                children: [
                  _StatCard(
                    icon: Icons.menu_book_rounded,
                    value: '${user.completedTopics}',
                    label: 'Topics Completed',
                    iconBg: AppColors.blueLight,
                    iconColor: AppColors.blue,
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '${user.streakDays}',
                    label: 'Day Streak',
                    iconBg: AppColors.amberLight,
                    iconColor: const Color(0xFFD97706),
                  ),
                  _StatCard(
                    icon: Icons.star_rounded,
                    value: '${user.totalXp}',
                    label: 'Total XP',
                    iconBg: AppColors.greenLight,
                    iconColor: AppColors.greenDark,
                  ),
                  _StatCard(
                    icon: Icons.explore_rounded,
                    value: '${user.totalTopics}',
                    label: 'Total Topics',
                    iconBg: AppColors.mutedXLight,
                    iconColor: AppColors.muted,
                  ),
                ],
              ),
            ],
          ),
        );
      },
      loading: () => Container(
        color: surface,
        height: 180,
        child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (_, __) => const SizedBox.shrink(),
    );
  }
}

// ── Level / XP pill badge ──────────────────────────────────────
class _Badge extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Badge({required this.label, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: 12,
          fontFamily: 'Sora',
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}

// ── Single stat card ───────────────────────────────────────────
class _StatCard extends StatelessWidget {
  final IconData icon;
  final String value;
  final String label;
  final Color iconBg;
  final Color iconColor;
  const _StatCard({
    required this.icon,
    required this.value,
    required this.label,
    required this.iconBg,
    required this.iconColor,
  });

  @override
  Widget build(BuildContext context) {
    final borderColor = Theme.of(context).dividerTheme.color ?? context.borderColor;
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        border: Border.all(color: borderColor),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(icon, color: iconColor, size: 16),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(value, style: Theme.of(context).textTheme.headlineSmall),
              Text(
                label,
                style: Theme.of(context).textTheme.bodySmall,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
