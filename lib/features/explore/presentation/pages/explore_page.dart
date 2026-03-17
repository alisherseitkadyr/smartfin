import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';

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

  void _showLockedSheet(BuildContext context, TopicWithStatus t, List<TopicWithStatus> allTopics) {
    final prereq = allTopics.where((x) => x.topic.id == t.topic.prerequisiteId).firstOrNull;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (_) => LockedTopicSheet(
        topicWithStatus: t,
        prerequisiteTitle: prereq?.topic.title,
        onGoToPrerequisite: prereq != null && !prereq.isLocked
            ? () => _handleTopicTap(prereq, allTopics)
            : null,
      ),
    );
  }

  void _handleTopicTap(TopicWithStatus t, List<TopicWithStatus> allTopics) {
    if (t.isLocked) {
      _showLockedSheet(context, t, allTopics);
      return;
    }
    // Navigation to learn page will be wired via router
    // For now show a snack to indicate tap is working
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Opening ${t.topic.title}…'),
        backgroundColor: AppColors.greenDark,
        duration: const Duration(seconds: 1),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final filter = ref.watch(exploreFilterProvider);
    final asyncTopics = ref.watch(exploreTopicsProvider);

    return Scaffold(
      backgroundColor: AppColors.bg,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // ── App Bar ──────────────────────────────────────────
          SliverAppBar(
            pinned: true,
            backgroundColor: AppColors.surface,
            expandedHeight: 140,
            collapsedHeight: 60,
            surfaceTintColor: Colors.transparent,
            shadowColor: Colors.black.withOpacity(0.06),
            elevation: 0.5,
            flexibleSpace: FlexibleSpaceBar(
              titlePadding: const EdgeInsets.fromLTRB(20, 0, 20, 16),
              title: Text(
                'Explore Topics',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
             
            ),
          ),

          // ── Search bar ───────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: _SearchBar(
                controller: _searchController,
                onChanged: _onSearchChanged,
                onClear: _clearSearch,
                hasText: filter.query.isNotEmpty,
              ),
            ),
          ),

          // ── Filter chips ─────────────────────────────────────
          SliverToBoxAdapter(
            child: Container(
              color: AppColors.surface,
              padding: const EdgeInsets.fromLTRB(0, 12, 0, 12),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  children: [
                    FilterChipItem(
                      label: 'All',
                      isActive: filter.level == null,
                      onTap: () => _onFilterLevel(null),
                    ),
                    const SizedBox(width: 8),
                    ...TopicLevel.values.map((level) => Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: FilterChipItem(
                        label: level.label,
                        isActive: filter.level == level,
                        onTap: () => _onFilterLevel(
                          filter.level == level ? null : level,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ),
          ),

          // ── Divider ──────────────────────────────────────────
          const SliverToBoxAdapter(
            child: Divider(height: 1),
          ),

          // ── Content ──────────────────────────────────────────
          asyncTopics.when(
            loading: () => const SliverFillRemaining(
              child: Center(child: CircularProgressIndicator(color: AppColors.green)),
            ),
            error: (e, _) => SliverFillRemaining(
              child: Center(
                child: Text('Something went wrong', style: Theme.of(context).textTheme.bodyMedium),
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

              // Group by level
              final grouped = <TopicLevel, List<TopicWithStatus>>{};
              for (final level in TopicLevel.values) {
                final group = topics.where((t) => t.topic.level == level).toList();
                if (group.isNotEmpty) grouped[level] = group;
              }

              return SliverPadding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 100),
                sliver: SliverList(
                  delegate: SliverChildBuilderDelegate(
                    (context, index) {
                      // Build a flat list of section headers + cards
                      final items = _buildFlatList(grouped, topics);
                      if (index >= items.length) return null;
                      return items[index];
                    },
                    childCount: _countFlatItems(grouped),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  int _countFlatItems(Map<TopicLevel, List<TopicWithStatus>> grouped) {
    int count = 0;
    for (final level in TopicLevel.values) {
      if (grouped.containsKey(level)) {
        count += 1 + grouped[level]!.length; // header + cards
      }
    }
    return count;
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

      items.add(SectionGroupHeader(level: level, done: done, total: group.length));

      for (int i = 0; i < group.length; i++) {
        final t = group[i];
        items.add(Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: TopicCard(
            topicWithStatus: t,
            animationIndex: cardIndex,
            onTap: () => _handleTopicTap(t, allTopics),
          ),
        ));
        cardIndex++;
      }
    }

    return items;
  }
}

// ── Search bar widget ─────────────────────────────────────────
class _SearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onClear;
  final bool hasText;

  const _SearchBar({
    required this.controller,
    required this.onChanged,
    required this.onClear,
    required this.hasText,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 46,
      decoration: BoxDecoration(
        color: AppColors.mutedXLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.mutedLight, width: 1.5),
      ),
      child: Row(
        children: [
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12),
            child: Icon(Icons.search_rounded, color: AppColors.muted, size: 20),
          ),
          Expanded(
            child: TextField(
              controller: controller,
              onChanged: onChanged,
              style: Theme.of(context).textTheme.bodyMedium,
              decoration: const InputDecoration(
                hintText: 'Search topics…',
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
                padding: EdgeInsets.symmetric(horizontal: 12),
                child: Icon(Icons.cancel_rounded, color: AppColors.muted, size: 18),
              ),
            ),
        ],
      ),
    );
  }
}