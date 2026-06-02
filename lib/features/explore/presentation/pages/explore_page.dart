import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/l10n/app_l10n.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../core/theme/app_theme.dart';
import '../../domain/entities/explore_section.dart';
import '../../domain/entities/topic_item.dart';
import '../providers/explore_providers.dart';
import '../widgets/explore_widgets.dart';

// ── Page ──────────────────────────────────────────────────────
class ExplorePage extends ConsumerStatefulWidget {
  const ExplorePage({super.key});

  @override
  ConsumerState<ExplorePage> createState() => _ExplorePageState();
}

class _ExplorePageState extends ConsumerState<ExplorePage> {
  final _bodyScrollController = ScrollController();
  final _cardRowController = ScrollController();

  int _activeSectionIndex = 0;
  bool _isProgrammaticScroll = false;
  bool _isUserScrollingBody = false;

  // Pre-allocate keys for up to 10 sections; unused keys have null contexts.
  final List<GlobalKey> _sectionKeys = List.generate(10, (_) => GlobalKey());

  // SectionCards header(108) + small buffer
  static const double _pinnedHeight = 116.0;

  @override
  void initState() {
    super.initState();
    _bodyScrollController.addListener(_onBodyScroll);
  }

  @override
  void dispose() {
    _bodyScrollController.removeListener(_onBodyScroll);
    _bodyScrollController.dispose();
    _cardRowController.dispose();
    super.dispose();
  }

  void _onBodyScroll() {
    if (_isProgrammaticScroll) return;
    int newActive = 0;
    for (int i = 0; i < _sectionKeys.length; i++) {
      final ctx = _sectionKeys[i].currentContext;
      if (ctx == null) continue;
      final box = ctx.findRenderObject() as RenderBox?;
      if (box == null) continue;
      if (box.localToGlobal(Offset.zero).dy <= _pinnedHeight) {
        newActive = i;
      }
    }
    if (newActive != _activeSectionIndex) {
      setState(() => _activeSectionIndex = newActive);
      // Card row syncs only after scroll ends — see NotificationListener below.
    }
  }

  void _animateCardIntoView(int index) {
    if (!_cardRowController.hasClients) return;
    const itemWidth = _kCardWidth + _kCardGap;
    final offset = (index * itemWidth - AppSpacing.xl).clamp(
      0.0,
      _cardRowController.position.maxScrollExtent,
    );
    _cardRowController.animateTo(
      offset,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  Future<void> _scrollToSection(int index) async {
    final ctx = _sectionKeys[index].currentContext;
    if (ctx == null) return;
    setState(() {
      _activeSectionIndex = index;
      _isProgrammaticScroll = true;
    });
    _animateCardIntoView(index);
    await Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 400),
      curve: Curves.easeInOut,
      alignment: 0.0,
    );
    await Future.delayed(const Duration(milliseconds: 150));
    if (mounted) setState(() => _isProgrammaticScroll = false);
  }

  void _handleTopicTap(TopicWithStatus t, List<ExploreSection> sections) {
    if (t.isLocked) {
      final allTopics = sections.expand((s) => s.topics).toList();
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
    final asyncSections = ref.watch(exploreSectionsProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: NotificationListener<ScrollNotification>(
          onNotification: (notification) {
            // depth == 0 means the body scroll, not the nested card row
            if (notification.depth == 0 && !_isProgrammaticScroll) {
              if (notification is ScrollStartNotification) {
                _isUserScrollingBody = notification.dragDetails != null;
              } else if (notification is ScrollEndNotification && _isUserScrollingBody) {
                _isUserScrollingBody = false;
                _animateCardIntoView(_activeSectionIndex);
              }
            }
            return false;
          },
          child: CustomScrollView(
          controller: _bodyScrollController,
          slivers: [
          SliverPersistentHeader(
            pinned: true,
            delegate: _SectionCardsDelegate(
              sections: asyncSections.valueOrNull ?? const [],
              activeIndex: _activeSectionIndex,
              controller: _cardRowController,
              onTap: _scrollToSection,
            ),
          ),
          asyncSections.when(
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
            data: (sections) => SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppSpacing.xl,
                  0,
                  AppSpacing.xl,
                  100,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: _buildSectionList(sections),
                ),
              ),
            ),
          ),
        ],
          ),
        ),
      ),
    );
  }

  List<Widget> _buildSectionList(List<ExploreSection> sections) {
    final items = <Widget>[];
    int cardIndex = 0;

    for (int i = 0; i < sections.length; i++) {
      final section = sections[i];

      items.add(_SectionBodyHeader(key: _sectionKeys[i], section: section));

      for (final t in section.topics) {
        items.add(
          Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.md),
            child: TopicCard(
              topicWithStatus: t,
              animationIndex: cardIndex,
              onTap: () => _handleTopicTap(t, sections),
            ),
          ),
        );
        cardIndex++;
      }
    }

    return items;
  }
}

// ── Section cards header constants ────────────────────────────
const double _kCardWidth = 98.0;
const double _kCardGap = 8.0;
const double _kCardsRowHeight = 135.0;
const double _kIndicatorWidth = 60.0; // ← change this to resize the line

// ── Section cards sticky delegate ────────────────────────────
class _SectionCardsDelegate extends SliverPersistentHeaderDelegate {
  final List<ExploreSection> sections;
  final int activeIndex;
  final ScrollController controller;
  final ValueChanged<int> onTap;

  _SectionCardsDelegate({
    required this.sections,
    required this.activeIndex,
    required this.controller,
    required this.onTap,
  });

  @override
  double get maxExtent => _kCardsRowHeight;

  @override
  double get minExtent => _kCardsRowHeight;

  @override
  bool shouldRebuild(_SectionCardsDelegate old) =>
      old.activeIndex != activeIndex || old.sections != sections;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) {
    return ColoredBox(
      color: Theme.of(context).colorScheme.surface,
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: controller,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(
                horizontal: AppSpacing.sm,
                vertical: AppSpacing.sm,
              ),
              itemCount: sections.length,
              itemBuilder: (ctx, i) {
                final s = sections[i];
                return Padding(
                  padding: EdgeInsets.only(
                    right: i < sections.length - 1 ? _kCardGap : 0,
                  ),
                  child: _SectionCard(
                    section: s,
                    isActive: i == activeIndex,
                    onTap: () => onTap(i),
                  ),
                );
              },
            ),
          ),
          SizedBox(
            height: 4,
            child: Stack(
              children: [
                _SlidingIndicator(
                  activeIndex: activeIndex,
                  scrollController: controller,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Section card (top row) ────────────────────────────────────
class _SectionCard extends StatelessWidget {
  final ExploreSection section;
  final bool isActive;
  final VoidCallback onTap;

  const _SectionCard({
    required this.section,
    required this.isActive,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final mutedColor = AppColors.getMutedColor(context);
    return GestureDetector(
      onTap: onTap,
      child: SizedBox(
        width: _kCardWidth,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _kCardWidth,
              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 5),
              decoration: BoxDecoration(
                color: isActive
                    ? AppColors.green.withValues(alpha: 0.12)
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(
                  color: isActive ? AppColors.green : context.borderColor,
                  width: isActive ? 1.5 : 1.0,
                ),
              ),
              child: Image.asset(
                section.icon,
                width: 60,
                height: 60,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              section.title,
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                color: isActive
                    ? Theme.of(context).textTheme.bodyMedium?.color
                    : mutedColor,
                fontWeight: isActive ? FontWeight.w700 : FontWeight.w500,
                fontSize: 11,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}

// ── Section body header ───────────────────────────────────────
class _SectionBodyHeader extends StatelessWidget {
  final ExploreSection section;

  const _SectionBodyHeader({super.key, required this.section});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppSpacing.xxl,
        bottom: AppSpacing.md,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  section.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: 5),
                Text(
                  section.description,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppColors.getMutedColor(context),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Image.asset(
            section.icon,
            width: 80,
            height: 80,
            fit: BoxFit.contain,
          ),
        ],
      ),
    );
  }
}

// ── Sliding indicator line ────────────────────────────────────
class _SlidingIndicator extends StatefulWidget {
  final int activeIndex;
  final ScrollController scrollController;

  const _SlidingIndicator({
    required this.activeIndex,
    required this.scrollController,
  });

  @override
  State<_SlidingIndicator> createState() => _SlidingIndicatorState();
}

class _SlidingIndicatorState extends State<_SlidingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _indexAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _indexAnim = Tween<double>(
      begin: widget.activeIndex.toDouble(),
      end: widget.activeIndex.toDouble(),
    ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
  }

  @override
  void didUpdateWidget(_SlidingIndicator old) {
    super.didUpdateWidget(old);
    if (old.activeIndex != widget.activeIndex) {
      _indexAnim = Tween<double>(
        begin: _indexAnim.value,
        end: widget.activeIndex.toDouble(),
      ).animate(CurvedAnimation(parent: _ctrl, curve: Curves.easeOut));
      _ctrl.forward(from: 0);
    }
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: Listenable.merge([_ctrl, widget.scrollController]),
      builder: (context, _) {
        final scrollOffset = widget.scrollController.hasClients
            ? widget.scrollController.offset
            : 0.0;
        // card's left edge + center offset so the line sits in the middle
        final cardLeft = AppSpacing.sm +
            _indexAnim.value * (_kCardWidth + _kCardGap) -
            scrollOffset;
        final left = (cardLeft + (_kCardWidth - _kIndicatorWidth) / 2)
            .clamp(0.0, double.infinity);
        return Positioned(
          left: left,
          top: 0,
          bottom: 0,
          width: _kIndicatorWidth,
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.green,
              borderRadius: BorderRadius.circular(1.5),
            ),
          ),
        );
      },
    );
  }
}
