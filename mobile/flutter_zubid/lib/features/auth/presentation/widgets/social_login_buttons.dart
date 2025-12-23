import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/custom_button.dart';

class SocialLoginButtons extends ConsumerWidget {
  const SocialLoginButtons({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Column(
      children: [
        // Google Login Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _handleGoogleLogin(context),
            icon: _buildGoogleIcon(),
            label: const Text('Continue with Google'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
        
        const SizedBox(height: 12),
        
        // Apple Login Button (iOS only)
        if (Theme.of(context).platform == TargetPlatform.iOS) ...[
          SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: () => _handleAppleLogin(context),
              icon: Icon(
                Icons.apple,
                color: colorScheme.onSurface,
              ),
              label: const Text('Continue with Apple'),
              style: OutlinedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                side: BorderSide(
                  color: colorScheme.outline.withOpacity(0.3),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],
        
        // Facebook Login Button
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: () => _handleFacebookLogin(context),
            icon: Icon(
              Icons.facebook,
              color: const Color(0xFF1877F2),
            ),
            label: const Text('Continue with Facebook'),
            style: OutlinedButton.styleFrom(
              padding: const EdgeInsets.symmetric(vertical: 16),
              side: BorderSide(
                color: colorScheme.outline.withOpacity(0.3),
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildGoogleIcon() {
    return Container(
      width: 20,
      height: 20,
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/icons/google.png'),
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  Future<void> _handleGoogleLogin(BuildContext context) async {
    try {
      AppLogger.userAction('Google login attempted');
      
      // TODO: Implement Google Sign-In
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google login coming soon!'),
          backgroundColor: Colors.orange,
        ),
      );
      
      AppLogger.info('Google login not yet implemented');
    } catch (e) {
      AppLogger.error('Google login error', error: e);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Google login failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleAppleLogin(BuildContext context) async {
    try {
      AppLogger.userAction('Apple login attempted');
      
      // TODO: Implement Apple Sign-In
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Apple login coming soon!'),
          backgroundColor: Colors.orange,
        ),
      );
      
      AppLogger.info('Apple login not yet implemented');
    } catch (e) {
      AppLogger.error('Apple login error', error: e);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Apple login failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }

  Future<void> _handleFacebookLogin(BuildContext context) async {
    try {
      AppLogger.userAction('Facebook login attempted');
      
      // TODO: Implement Facebook Login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Facebook login coming soon!'),
          backgroundColor: Colors.orange,
        ),
      );
      
      AppLogger.info('Facebook login not yet implemented');
    } catch (e) {
      AppLogger.error('Facebook login error', error: e);
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Facebook login failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}

class SocialLoginButton extends StatelessWidget {
  final String text;
  final Widget icon;
  final VoidCallback onPressed;
  final Color? backgroundColor;
  final Color? textColor;
  final Color? borderColor;

  const SocialLoginButton({
    super.key,
    required this.text,
    required this.icon,
    required this.onPressed,
    this.backgroundColor,
    this.textColor,
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton(
        onPressed: onPressed,
        style: OutlinedButton.styleFrom(
          backgroundColor: backgroundColor ?? Colors.transparent,
          foregroundColor: textColor ?? colorScheme.onSurface,
          side: BorderSide(
            color: borderColor ?? colorScheme.outline.withOpacity(0.3),
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            icon,
            const SizedBox(width: 12),
            Text(
              text,
              style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: textColor ?? colorScheme.onSurface,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
