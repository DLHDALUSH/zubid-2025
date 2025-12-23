import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../data/models/login_request_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/social_login_buttons.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _passwordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _rememberMe = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    AppLogger.userAction('Login attempt', parameters: {
      'username': _usernameController.text,
      'rememberMe': _rememberMe,
    });

    final request = LoginRequestModel(
      username: _usernameController.text.trim(),
      password: _passwordController.text,
      rememberMe: _rememberMe,
    );

    final success = await ref.read(authProvider.notifier).login(request);

    if (success && mounted) {
      AppLogger.userAction('Login successful - navigating to home');
      context.go('/home');
    } else {
      // Error is handled by the provider and shown in UI
      AppLogger.userAction('Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    return LoadingOverlay(
      isLoading: authState.isLoading,
      child: Scaffold(
        backgroundColor: Theme.of(context).colorScheme.surface,
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 40),
                  
                  // Header
                  const AuthHeader(
                    title: 'Welcome Back',
                    subtitle: 'Sign in to continue to ZUBID',
                  ),
                  
                  const SizedBox(height: 48),
                  
                  // Username/Email Field
                  CustomTextField(
                    controller: _usernameController,
                    label: 'Username or Email',
                    hint: 'Enter your username or email',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.emailAddress,
                    textInputAction: TextInputAction.next,
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Please enter your username or email';
                      }
                      return null;
                    },
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Password Field
                  CustomTextField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: 'Enter your password',
                    prefixIcon: Icons.lock_outline,
                    obscureText: _obscurePassword,
                    textInputAction: TextInputAction.done,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword ? Icons.visibility_off : Icons.visibility,
                      ),
                      onPressed: () {
                        setState(() {
                          _obscurePassword = !_obscurePassword;
                        });
                      },
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (value.length < 6) {
                        return 'Password must be at least 6 characters';
                      }
                      return null;
                    },
                    onSubmitted: (_) => _handleLogin(),
                  ),
                  
                  const SizedBox(height: 16),
                  
                  // Remember Me & Forgot Password Row
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (value) {
                          setState(() {
                            _rememberMe = value ?? false;
                          });
                        },
                      ),
                      const Text('Remember me'),
                      const Spacer(),
                      TextButton(
                        onPressed: () {
                          AppLogger.userAction('Forgot password tapped');
                          context.push('/auth/forgot-password');
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Error Message
                  if (authState.error != null) ...[
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(
                            Icons.error_outline,
                            color: Theme.of(context).colorScheme.error,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              authState.error!,
                              style: TextStyle(
                                color: Theme.of(context).colorScheme.error,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                  
                  // Login Button
                  CustomButton(
                    text: 'Sign In',
                    onPressed: _handleLogin,
                    isLoading: authState.isLoading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Divider
                  Row(
                    children: [
                      const Expanded(child: Divider()),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                      ),
                      const Expanded(child: Divider()),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Social Login Buttons
                  const SocialLoginButtons(),
                  
                  const SizedBox(height: 32),
                  
                  // Sign Up Link
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("Don't have an account? "),
                      TextButton(
                        onPressed: () {
                          AppLogger.userAction('Navigate to register');
                          context.push('/auth/register');
                        },
                        child: const Text('Sign Up'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
