import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/logger.dart';
import '../../data/models/auth_response_model.dart';
import '../../data/repositories/social_auth_repository.dart';
import '../providers/auth_provider.dart';

class SocialLoginButtons extends ConsumerStatefulWidget {
  const SocialLoginButtons({super.key});

  @override
  ConsumerState<SocialLoginButtons> createState() => _SocialLoginButtonsState();
}

class _SocialLoginButtonsState extends ConsumerState<SocialLoginButtons> {
  bool _isLoading = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _SocialLoginButton(
          text: 'Continue with Google',
          icon: 'assets/icons/google.png',
          isLoading: _isLoading,
          onPressed:
              _isLoading ? null : () => _handleGoogleSignIn(context, ref),
        ),
        const SizedBox(height: 12),
        if (defaultTargetPlatform == TargetPlatform.iOS) ...[
          _SocialLoginButton(
            text: 'Continue with Apple',
            icon: 'assets/icons/apple.png',
            isLoading: _isLoading,
            onPressed:
                _isLoading ? null : () => _handleAppleSignIn(context, ref),
          ),
          const SizedBox(height: 12),
        ],
      ],
    );
  }

  Future<void> _handleGoogleSignIn(BuildContext context, WidgetRef ref) async {
    setState(() => _isLoading = true);

    try {
      AppLogger.userAction('Google login attempted');

      final result =
          await ref.read(socialAuthRepositoryProvider).signInWithGoogle();

      if (!mounted) return;

      result.when(
        success: (response) {
          _handleSuccessfulLogin(context, ref, response, 'Google');
        },
        error: (error) {
          _showErrorSnackBar(context, error);
        },
      );
    } catch (e) {
      AppLogger.error('Google login error', error: e);
      if (mounted) {
        _showErrorSnackBar(context, 'Google login failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleAppleSignIn(BuildContext context, WidgetRef ref) async {
    setState(() => _isLoading = true);

    try {
      AppLogger.userAction('Apple login attempted');

      final result =
          await ref.read(socialAuthRepositoryProvider).signInWithApple();

      if (!mounted) return;

      result.when(
        success: (response) {
          _handleSuccessfulLogin(context, ref, response, 'Apple');
        },
        error: (error) {
          _showErrorSnackBar(context, error);
        },
      );
    } catch (e) {
      AppLogger.error('Apple login error', error: e);
      if (mounted) {
        _showErrorSnackBar(context, 'Apple login failed. Please try again.');
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _handleSuccessfulLogin(
    BuildContext context,
    WidgetRef ref,
    AuthResponseModel response,
    String providerName,
  ) {
    AppLogger.info(
        '$providerName login successful for: ${response.user?.email}');

    // Update auth state with the response
    ref.read(authProvider.notifier).loginWithSocialAuth(response);

    // Show success message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Welcome, ${response.user?.displayName ?? 'User'}!'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
      ),
    );

    // Navigate to home
    context.go('/home');
  }

  void _showErrorSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Theme.of(context).colorScheme.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }
}

class _SocialLoginButton extends StatelessWidget {
  final String text;
  final String icon;
  final VoidCallback? onPressed;
  final bool isLoading;

  const _SocialLoginButton({
    required this.text,
    required this.icon,
    required this.onPressed,
    this.isLoading = false,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton.icon(
        onPressed: onPressed,
        icon: isLoading
            ? const SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              )
            : _buildIcon(icon),
        label: Text(isLoading ? 'Please wait...' : text),
        style: OutlinedButton.styleFrom(
          padding: const EdgeInsets.symmetric(vertical: 16),
          side: BorderSide(
              color: theme.colorScheme.outline.withValues(alpha: 0.3)),
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
