import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/utils/logger.dart';
import '../../../../core/utils/validators.dart';
import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../data/models/register_request_model.dart';
import '../providers/auth_provider.dart';
import '../widgets/auth_header.dart';
import '../widgets/social_login_buttons.dart';

// Route constants
const String _loginRoute = '/login';
const String _homeRoute = '/home';
const String _termsOfServiceRoute = '/terms-of-service';
const String _privacyPolicyRoute = '/privacy-policy';

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
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('You must accept the terms and conditions to register.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    final request = RegisterRequestModel(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      firstName: _firstNameController.text.trim(),
      lastName: _lastNameController.text.trim(),
      phoneNumber: _phoneController.text.trim(),
      acceptTerms: _acceptTerms,
    );

    final success = await ref.read(authProvider.notifier).register(request);

    if (success && mounted) {
      AppLogger.userAction('Registration successful for ${request.email}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Registration successful! Please check your email to verify your account.'),
          backgroundColor: Colors.green,
        ),
      );
      context.go(_homeRoute);
    }
    // Error state is handled by the provider and displayed in the UI
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
        body: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            child: Form(
              key: _formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const AuthHeader(
                    title: 'Create an Account',
                    subtitle: 'Start your auction journey with ZUBID',
                  ),
                  const SizedBox(height: 32),
                  _buildRegistrationForm(),
                  const SizedBox(height: 24),
                  _buildTermsCheckbox(),
                  const SizedBox(height: 32),
                  CustomButton(
                    text: 'Create Account',
                    onPressed: _handleRegister,
                    isLoading: authState.isLoading,
                  ),
                  const SizedBox(height: 24),
                  const _AuthDivider(),
                  const SizedBox(height: 24),
                  const SocialLoginButtons(),
                  const SizedBox(height: 32),
                  _buildLoginLink(),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRegistrationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CustomTextField(
          controller: _usernameController,
          label: 'Username',
          validator: Validators.username,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          label: 'Email Address',
          keyboardType: TextInputType.emailAddress,
          validator: Validators.email,
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: CustomTextField(
                controller: _firstNameController,
                label: 'First Name',
                validator: Validators.notEmpty,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _lastNameController,
                label: 'Last Name',
                validator: Validators.notEmpty,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _phoneController,
          label: 'Phone Number (Optional)',
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          label: 'Password',
          obscureText: _obscurePassword,
          validator: Validators.password,
          suffixIcon: IconButton(
            icon: Icon(_obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password',
          obscureText: _obscureConfirmPassword,
          validator: (value) => Validators.confirmPassword(value, _passwordController.text),
          suffixIcon: IconButton(
            icon: Icon(_obscureConfirmPassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () => setState(() => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
        ),
      ],
    );
  }

  Widget _buildTermsCheckbox() {
    return Row(
      children: [
        Checkbox(
          value: _acceptTerms,
          onChanged: (value) => setState(() => _acceptTerms = value ?? false),
        ),
        Expanded(
          child: RichText(
            text: TextSpan(
              text: 'I agree to the ',
              style: Theme.of(context).textTheme.bodySmall,
              children: [
                TextSpan(
                  text: 'Terms of Service',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  recognizer: TapGestureRecognizer()..onTap = () => context.push(_termsOfServiceRoute),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue),
                  recognizer: TapGestureRecognizer()..onTap = () => context.push(_privacyPolicyRoute),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildLoginLink() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text("Already have an account?"),
        TextButton(
          onPressed: () => context.go(_loginRoute),
          child: const Text('Sign In'),
        ),
      ],
    );
  }
}

class _AuthDivider extends StatelessWidget {
  const _AuthDivider();

  @override
  Widget build(BuildContext context) {
    return Row(
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
    );
  }
}
