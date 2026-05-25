import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:google_sign_in_web/web_only.dart' as google_web;

import '../providers/auth_providers.dart';

class PlatformGoogleSignInButton extends ConsumerStatefulWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const PlatformGoogleSignInButton({
    super.key,
    this.onTap,
    this.isLoading = false,
  });

  @override
  ConsumerState<PlatformGoogleSignInButton> createState() =>
      _PlatformGoogleSignInButtonState();
}

class _PlatformGoogleSignInButtonState
    extends ConsumerState<PlatformGoogleSignInButton> {
  StreamSubscription<GoogleSignInAccount?>? _accountSub;
  bool _isSubmitting = false;

  @override
  void initState() {
    super.initState();
    _accountSub = ref
        .read(googleSignInProvider)
        .onCurrentUserChanged
        .listen(_submitGoogleAccount);
  }

  @override
  void dispose() {
    _accountSub?.cancel();
    super.dispose();
  }

  Future<void> _submitGoogleAccount(GoogleSignInAccount? account) async {
    if (account == null || _isSubmitting || !mounted) return;

    _isSubmitting = true;
    try {
      final auth = await account.authentication;
      if (!mounted) return;
      await ref
          .read(authNotifierProvider.notifier)
          .loginWithGoogleIdToken(auth.idToken ?? '');
    } finally {
      _isSubmitting = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 52,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final buttonWidth = constraints.maxWidth
              .clamp(120.0, 400.0)
              .toDouble();

          return AbsorbPointer(
            absorbing: widget.isLoading,
            child: Stack(
              alignment: Alignment.center,
              children: [
                google_web.renderButton(
                  configuration: google_web.GSIButtonConfiguration(
                    type: google_web.GSIButtonType.standard,
                    theme: google_web.GSIButtonTheme.outline,
                    size: google_web.GSIButtonSize.large,
                    text: google_web.GSIButtonText.continueWith,
                    shape: google_web.GSIButtonShape.rectangular,
                    logoAlignment: google_web.GSIButtonLogoAlignment.left,
                    minimumWidth: buttonWidth,
                  ),
                ),
                if (widget.isLoading)
                  Positioned.fill(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                      ),
                      child: const Center(
                        child: SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2.5),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
