import 'package:flutter/material.dart';

import 'auth_widgets.dart';

class PlatformGoogleSignInButton extends StatelessWidget {
  final VoidCallback? onTap;
  final bool isLoading;

  const PlatformGoogleSignInButton({
    super.key,
    this.onTap,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleSignInButton(onTap: onTap, isLoading: isLoading);
  }
}
