import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';

import '../../../../core/widgets/custom_button.dart';
import '../../../../core/widgets/custom_text_field.dart';
import '../../../../core/widgets/loading_overlay.dart';
import '../../../../core/utils/logger.dart';
import '../widgets/profile_photo_picker.dart';
import '../providers/profile_provider.dart';
import '../../data/models/update_profile_model.dart';

class EditProfileScreen extends ConsumerStatefulWidget {
  const EditProfileScreen({super.key});

  @override
  ConsumerState<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends ConsumerState<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _idNumberController = TextEditingController();
  final _addressController = TextEditingController();
  final _cityController = TextEditingController();
  final _countryController = TextEditingController();
  final _postalCodeController = TextEditingController();
  final _bioController = TextEditingController();

  DateTime? _selectedDateOfBirth;
  File? _selectedImage;
  bool _hasChanges = false;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _phoneController.dispose();
    _idNumberController.dispose();
    _addressController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    _bioController.dispose();
    super.dispose();
  }

  void _loadProfileData() {
    final profile = ref.read(currentProfileProvider);
    if (profile != null) {
      _firstNameController.text = profile.firstName ?? '';
      _lastNameController.text = profile.lastName ?? '';
      _phoneController.text = profile.phoneNumber ?? '';
      _idNumberController.text = profile.idNumber ?? '';
      _addressController.text = profile.address ?? '';
      _cityController.text = profile.city ?? '';
      _countryController.text = profile.country ?? '';
      _postalCodeController.text = profile.postalCode ?? '';
      _bioController.text = profile.bio ?? '';
      _selectedDateOfBirth = profile.dateOfBirth;
    }

    // Add listeners to detect changes
    _firstNameController.addListener(_onFieldChanged);
    _lastNameController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _idNumberController.addListener(_onFieldChanged);
    _addressController.addListener(_onFieldChanged);
    _cityController.addListener(_onFieldChanged);
    _countryController.addListener(_onFieldChanged);
    _postalCodeController.addListener(_onFieldChanged);
    _bioController.addListener(_onFieldChanged);
  }

  void _onFieldChanged() {
    if (!_hasChanges) {
      setState(() {
        _hasChanges = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final profileState = ref.watch(profileProvider);
    final profile = profileState.profile;
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          if (_hasChanges || _selectedImage != null)
            TextButton(
              onPressed: profileState.isUpdating ? null : _handleSave,
              child: Text(
                'Save',
                style: TextStyle(
                  color: theme.colorScheme.primary,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      body: LoadingOverlay(
        isLoading: profileState.isUpdating,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Profile Photo Section
                ProfilePhotoPicker(
                  currentPhotoUrl: profile?.profilePhotoUrl,
                  selectedImage: _selectedImage,
                  onImageSelected: (image) {
                    setState(() {
                      _selectedImage = image;
                      _hasChanges = true;
                    });
                  },
                  onImageRemoved: () {
                    setState(() {
                      _selectedImage = null;
                      _hasChanges = true;
                    });
                  },
                  isUploading: profileState.isUploadingPhoto,
                ),
                
                const SizedBox(height: 24),
                
                // Personal Information Section
                _buildSectionHeader('Personal Information'),
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _firstNameController,
                        labelText: 'First Name',
                        prefixIcon: Icons.person_outline,
                        validator: (value) {
                          if (value == null || value.trim().isEmpty) {
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
                          if (value == null || value.trim().isEmpty) {
                            return 'Last name is required';
                          }
                          return null;
                        },
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _phoneController,
                  labelText: 'Phone Number',
                  prefixIcon: Icons.phone_outlined,
                  keyboardType: TextInputType.phone,
                  validator: (value) {
                    if (value != null && value.isNotEmpty) {
                      if (!RegExp(r'^\+?[\d\s\-\(\)]+$').hasMatch(value)) {
                        return 'Please enter a valid phone number';
                      }
                    }
                    return null;
                  },
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _idNumberController,
                  labelText: 'ID Number',
                  prefixIcon: Icons.badge_outlined,
                ),
                
                const SizedBox(height: 16),
                
                // Date of Birth
                _buildDateOfBirthField(),
                
                const SizedBox(height: 24),
                
                // Address Information Section
                _buildSectionHeader('Address Information'),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _addressController,
                  labelText: 'Address',
                  prefixIcon: Icons.home_outlined,
                  maxLines: 2,
                ),
                
                const SizedBox(height: 16),
                
                Row(
                  children: [
                    Expanded(
                      child: CustomTextField(
                        controller: _cityController,
                        labelText: 'City',
                        prefixIcon: Icons.location_city_outlined,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: CustomTextField(
                        controller: _countryController,
                        labelText: 'Country',
                        prefixIcon: Icons.public_outlined,
                      ),
                    ),
                  ],
                ),
                
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _postalCodeController,
                  labelText: 'Postal Code',
                  prefixIcon: Icons.markunread_mailbox_outlined,
                ),
                
                const SizedBox(height: 24),
                
                // Bio Section
                _buildSectionHeader('About You'),
                const SizedBox(height: 16),
                
                CustomTextField(
                  controller: _bioController,
                  labelText: 'Bio',
                  prefixIcon: Icons.description_outlined,
                  maxLines: 4,
                  hintText: 'Tell others about yourself...',
                ),
                
                const SizedBox(height: 32),
                
                // Save Button
                CustomButton(
                  text: 'Save Changes',
                  onPressed: (_hasChanges || _selectedImage != null) && !profileState.isUpdating
                      ? _handleSave
                      : null,
                  isLoading: profileState.isUpdating,
                ),
                
                const SizedBox(height: 16),
                
                // Cancel Button
                OutlinedButton(
                  onPressed: profileState.isUpdating ? null : () => context.pop(),
                  child: const Text('Cancel'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    final theme = Theme.of(context);

    return Text(
      title,
      style: theme.textTheme.titleMedium?.copyWith(
        color: theme.colorScheme.primary,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  Widget _buildDateOfBirthField() {
    final theme = Theme.of(context);

    return InkWell(
      onTap: _selectDateOfBirth,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 16),
        decoration: BoxDecoration(
          border: Border.all(
            color: theme.colorScheme.outline.withOpacity(0.5),
          ),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Icon(
              Icons.calendar_today_outlined,
              color: theme.colorScheme.onSurface.withOpacity(0.7),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                _selectedDateOfBirth != null
                    ? '${_selectedDateOfBirth!.day}/${_selectedDateOfBirth!.month}/${_selectedDateOfBirth!.year}'
                    : 'Date of Birth',
                style: theme.textTheme.bodyLarge?.copyWith(
                  color: _selectedDateOfBirth != null
                      ? theme.colorScheme.onSurface
                      : theme.colorScheme.onSurface.withOpacity(0.6),
                ),
              ),
            ),
            if (_selectedDateOfBirth != null)
              IconButton(
                icon: const Icon(Icons.clear),
                onPressed: () {
                  setState(() {
                    _selectedDateOfBirth = null;
                    _hasChanges = true;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }

  Future<void> _selectDateOfBirth() async {
    final now = DateTime.now();
    final eighteenYearsAgo = DateTime(now.year - 18, now.month, now.day);

    final date = await showDatePicker(
      context: context,
      initialDate: _selectedDateOfBirth ?? eighteenYearsAgo,
      firstDate: DateTime(1900),
      lastDate: eighteenYearsAgo,
      helpText: 'Select Date of Birth',
    );

    if (date != null) {
      setState(() {
        _selectedDateOfBirth = date;
        _hasChanges = true;
      });
    }
  }

  Future<void> _handleSave() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }

    AppLogger.userAction('Profile update initiated');

    try {
      // Upload photo first if selected
      if (_selectedImage != null) {
        final photoUploaded = await ref.read(profileProvider.notifier).uploadProfilePhoto(_selectedImage!);
        if (!photoUploaded) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: const Text('Failed to upload profile photo'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
          return;
        }
      }

      // Update profile information
      final request = UpdateProfileRequestModel(
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
        address: _addressController.text.trim().isNotEmpty
            ? _addressController.text.trim()
            : null,
        city: _cityController.text.trim().isNotEmpty
            ? _cityController.text.trim()
            : null,
        country: _countryController.text.trim().isNotEmpty
            ? _countryController.text.trim()
            : null,
        postalCode: _postalCodeController.text.trim().isNotEmpty
            ? _postalCodeController.text.trim()
            : null,
        dateOfBirth: _selectedDateOfBirth?.toIso8601String(),
        bio: _bioController.text.trim().isNotEmpty
            ? _bioController.text.trim()
            : null,
      );

      final success = await ref.read(profileProvider.notifier).updateProfile(request);

      if (success) {
        AppLogger.userAction('Profile updated successfully');

        setState(() {
          _hasChanges = false;
          _selectedImage = null;
        });

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );

          context.pop();
        }
      } else {
        final error = ref.read(profileErrorProvider);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to update profile: ${error ?? 'Unknown error'}'),
              backgroundColor: Theme.of(context).colorScheme.error,
            ),
          );
        }
      }
    } catch (e) {
      AppLogger.error('Profile update failed', error: e);

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to update profile: ${e.toString()}'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    }
  }
}
