import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../providers/connectivity_provider.dart';

class NoInternetPage extends ConsumerStatefulWidget {
  const NoInternetPage({super.key});

  @override
  ConsumerState<NoInternetPage> createState() => _NoInternetPageState();
}

class _NoInternetPageState extends ConsumerState<NoInternetPage>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulse;
  bool _checking = false;

  @override
  void initState() {
    super.initState();
    _pulse = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
      lowerBound: 0.88,
      upperBound: 1.0,
    )..repeat(reverse: true);
  }

  @override
  void dispose() {
    _pulse.dispose();
    super.dispose();
  }

  Future<void> _retry() async {
    if (_checking) return;
    setState(() => _checking = true);
    await ref.read(connectivityProvider.notifier).recheck();
    if (mounted) setState(() => _checking = false);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final bg = isDark ? const Color(0xFF0F1117) : const Color(0xFFF5F7FA);
    final iconRingOuter =
        isDark ? const Color(0xFF1A1D27) : const Color(0xFFE5E7EB);
    final iconRingInner =
        isDark ? const Color(0xFF252836) : const Color(0xFFD1D5DB);
    final iconColor =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);
    final titleColor = isDark ? Colors.white : const Color(0xFF111827);
    final subtitleColor =
        isDark ? const Color(0xFF9CA3AF) : const Color(0xFF6B7280);

    return Scaffold(
      backgroundColor: bg,
      body: SafeArea(
        child: Column(
          children: [
            const Spacer(flex: 3),

            // ── Icon ─────────────────────────────────────────────
            ScaleTransition(
              scale: _pulse,
              child: Container(
                width: 140,
                height: 140,
                decoration: BoxDecoration(
                  color: iconRingOuter,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: iconRingInner,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.wifi_off_rounded,
                      size: 44,
                      color: iconColor,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 36),

            // ── Text ─────────────────────────────────────────────
            Text(
              'No internet connection',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    color: titleColor,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 48),
              child: Text(
                'Connect to the internet to continue',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: subtitleColor,
                      height: 1.5,
                    ),
                textAlign: TextAlign.center,
              ),
            ),

            const Spacer(flex: 4),

            // ── Button ───────────────────────────────────────────
            Padding(
              padding: EdgeInsets.fromLTRB(
                24,
                0,
                24,
                MediaQuery.paddingOf(context).bottom + 24,
              ),
              child: _RetryButton(checking: _checking, onTap: _retry),
            ),
          ],
        ),
      ),
    );
  }
}

class _RetryButton extends StatelessWidget {
  final bool checking;
  final VoidCallback onTap;

  const _RetryButton({required this.checking, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: checking ? null : onTap,
      child: AnimatedOpacity(
        duration: const Duration(milliseconds: 150),
        opacity: checking ? 0.65 : 1.0,
        child: Container(
          height: 56,
          width: double.infinity,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF2C2C2E),
                Color(0xFF111111),
              ],
            ),
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.45),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.15),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: checking
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor:
                          AlwaysStoppedAnimation<Color>(Colors.white),
                    ),
                  )
                : const Text(
                    'Try again',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.1,
                    ),
                  ),
          ),
        ),
      ),
    );
  }
}
