// smartfin/lib/core/router/app_router.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../l10n/app_l10n.dart';

import '../../features/auth/presentation/pages/splash_screen.dart';
import '../../features/auth/presentation/pages/login_page.dart';
import '../../features/auth/presentation/pages/register_page.dart';
import '../../features/explore/presentation/pages/explore_page.dart';
import '../../features/explore/presentation/pages/topic_preview_page.dart';
import '../../features/learn/presentation/pages/learn_page.dart';
import '../../features/home/presentation/pages/home_page.dart';
import '../../features/expenses/presentation/pages/expense_page.dart';
import '../../features/learn/presentation/pages/lesson_flow_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';
import '../../features/onboarding/presentation/pages/onboarding_page.dart';

class Routes {
  Routes._();
  static const splash = '/';
  static const login = '/login';
  static const register = '/register';
  static const onboarding = '/onboarding';
  static const home = '/home';
  static const explore = '/explore';
  static const learn = '/learn';
  static const expenses = '/expenses';
  static const profile = '/profile';
}

final _rootNavigatorKey = GlobalKey<NavigatorState>();

final appRouter = GoRouter(
  navigatorKey: _rootNavigatorKey,
  initialLocation: Routes.splash,
  routes: [
    // ── Splash screen (entry point) ────────────────────
    GoRoute(
      path: Routes.splash,
      pageBuilder: (_, __) => const NoTransitionPage(child: SplashScreen()),
    ),

    // ── Auth routes ────────────────────────────────────
    GoRoute(
      path: Routes.login,
      pageBuilder: (_, __) => const NoTransitionPage(child: LoginPage()),
    ),
    GoRoute(
      path: Routes.register,
      pageBuilder: (_, __) => const NoTransitionPage(child: RegisterPage()),
    ),

    // ── Onboarding (post-registration setup) ───────────
    GoRoute(
      path: Routes.onboarding,
      pageBuilder: (_, __) => const NoTransitionPage(child: OnboardingPage()),
    ),

    // ── Main app shell with tabs ───────────────────────
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
          routes: [
            GoRoute(
              path: 'topic/:topicId',
              builder: (context, state) =>
                  TopicPreviewPage(topicId: state.pathParameters['topicId']!),
            ),
          ],
        ),
        GoRoute(
          path: Routes.learn,
          pageBuilder: (_, __) => const NoTransitionPage(child: LearnPage()),
          routes: [
            GoRoute(
              parentNavigatorKey: _rootNavigatorKey,
              path: 'lesson/:topicId',
              pageBuilder: (context, state) {
                final topicId = state.pathParameters['topicId']!;
                return NoTransitionPage(
                  child: LessonFlowPage(topicId: topicId),
                );
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
          pageBuilder: (_, __) => const NoTransitionPage(child: ProfilePage()),
        ),
      ],
    ),

    // ── Assessment route ───────────────────────────────
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
    if (location.startsWith(Routes.explore)) return 1;
    if (location.startsWith(Routes.learn)) return 2;
    if (location.startsWith(Routes.expenses)) return 3;
    if (location.startsWith(Routes.profile)) return 4;
    return 0; // home
  }

  void _onTabTap(BuildContext context, int index) {
    context.go(_tabs[index]);
  }

  @override
  Widget build(BuildContext context) {
    final location = GoRouterState.of(context).location;
    final selectedIndex = _locationToIndex(location);
    final surface = Theme.of(context).colorScheme.surface;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        systemNavigationBarColor: surface,
        systemNavigationBarIconBrightness:
            isDark ? Brightness.light : Brightness.dark,
      ),
      child: Scaffold(
        body: child,
        bottomNavigationBar: _AppBottomNav(
          selectedIndex: selectedIndex,
          onTap: (i) => _onTabTap(context, i),
        ),
      ),
    );
  }
}

// ── Bottom nav ────────────────────────────────────────────────
class _AppBottomNav extends ConsumerWidget {
  final int selectedIndex;
  final ValueChanged<int> onTap;

  const _AppBottomNav({required this.selectedIndex, required this.onTap});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = ref.watch(appL10nProvider);
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Color(0x0A000000),
            blurRadius: 20,
            offset: Offset(0, -4),
          ),
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
                label: l10n.navHome,
                selected: selectedIndex == 0,
                onTap: () => onTap(0),
              ),
              _NavItem(
                icon: Icons.explore_rounded,
                label: l10n.navExplore,
                selected: selectedIndex == 1,
                onTap: () => onTap(1),
              ),
              _NavItem(
                icon: Icons.menu_book_rounded,
                label: l10n.navLearn,
                selected: selectedIndex == 2,
                onTap: () => onTap(2),
              ),
              _NavItem(
                icon: Icons.receipt_long_rounded,
                label: l10n.navExpenses,
                selected: selectedIndex == 3,
                onTap: () => onTap(3),
              ),
              _NavItem(
                icon: Icons.person_rounded,
                label: l10n.navProfile,
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
    );
  }
}
