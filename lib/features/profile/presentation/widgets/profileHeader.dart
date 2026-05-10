import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../../core/theme/app_theme.dart';


// ── Profile header ─────────────────────────────────────────────
class ProfileHeader extends StatelessWidget {
  final String name;
  final String email;
  final String initial;
  final AsyncValue homeAsync;

  const ProfileHeader({
    required this.name,
    required this.email,
    required this.initial,
    required this.homeAsync,
  });

  @override
  Widget build(BuildContext context) {
    final surface = Theme.of(context).colorScheme.surface;

    return Container(
      color: surface,
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: Column(
        children: [
          // Avatar + info
          Row(
            children: [
              Container(
                width: 60,
                height: 60,
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
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      name,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    const SizedBox(height: 3),
                    Text(email, style: Theme.of(context).textTheme.bodySmall),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 6,
                      children: const [
                        _StatBadge(
                          text: 'Level 5',
                          bg: AppColors.greenLight,
                          fg: AppColors.greenDark,
                        ),
                        _StatBadge(
                          text: '2,150 XP',
                          bg: AppColors.amberLight,
                          fg: Color(0xFFD97706),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          const Divider(height: 1),
        ],
      ),
    );
  }
}



class _StatBadge extends StatelessWidget {
  final String text;
  final Color bg;
  final Color fg;
  const _StatBadge({required this.text, required this.bg, required this.fg});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 4),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(
        text,
        style: TextStyle(
          fontSize: 11,
          fontFamily: 'Sora',
          fontWeight: FontWeight.w600,
          color: fg,
        ),
      ),
    );
  }
}