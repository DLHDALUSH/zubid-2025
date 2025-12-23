import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/logger.dart';
import '../widgets/auth_header.dart';
import '../widgets/social_login_buttons.dart';
import '../providers/auth_provider.dart';
import '../../data/models/auth_response_model.dart';

class RegisterScreen extends ConsumerStatefulWidget {
  const RegisterScreen({super.key});

  @override
  ConsumerState<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends ConsumerState<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _usernameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idNumberController = TextEditingController();

  bool _acceptTerms = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;

  @override
  void dispose() {
    _usernameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);
    final theme = Theme.of(context);

    return Scaffold(
      body: AuthBackground(
        child: SafeArea(
          child: LoadingOverlay(
            isLoading: authState.isLoading,
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: 20),
                    
                    // Header
                    const AuthHeader(
                      title: 'Create Account',
                      subtitle: 'Join ZUBID and start bidding on amazing items',
                    ),
                    
                    const SizedBox(height: 32),
                    
                    // Registration Form
                    _buildRegistrationForm(),
                    
                    const SizedBox(height: 24),
                    
                    // Terms and Conditions
                    _buildTermsCheckbox(),
                    
                    const SizedBox(height: 24),
                    
                    // Register Button
                    CustomButton(
                      text: 'Create Account',
                      onPressed: _acceptTerms ? _handleRegister : null,
                      isLoading: authState.isLoading,
                    ),
                    
                    const SizedBox(height: 24),
                    
                    // Divider
                    const AuthDivider(),
                    
                    const SizedBox(height: 24),
                    
                    // Social Login
                    const SocialLoginButtons(),
                    
                    const SizedBox(height: 32),
                    
                    // Login Link
                    AuthBottomText(
                      text: 'Already have an account?',
                      actionText: 'Sign In',
                      onActionPressed: () => context.go('/login'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      children: [
        // Username
        CustomTextField(
          controller: _usernameController,
          labelText: 'Username',
          prefixIcon: Icons.person_outline,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Username is required';
            }
            if (value.length < 3) {
              return 'Username must be at least 3 characters';
            }
            if (!RegExp(r'^[a-zA-Z0-9_]+$').hasMatch(value)) {
              return 'Username can only contain letters, numbers, and underscores';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // Email
        CustomTextField(
          controller: _emailController,
          labelText: 'Email',
          prefixIcon: Icons.email_outlined,
          keyboardType: TextInputType.emailAddress,
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Email is required';
            }
            if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
              return 'Please enter a valid email address';
            }
            return null;
          },
        ),
        
        const SizedBox(height: 16),
        
        // First Name and Last Name Row
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _firstNameController,
                labelText: 'First Name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'First name is required';
                  }
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _lastNameController,
                labelText: 'Last Name',
                prefixIcon: Icons.person_outline,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Last name is required';
                  }
                  return null;
                },
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        // Phone Number
        CustomTextField(
          controller: _phoneController,
          labelText: 'Phone Number (Optional)',
          prefixIcon: Icons.phone_outlined,
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 16),

        // ID Number
        CustomTextField(
          controller: _idNumberController,
          labelText: 'ID Number (Optional)',
          prefixIcon: Icons.badge_outlined,
        ),

        const SizedBox(height: 16),

        // Password
        CustomTextField(
          controller: _passwordController,
          labelText: 'Password',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscurePassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscurePassword ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _obscurePassword = !_obscurePassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Password is required';
            }
            if (value.length < 8) {
              return 'Password must be at least 8 characters';
            }
            if (!RegExp(r'^(?=.*[a-z])(?=.*[A-Z])(?=.*\d)').hasMatch(value)) {
              return 'Password must contain uppercase, lowercase, and number';
            }
            return null;
          },
        ),

        const SizedBox(height: 16),

        // Confirm Password
        CustomTextField(
          controller: _confirmPasswordController,
          labelText: 'Confirm Password',
          prefixIcon: Icons.lock_outline,
          obscureText: _obscureConfirmPassword,
          suffixIcon: IconButton(
            icon: Icon(
              _obscureConfirmPassword ? Icons.visibility : Icons.visibility_off,
            ),
            onPressed: () {
              setState(() {
                _obscureConfirmPassword = !_obscureConfirmPassword;
              });
            },
          ),
          validator: (value) {
            if (value == null || value.isEmpty) {
              return 'Please confirm your password';
            }
            if (value != _passwordController.text) {
              return 'Passwords do not match';
            }
            return null;
          },
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    final theme = Theme.of(context);

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) {
            setState(() {
              _acceptTerms = value ?? false;
            });
          },
        ),
        Expanded(
          child: GestureDetector(
            onTap: () {
              setState(() {
                _acceptTerms = !_acceptTerms;
              });
            },
            child: Text.rich(
              TextSpan(
                text: 'I agree to the ',
                style: theme.textTheme.bodyMedium,
                children: [
                  TextSpan(
                    text: 'Terms of Service',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const TextSpan(text: ' and '),
                  TextSpan(
                    text: 'Privacy Policy',
                    style: TextStyle(
                      color: theme.colorScheme.primary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please accept the Terms of Service and Privacy Policy'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    AppLogger.userAction('Registration attempted for ${_emailController.text}');

    final request = RegisterRequestModel(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      confirmPassword: _confirmPasswordController.text,
      firstName: _firstNameController.text.trim().isNotEmpty
          ? _firstNameController.text.trim()
          : null,
      lastName: _lastNameController.text.trim().isNotEmpty
          ? _lastNameController.text.trim()
          : null,
      phoneNumber: _phoneController.text.trim().isNotEmpty
          ? _phoneController.text.trim()
          : null,
      idNumber: _idNumberController.text.trim().isNotEmpty
          ? _idNumberController.text.trim()
          : null,
      acceptTerms: _acceptTerms,
    );

    try {
      await ref.read(authProvider.notifier).register(request);

      final authState = ref.read(authProvider);

      if (authState.user != null) {
        AppLogger.userAction('Registration successful for ${_emailController.text}');

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Account created successfully! Please verify your email.'),
              backgroundColor: Colors.green,
            ),
          );

          // Navigate to home or email verification screen
          context.go('/home');
        }
      }
    } catch (e) {
      AppLogger.error('Registration failed', error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Registration failed: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
