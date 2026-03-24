// smartfin/lib/core/router/app_router.dart
//
// UPDATED — adds /home and /expenses routes alongside the existing
// /explore and /learn routes. All four tabs are now wired.
//
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/learn/presentation/pages/learn_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/expenses/presentation/pages/expense_page.dart';
import '../../features/learn/presentation/pages/lesson_flow_page.dart';

class Routes {
  Routes._();
  static const shell    = '/';
  static const home     = '/home';
  static const explore  = '/explore';
  static const learn    = '/learn';
  static const expenses = '/expenses';
  static const profile  = '/profile';
}

final appRouter = GoRouter(
  initialLocation: Routes.home,
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: Routes.home,
          pageBuilder: (_, __) => const NoTransitionPage(child: HomePage()),
        ),
        GoRoute(
          path: Routes.explore,
          pageBuilder: (_, __) => const NoTransitionPage(child: ExplorePage()),
        ),
        GoRoute(
          path: Routes.learn,
          pageBuilder: (_, __) => const NoTransitionPage(child: LearnPage()),
          routes: [
            GoRoute(
              path: 'lesson/:topicId',
              builder: (context, state) {
                final topicId = state.pathParameters['topicId']!;
                return LessonFlowPage(topicId: topicId);
              },
            ),
          ],
        ),
        GoRoute(
          path: Routes.expenses,
          pageBuilder: (_, __) => const NoTransitionPage(child: ExpensePage()),
        ),
        GoRoute(
          path: Routes.profile,
          pageBuilder: (_, __) =>
              const NoTransitionPage(child: _PlaceholderPage(label: 'Profile')),
        ),
      ],
    ),
  ],
);

// ── App shell ─────────────────────────────────────────────────
class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  static const _tabs = [
    Routes.home,
    Routes.explore,
    Routes.learn,
    Routes.expenses,
    Routes.profile,
  ];

  int _locationToIndex(String location) {
    if (location.startsWith(Routes.explore))  return 1;
    if (location.startsWith(Routes.learn))    return 2;
    if (location.startsWith(Routes.expenses)) return 3;
    if (location.startsWith(Routes.profile))  return 4;
    return 0; // home
  }

  void _onTabTap(BuildContext context, int index) {
    context.go(_tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).location;
    final selectedIndex = _locationToIndex(location);

    return Scaffold(
      body: child,
      bottomNavigationBar: _AppBottomNav(
        selectedIndex: selectedIndex,
        onTap: (i) => _onTabTap(context, i),
      ),
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────
class _AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _AppBottomNav(
      {required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        boxShadow: [
          BoxShadow(
              color: Color(0x0A000000),
              blurRadius: 20,
              offset: Offset(0, -4)),
        ],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(
                icon: Icons.home_rounded,
                label: 'Home',
                selected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.explore_rounded,
                label: 'Explore',
                selected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.menu_book_rounded,
                label: 'Learn',
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                label: 'Expenses',
                selected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: 'Profile',
                selected: selectedIndex == 4,
                onTap: () => onTap(4),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = selected ? const Color(0xFF15803D) : const Color(0xFF6B7280);

    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedSlide(
              duration: const Duration(milliseconds: 150),
              offset: selected ? const Offset(0, -0.1) : Offset.zero,
              child: Icon(icon, color: color, size: 24),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Sora',
                fontSize: 11,
                fontWeight:
                    selected ? FontWeight.w600 : FontWeight.w500,
                color: color,
              ),
            ),
            const SizedBox(height: 3),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: selected ? 5 : 0,
              height: selected ? 5 : 0,
              decoration: const BoxDecoration(
                color: Color(0xFF22C55E),
                shape: BoxShape.circle,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Placeholder for profile ───────────────────────────────────
class _PlaceholderPage extends StatelessWidget {
  final String label;
  const _PlaceholderPage({required this.label});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🚧', style: TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text('$label screen',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 8),
            Text('Coming soon',
                style: Theme.of(context).textTheme.bodyMedium),
          ],
        ),
      ),
    );
  }
}