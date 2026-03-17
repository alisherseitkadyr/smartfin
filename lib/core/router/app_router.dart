import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/learn/presentation/pages/learn_page.dart';

// Route name constants
class Routes {
  Routes._();
  static const shell = '/';
  static const home = '/home';
  static const explore = '/explore';
  static const learn = '/learn';
  static const profile = '/profile';
}

final appRouter = GoRouter(
  initialLocation: Routes.explore,
  routes: [
    ShellRoute(
      builder: (context, state, child) => _AppShell(child: child),
      routes: [
        GoRoute(
          path: Routes.explore,
          pageBuilder: (context, state) => const NoTransitionPage(child: ExplorePage()),
        ),
        GoRoute(
          path: Routes.learn,
          pageBuilder: (context, state) => const NoTransitionPage(child: LearnPage()),
        ),
        // Placeholder routes for home and profile
        GoRoute(
          path: Routes.home,
          pageBuilder: (context, state) => const NoTransitionPage(child: _PlaceholderPage(label: 'Home')),
        ),
        GoRoute(
          path: Routes.profile,
          pageBuilder: (context, state) => const NoTransitionPage(child: _PlaceholderPage(label: 'Profile')),
        ),
      ],
    ),
  ],
);

// ── App shell with bottom nav ─────────────────────────────────
class _AppShell extends StatelessWidget {
  final Widget child;
  const _AppShell({required this.child});

  int _locationToIndex(String location) {
    if (location.startsWith(Routes.explore)) return 1;
    if (location.startsWith(Routes.learn)) return 2;
    if (location.startsWith(Routes.profile)) return 3;
    return 0; // home
  }

  void _onTabTap(BuildContext context, int index) {
    switch (index) {
      case 0: context.go(Routes.home);
      case 1: context.go(Routes.explore);
      case 2: context.go(Routes.learn);
      case 3: context.go(Routes.profile);
    }
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

// ── Bottom navigation bar ─────────────────────────────────────
class _AppBottomNav extends StatelessWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _AppBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Color(0xFFE5E7EB), width: 1)),
        boxShadow: [BoxShadow(color: Color(0x0A000000), blurRadius: 20, offset: Offset(0, -4))],
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 64,
          child: Row(
            children: [
              _NavItem(icon: Icons.home_rounded, label: 'Home', selected: selectedIndex == 0, onTap: () => onTap(0)),
              _NavItem(icon: Icons.explore_rounded, label: 'Explore', selected: selectedIndex == 1, onTap: () => onTap(1)),
              _NavItem(icon: Icons.menu_book_rounded, label: 'Learn', selected: selectedIndex == 2, onTap: () => onTap(2)),
              _NavItem(icon: Icons.person_rounded, label: 'Profile', selected: selectedIndex == 3, onTap: () => onTap(3)),
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
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 150),
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
                  fontWeight: selected ? FontWeight.w600 : FontWeight.w500,
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
      ),
    );
  }
}

// ── Placeholder for screens not yet built ─────────────────────
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
            Text('🚧', style: const TextStyle(fontSize: 48)),
            const SizedBox(height: 16),
            Text(
              '$label screen',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 8),
            Text(
              'Coming soon',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ],
        ),
      ),
    );
  }
}