import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../data/models/login_request_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/social_login_buttons.dart';

// Route constants for better maintainability
const String _homeRoute = '/home';
const String _forgotPasswordRoute = '/forgot-password';
const String _registerRoute = '/register';

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
      context.go(_homeRoute);
    } else {
      // Error is handled by the provider and shown in the UI
      AppLogger.userAction('Login failed');
    }
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    
    ref.listen(authProvider, (_, state) {
      if (state.error != null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.error!),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    });

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
                    validator: Validators.usernameOrEmail,
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
                    validator: (value) => Validators.password(value, minLength: 6),
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
                          context.push(_forgotPasswordRoute);
                        },
                        child: const Text('Forgot Password?'),
                      ),
                    ],
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Login Button
                  CustomButton(
                    text: 'Sign In',
                    onPressed: _handleLogin,
                    isLoading: authState.isLoading,
                  ),
                  
                  const SizedBox(height: 24),
                  
                  // Divider
                  const Row(
                    children: [
                      Expanded(child: Divider()),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 16),
                        child: Text(
                          'OR',
                        ),
                      ),
                      Expanded(child: Divider()),
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
                          context.push(_registerRoute);
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
