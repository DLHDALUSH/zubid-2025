import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../data/repositories/social_auth_repository.dart';

class SocialLoginButtons extends ConsumerWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: [
        _SocialLoginButton(
          text: 'Continue with Google',
          icon: 'assets/icons/google.png',
          onPressed: () => _handleSocialLogin(
            context,
            ref,
            () => ref.read(socialAuthRepositoryProvider).signInWithGoogle(),
            'Google',
          ),
        ),
        const SizedBox(height: 12),
        if (defaultTargetPlatform == TargetPlatform.iOS) ...[
          _SocialLoginButton(
            text: 'Continue with Apple',
            icon: 'assets/icons/apple.png',
            onPressed: () => _handleSocialLogin(
              context,
              ref,
              () => ref.read(socialAuthRepositoryProvider).signInWithApple(),
              'Apple',
            ),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Future<void> _handleSocialLogin(
    BuildContext context,
    WidgetRef ref,
    Future<void> Function() signInMethod,
    String providerName,
  ) async {
    try {
      AppLogger.userAction('$providerName login attempted');
      await signInMethod();
      // TODO: Handle the successful response from your repository
    } catch (e) {
      AppLogger.error('$providerName login error', error: e);
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('$providerName login failed. Please try again.'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback onPressed;

  const _SocialLoginButton({
    required this.text,
    required this.icon,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: _buildIcon(icon),
        label: Text(text),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(color: theme.colorScheme.outline.withOpacity(0.3)),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
      ),
    );
  }

  Widget _buildIcon(String iconPath) {
    // Fallback to icons if assets are missing
    if (iconPath.contains('google')) {
      return Container(
        width: 20,
        height: 20,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(4),
        ),
        child: const Icon(
          Icons.g_mobiledata,
          size: 16,
          color: Colors.blue,
        ),
      );
    } else if (iconPath.contains('apple')) {
      return const Icon(
        Icons.apple,
        size: 20,
        color: Colors.black,
      );
    }

    // Try to load the asset, fallback to generic icon
    try {
      return Image.asset(iconPath, width: 20, height: 20);
    } catch (e) {
      return const Icon(
        Icons.login,
        size: 20,
      );
    }
  }
}
