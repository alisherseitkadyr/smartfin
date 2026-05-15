import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/topic_item.dart';
import '../providers/explore_providers.dart';
import '../widgets/explore_widgets.dart';

class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final _searchController = TextEditingController();
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Re-fetch every time the Explore tab is opened so completion
    // status reflects recent lesson/quiz activity.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.invalidate(allTopicsProvider);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String value) {
    ref.read(exploreFilterProvider.notifier).update(
          (state) => state.copyWith(query: value),
        );
  }

  void _onFilterLevel(TopicLevel? level) {
    ref.read(exploreFilterProvider.notifier).update(
          (state) => state.copyWith(level: level),
        );
  }

  void _clearSearch() {
    _searchController.clear();
    ref.read(exploreFilterProvider.notifier).update(
          (_) => const ExploreFilter(),
        );
  }

  void _handleTopicTap(TopicWithStatus t, List<TopicWithStatus> allTopics) {
    if (t.isLocked) {
      final prereq = allTopics
          .where((x) => x.topic.id == t.topic.prerequisiteId)
          .firstOrNull;
      showModalBottomSheet(
        context: context,
        backgroundColor: Colors.transparent,
        builder: (_) => LockedTopicSheet(
          topicWithStatus: t,
          prerequisiteTitle: prereq?.topic.title,
          onGoToPrerequisite: prereq != null && !prereq.isLocked
              ? () {
                  Navigator.pop(context);
                  context.push('/explore/topic/${prereq.topic.id}');
                }
              : null,
        ),
      );
      return;
    }
    context.push('/explore/topic/${t.topic.id}');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = ref.watch(appL10nProvider);
    final filter = ref.watch(exploreFilterProvider);
    final asyncTopics = ref.watch(exploreTopicsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          SliverAppBar(
            pinned: true,
            backgroundColor: Theme.of(context).colorScheme.surface,
            expandedHeight: 56,
            collapsedHeight: 56,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withValues(alpha: 0.06),
            elevation: 0.5,
            title: Text(
              l10n.exploreTopics,
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            centerTitle: false,
            toolbarHeight: 56,
          ),
          SliverToBoxAdapter(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  0,
                ),
                child: _SearchBar(
                  controller: _searchController,
                  onChanged: _onSearchChanged,
                  onClear: _clearSearch,
                  hasText: filter.query.isNotEmpty,
                  hintText: l10n.searchTopics,
                ),
              ),
            ),
          ),
          SliverToBoxAdapter(
            child: ColoredBox(
              color: Theme.of(context).colorScheme.surface,
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.sm,
                  AppSpacing.xl,
                  AppSpacing.md,
                ),
                child: Row(
                  children: [
                    FilterChipItem(
                      label: l10n.all,
                      isActive: filter.level == null,
                      onTap: () => _onFilterLevel(null),
                    ),
                    const SizedBox(width: AppSpacing.sm),
                    ...TopicLevel.values.map(
                      (level) => Padding(
                        padding: const EdgeInsets.only(right: AppSpacing.sm),
                        child: FilterChipItem(
                          label: l10n.levelLabel(level),
                          isActive: filter.level == level,
                          onTap: () => _onFilterLevel(
                            filter.level == level ? null : level,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SliverToBoxAdapter(child: Divider(height: 1)),
          asyncTopics.when(
            loading: () => const SliverFillRemaining(
              child: Center(
                child: CircularProgressIndicator(color: AppColors.green),
              ),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text(
                  l10n.somethingWentWrong,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ),
            ),
            data: (topics) {
              if (topics.isEmpty) {
                return SliverToBoxAdapter(
                  child: ExploreEmptyState(
                    query: filter.query,
                    onClear: _clearSearch,
                  ),
                );
              }

              final grouped = <TopicLevel, List<TopicWithStatus>>{};
              for (final level in TopicLevel.values) {
                final group =
                    topics.where((t) => t.topic.level == level).toList();
                if (group.isNotEmpty) grouped[level] = group;
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  AppSpacing.xs,
                  AppSpacing.xl,
                  100,
                ),
                sliver: SliverList(
                  delegate: SliverChildListDelegate(
                    _buildFlatList(grouped, topics),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  List<Widget> _buildFlatList(
    Map<TopicLevel, List<TopicWithStatus>> grouped,
    List<TopicWithStatus> allTopics,
  ) {
    final items = <Widget>[];
    int cardIndex = 0;

    for (final level in TopicLevel.values) {
      final group = grouped[level];
      if (group == null) continue;

      final done = group.where((t) => t.isCompleted).length;
      items.add(
        SectionGroupHeader(level: level, done: done, total: group.length),
      );

      for (final t in group) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.sm + 2),
            child: TopicCard(
              topicWithStatus: t,
              animationIndex: cardIndex,
              onTap: () => _handleTopicTap(t, allTopics),
            ),
          ),
        );
        cardIndex++;
      }
    }

    return items;
  }
}

// ── Search bar ────────────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasText;
  final String hintText;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.hasText,
    required this.hintText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.mutedXLight,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: context.borderColor, width: 1.5),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
            child: Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: InputDecoration(
                hintText: hintText,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                filled: false,
                contentPadding: EdgeInsets.zero,
                isDense: true,
              ),
            ),
          ),
          if (hasText)
            GestureDetector(
              onTap: onClear,
              child: const Padding(
                padding: EdgeInsets.symmetric(horizontal: AppSpacing.md),
                child: Icon(
                  Icons.cancel_rounded,
                  color: AppColors.muted,
                  size: 18,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
