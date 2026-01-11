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
  final _idNumberController = TextEditingController();
  final _addressController = TextEditingController();
  DateTime? _selectedBirthDate;

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
    _addressController.dispose();
    super.dispose();
  }

  Future<void> _handleRegister() async {
    if (!_formKey.currentState!.validate()) return;

    if (_selectedBirthDate == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select your date of birth.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    if (!_acceptTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content:
              Text('You must accept the terms and conditions to register.'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    // Format birth date as YYYY-MM-DD
    final birthDateStr =
        '${_selectedBirthDate!.year}-${_selectedBirthDate!.month.toString().padLeft(2, '0')}-${_selectedBirthDate!.day.toString().padLeft(2, '0')}';

    final request = RegisterRequestModel(
      username: _usernameController.text.trim(),
      email: _emailController.text.trim(),
      password: _passwordController.text,
      phoneNumber: _phoneController.text.trim(),
      idNumber: _idNumberController.text.trim(),
      birthDate: birthDateStr,
      address: _addressController.text.trim(),
      firstName: _firstNameController.text.trim().isNotEmpty
          ? _firstNameController.text.trim()
          : null,
      lastName: _lastNameController.text.trim().isNotEmpty
          ? _lastNameController.text.trim()
          : null,
      acceptTerms: _acceptTerms,
    );

    final success = await ref.read(authProvider.notifier).register(request);

    if (success && mounted) {
      AppLogger.userAction('Registration successful for ${request.email}');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text(
              'Registration successful! Please check your email to verify your account.'),
          backgroundColor: Colors.green,
        ),
      );
      context.go(_homeRoute);
    }
    // Error state is handled by the provider and displayed in the UI
  }

  Future<void> _selectBirthDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedBirthDate ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1900),
      lastDate: DateTime.now()
          .subtract(const Duration(days: 365 * 18)), // Must be 18+
      helpText: 'Select your date of birth',
    );
    if (picked != null && picked != _selectedBirthDate) {
      setState(() {
        _selectedBirthDate = picked;
      });
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
          label: 'Username *',
          validator: Validators.username,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _emailController,
          label: 'Email Address *',
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
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: CustomTextField(
                controller: _lastNameController,
                label: 'Last Name',
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _phoneController,
          label: 'Phone Number *',
          keyboardType: TextInputType.phone,
          validator: Validators.phone,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _idNumberController,
          label: 'ID Number *',
          validator: Validators.notEmpty,
        ),
        const SizedBox(height: 16),
        // Birth Date Picker
        InkWell(
          onTap: _selectBirthDate,
          child: InputDecorator(
            decoration: InputDecoration(
              labelText: 'Date of Birth *',
              border: const OutlineInputBorder(),
              suffixIcon: const Icon(Icons.calendar_today),
              errorText: _selectedBirthDate == null ? null : null,
            ),
            child: Text(
              _selectedBirthDate != null
                  ? '${_selectedBirthDate!.day}/${_selectedBirthDate!.month}/${_selectedBirthDate!.year}'
                  : 'Select your date of birth',
              style: TextStyle(
                color: _selectedBirthDate != null
                    ? Theme.of(context).textTheme.bodyLarge?.color
                    : Theme.of(context).hintColor,
              ),
            ),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _addressController,
          label: 'Address *',
          validator: (value) {
            if (value == null || value.isEmpty) return 'Address is required';
            if (value.length < 5) {
              return 'Address must be at least 5 characters';
            }
            return null;
          },
          maxLines: 2,
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _passwordController,
          label: 'Password *',
          obscureText: _obscurePassword,
          validator: Validators.password,
          suffixIcon: IconButton(
            icon: Icon(
                _obscurePassword ? Icons.visibility_off : Icons.visibility),
            onPressed: () =>
                setState(() => _obscurePassword = !_obscurePassword),
          ),
        ),
        const SizedBox(height: 16),
        CustomTextField(
          controller: _confirmPasswordController,
          label: 'Confirm Password *',
          obscureText: _obscureConfirmPassword,
          validator: (value) =>
              Validators.confirmPassword(value, _passwordController.text),
          suffixIcon: IconButton(
            icon: Icon(_obscureConfirmPassword
                ? Icons.visibility_off
                : Icons.visibility),
            onPressed: () => setState(
                () => _obscureConfirmPassword = !_obscureConfirmPassword),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '* Required fields',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).hintColor,
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
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => context.push(_termsOfServiceRoute),
                ),
                const TextSpan(text: ' and '),
                TextSpan(
                  text: 'Privacy Policy',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, color: Colors.blue),
                  recognizer: TapGestureRecognizer()
                    ..onTap = () => context.push(_privacyPolicyRoute),
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
