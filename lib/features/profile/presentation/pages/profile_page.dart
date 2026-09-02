import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../../core/l10n/app_l10n.dart';
import '../../../../../core/theme/app_theme.dart';
import '../../../home/presentation/providers/home_providers.dart';
import '../../../home/domain/entities/home_entities.dart';
import '../providers/profile_provider.dart';
import '../../domain/entities/user_profile.dart';

class ProfilePage extends ConsumerWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final profileAsync = ref.watch(userProfileProvider);

    return Scaffold(
      body: profileAsync.when(
        data: (profile) => _ProfileContent(profile: profile),
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Error: $e')),
      ),
    );
  }
}

class _ProfileContent extends ConsumerWidget {
  final UserProfile profile;
  const _ProfileContent({required this.profile});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    final homeAsync = ref.watch(homeDataProvider);
    final initial = profile.name.isNotEmpty ? profile.name[0].toUpperCase() : 'U';
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Gradient hero header ────────────────────────────────
        SliverToBoxAdapter(
          child: _HeroHeader(
            initial: initial,
            profile: profile,
            l10n: l10n,
            homeAsync: homeAsync,
            isDark: isDark,
          ).animate().fadeIn(duration: 300.ms),
        ),

        // ── Stats grid ──────────────────────────────────────────
        SliverToBoxAdapter(
          child: _StatsSection(homeAsync: homeAsync)
              .animate()
              .fadeIn(delay: 80.ms, duration: 300.ms),
        ),

        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.paddingOf(context).bottom + 100),
        ),
      ],
    );
  }
}

// ── Hero header with gradient, avatar, XP bar ─────────────────
class _HeroHeader extends StatelessWidget {
  final String initial;
  final UserProfile profile;
  final AppL10n l10n;
  final AsyncValue<HomeData> homeAsync;
  final bool isDark;

  const _HeroHeader({
    required this.initial,
    required this.profile,
    required this.l10n,
    required this.homeAsync,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Gradient background slab
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFF0F4C2A), Color(0xFF166534)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          padding: EdgeInsets.fromLTRB(
            20,
            MediaQuery.paddingOf(context).top + 16,
            20,
            88, // room for the floating card
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Settings row
              Row(
                children: [
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.settings_outlined, color: Colors.white70, size: 22),
                    onPressed: () => context.push('/settings'),
                    tooltip: l10n.settingsTitle,
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Avatar + name + email
              Row(
                children: [
                  Container(
                    width: 68,
                    height: 68,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.15),
                      shape: BoxShape.circle,
                      border: Border.all(color: Colors.white30, width: 2),
                    ),
                    child: Center(
                      child: Text(
                        initial,
                        style: const TextStyle(
                          color: Colors.white,
                          fontFamily: 'Sora',
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          profile.name,
                          style: const TextStyle(
                            color: Colors.white,
                            fontFamily: 'Sora',
                            fontSize: 20,
                            fontWeight: FontWeight.w700,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          profile.email,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.65),
                            fontSize: 13,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Floating XP card
        Positioned(
          left: 16,
          right: 16,
          bottom: 0,
          child: Transform.translate(
            offset: const Offset(0, 20),
            child: _XpCard(homeAsync: homeAsync, isDark: isDark),
          ),
        ),
      ],
    );
  }
}

// ── Floating XP + level card ───────────────────────────────────
class _XpCard extends ConsumerWidget {
  final AsyncValue<HomeData> homeAsync;
  final bool isDark;
  const _XpCard({required this.homeAsync, required this.isDark});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.4 : 0.10),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: homeAsync.when(
        data: (home) {
          final user = home.user;
          final greenBg = isDark ? const Color(0xFF0D3320) : AppColors.greenLight;
          final amberBg = isDark ? const Color(0xFF3D2A00) : AppColors.amberLight;

          return Column(
            children: [
              Row(
                children: [
                  _Pill(label: 'Level ${user.level}', bg: greenBg, fg: AppColors.greenDark),
                  const SizedBox(width: 8),
                  _Pill(label: '${user.totalXp} XP', bg: amberBg, fg: const Color(0xFFD97706)),
                  const Spacer(),
                  Text(
                    l10n.xpToNextLabel(user.xpToNextLevel),
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ClipRRect(
                borderRadius: BorderRadius.circular(6),
                child: LinearProgressIndicator(
                  value: user.progressToNextLevel,
                  minHeight: 7,
                  backgroundColor: context.borderColor,
                  valueColor: const AlwaysStoppedAnimation(AppColors.green),
                ),
              ),
            ],
          );
        },
        loading: () => const SizedBox(
          height: 48,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

// ── Stats 2×2 section ──────────────────────────────────────────
class _StatsSection extends ConsumerWidget {
  final AsyncValue<HomeData> homeAsync;
  const _StatsSection({required this.homeAsync});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 44, 16, 0),
      child: homeAsync.when(
        data: (home) {
          final user = home.user;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(4, 0, 0, 14),
                child: Text(
                  l10n.statistics,
                  style: Theme.of(context)
                      .textTheme
                      .labelLarge
                      ?.copyWith(letterSpacing: 0.8),
                ),
              ),
              GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                childAspectRatio: 1.55,
                children: [
                  _StatCard(
                    icon: Icons.menu_book_rounded,
                    value: '${user.completedTopics}',
                    label: l10n.topicsDoneLabel,
                    iconBg: AppColors.blueLight,
                    iconColor: AppColors.blue,
                  ),
                  _StatCard(
                    icon: Icons.local_fire_department_rounded,
                    value: '${user.streakDays}d',
                    label: l10n.dayStreakStatLabel,
                    iconBg: AppColors.amberLight,
                    iconColor: const Color(0xFFD97706),
                  ),
                  _StatCard(
                    icon: Icons.star_rounded,
                    value: '${user.totalXp}',
                    label: l10n.totalXpLabel,
                    iconBg: AppColors.greenLight,
                    iconColor: AppColors.greenDark,
                  ),
                  _StatCard(
                    icon: Icons.explore_rounded,
                    value: '${user.totalTopics}',
                    label: l10n.totalTopicsLabel,
                    iconBg: AppColors.indigoLight,
                    iconColor: AppColors.indigoDark,
                  ),
                ],
              ),
            ],
          );
        },
        loading: () => const SizedBox(
          height: 180,
          child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        error: (_, __) => const SizedBox.shrink(),
      ),
    );
  }
}

// ── Small pill badge ───────────────────────────────────────────
class _Pill extends StatelessWidget {
  final String label;
  final Color bg;
  final Color fg;
  const _Pill({required this.label, required this.bg, required this.fg});

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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: surface,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: isDark ? 0.3 : 0.06),
            blurRadius: 10,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: iconBg,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 17),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
              ),
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
