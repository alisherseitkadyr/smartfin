// smartfin/lib/features/home/presentation/pages/home_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/progress_provider.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../auth/presentation/providers/auth_providers.dart';
import '../../domain/entities/home_entities.dart';
import '../providers/home_providers.dart';
import '../widgets/home_widgets.dart';

class HomePage extends ConsumerWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final asyncData = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: asyncData.when(
        loading: () => const _HomeSkeletonLoader(),
        error: (e, _) => _HomeErrorView(
          error: e.toString(),
          onRetry: () => ref.invalidate(homeDataProvider),
        ),
        data: (data) => _HomeContent(data: data),
      ),
    );
  }
}

// ── Loaded content ─────────────────────────────────────────────
class _HomeContent extends ConsumerWidget {
  final HomeData data;
  const _HomeContent({required this.data});

  void _onQuickAction(BuildContext context, QuickAction action) {
    context.go(action.route);
  }

  void _onTopicTap(BuildContext context, String topicId) {
    context.push('/learn/lesson/$topicId');
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authName = ref.watch(authNotifierProvider).valueOrNull?.user?.name;
    final progress = ref.watch(progressNotifierProvider);

    // Build continue-learning topic from live progress state if available,
    // otherwise fall back to what the home API returned.
    final FeaturedTopic? activeTopic = progress.currentTopic != null
        ? FeaturedTopic(
            topicId: progress.currentTopic!.id,
            title: progress.currentTopic!.title,
            emoji: progress.currentTopic!.icon,
            level: progress.currentTopic!.level,
            xp: progress.currentTopic!.xp,
            duration: progress.currentTopic!.duration,
            isInProgress: true,
            progressPercent: progress.currentTopic!.progressPercent,
          )
        : data.currentTopic;

    return CustomScrollView(
      physics: const BouncingScrollPhysics(),
      slivers: [
        // ── Status bar padding ─────────────────────────────
        SliverToBoxAdapter(
          child: SizedBox(height: MediaQuery.of(context).padding.top + 8),
        ),

        // ── Greeting header ────────────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HomeGreetingHeader(user: data.user, nameOverride: authName),
          ).animate().fadeIn(duration: 350.ms).slideY(begin: -0.05, end: 0),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // ── XP / streak stat row ───────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: HomeStatsRow(user: data.user),
          ).animate().fadeIn(delay: 60.ms, duration: 300.ms),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 20)),

        // ── Monthly snapshot card ──────────────────────────
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: MonthlySnapshotCard(snapshot: data.snapshot),
          ).animate().fadeIn(delay: 100.ms, duration: 300.ms),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // ── Continue Learning banner (live progress) ───────
        if (activeTopic != null) ...[
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: ContinueLearningCard(
                topic: activeTopic,
                onTap: () => _onTopicTap(context, activeTopic.topicId),
              ),
            ).animate().fadeIn(delay: 140.ms, duration: 300.ms),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 24)),
        ],

        // ── Recommended topics horizontal scroll ───────────
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SectionHeader(
                  title: 'Recommended for you',
                  onSeeAll: () => context.go('/explore'),
                ),
              ),
              const SizedBox(height: 12),
              RecommendedTopicsRow(
                topics: data.recommendedTopics,
                onTap: (id) => _onTopicTap(context, id),
              ),
            ],
          ).animate().fadeIn(delay: 180.ms, duration: 300.ms),
        ),

        const SliverToBoxAdapter(child: SizedBox(height: 24)),

        // ── Finance news section ───────────────────────────
        SliverToBoxAdapter(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: _SectionHeader(title: 'New for you'),
              ),
              const SizedBox(height: 12),
              const FinanceNewsSection(),
            ],
          ).animate().fadeIn(delay: 240.ms, duration: 300.ms),
        ),

        // ── Bottom padding ─────────────────────────────────
        const SliverToBoxAdapter(child: SizedBox(height: 100)),
      ],
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final VoidCallback? onSeeAll;
  const _SectionHeader({required this.title, this.onSeeAll});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(title, style: Theme.of(context).textTheme.titleLarge),
        if (onSeeAll != null)
          GestureDetector(
            onTap: onSeeAll,
            child: Text(
              'See all',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.greenDark,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),
      ],
    );
  }
}

// ── Error view ─────────────────────────────────────────────────
class _HomeErrorView extends StatelessWidget {
  final String error;
  final VoidCallback onRetry;
  const _HomeErrorView({required this.error, required this.onRetry});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('😕', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('Something went wrong',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text(error,
                style: Theme.of(context).textTheme.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            ElevatedButton(onPressed: onRetry, child: const Text('Retry')),
          ],
        ),
      ),
    );
  }
}

// ── Skeleton loader ────────────────────────────────────────────
class _HomeSkeletonLoader extends StatelessWidget {
  const _HomeSkeletonLoader();

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      physics: const NeverScrollableScrollPhysics(),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top + 8,
        left: 20, right: 20, bottom: 100,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Bone(width: 200, height: 28),
          const SizedBox(height: 6),
          _Bone(width: 140, height: 16),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _Bone(height: 76)),
            const SizedBox(width: 10),
            Expanded(child: _Bone(height: 76)),
            const SizedBox(width: 10),
            Expanded(child: _Bone(height: 76)),
          ]),
          const SizedBox(height: 20),
          Row(children: [
            Expanded(child: _Bone(height: 72)),
            const SizedBox(width: 10),
            Expanded(child: _Bone(height: 72)),
            const SizedBox(width: 10),
            Expanded(child: _Bone(height: 72)),
            const SizedBox(width: 10),
            Expanded(child: _Bone(height: 72)),
          ]),
          const SizedBox(height: 20),
          _Bone(height: 130),
          const SizedBox(height: 20),
          _Bone(height: 100),
          const SizedBox(height: 20),
          _Bone(width: 180, height: 20),
          const SizedBox(height: 12),
          Row(children: [
            _Bone(width: 160, height: 180),
            const SizedBox(width: 10),
            _Bone(width: 160, height: 180),
          ]),
        ],
      ),
    );
  }
}

class _Bone extends StatelessWidget {
  final double? width;
  final double height;
  const _Bone({this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: context.mutedLight,
        borderRadius: BorderRadius.circular(12),
      ),
    )
        .animate(onPlay: (c) => c.repeat())
        .shimmer(duration: 1200.ms, color: Theme.of(context).colorScheme.surface.withValues(alpha: 0.7));
  }
}