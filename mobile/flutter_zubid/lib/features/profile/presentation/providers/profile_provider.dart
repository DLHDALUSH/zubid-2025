import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/profile_model.dart';
import '../../data/models/update_profile_request_model.dart';
import '../../data/repositories/profile_repository.dart';
import '../../../../core/utils/logger.dart';

// Profile State
class ProfileState {
  final bool isLoading;
  final bool isUpdating;
  final bool isUploadingPhoto;
  final ProfileModel? profile;
  final String? error;

  const ProfileState({
    this.isLoading = false,
    this.isUpdating = false,
    this.isUploadingPhoto = false,
    this.profile,
    this.error,
  });

  // Computed properties
  bool get hasProfile => profile != null;
  bool get isProfileComplete => profile?.isComplete ?? false;
  bool get hasError => error != null;

  ProfileState copyWith({
    bool? isLoading,
    bool? isUpdating,
    bool? isUploadingPhoto,
    ProfileModel? profile,
    String? error,
  }) {
    return ProfileState(
      isLoading: isLoading ?? this.isLoading,
      isUpdating: isUpdating ?? this.isUpdating,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
      profile: profile ?? this.profile,
      error: error,
    );
  }
}

// Profile Provider (Riverpod 3.x)
class ProfileNotifier extends Notifier<ProfileState> {
  late final ProfileRepository _profileRepository;

  @override
  ProfileState build() {
    _profileRepository = ref.read(profileRepositoryProvider);
    return const ProfileState();
  }

  Future<void> loadProfile() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _profileRepository.getProfile();

      result.when(
        success: (profile) {
          state = state.copyWith(
            isLoading: false,
            profile: profile,
          );
          AppLogger.info('Profile loaded successfully');
        },
        error: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
          AppLogger.error('Failed to load profile', error: error);
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Profile loading exception', error: e);
    }
  }

  Future<bool> updateProfile(UpdateProfileRequestModel request) async {
    state = state.copyWith(isUpdating: true, error: null);

    try {
      final result = await _profileRepository.updateProfile(request);

      if (result.data != null) {
        state = state.copyWith(
          isUpdating: false,
          profile: result.data,
          error: null,
        );
        AppLogger.info('Profile updated successfully');
        return true;
      } else {
        state = state.copyWith(
          isUpdating: false,
          error: result.message ?? 'Failed to update profile',
        );
        AppLogger.error('Failed to update profile', error: result.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isUpdating: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Profile update exception', error: e);
      return false;
    }
  }

  Future<bool> uploadProfilePhoto(File imageFile) async {
    state = state.copyWith(isUploadingPhoto: true, error: null);

    try {
      final result = await _profileRepository.uploadProfilePhoto(imageFile);

      if (result.data != null) {
        // Update profile with new photo URL
        if (state.profile != null) {
          final updatedProfile = ProfileModel(
            id: state.profile!.id,
            username: state.profile!.username,
            email: state.profile!.email,
            firstName: state.profile!.firstName,
            lastName: state.profile!.lastName,
            phoneNumber: state.profile!.phoneNumber,
            profilePhotoUrl: result.data,
            idNumber: state.profile!.idNumber,
            address: state.profile!.address,
            city: state.profile!.city,
            country: state.profile!.country,
            postalCode: state.profile!.postalCode,
            dateOfBirth: state.profile!.dateOfBirth,
            bio: state.profile!.bio,
            preferredLanguage: state.profile!.preferredLanguage,
            timezone: state.profile!.timezone,
            emailVerified: state.profile!.emailVerified,
            phoneVerified: state.profile!.phoneVerified,
            profileCompleted: state.profile!.profileCompleted,
            rating: state.profile!.rating,
            totalBids: state.profile!.totalBids,
            totalWins: state.profile!.totalWins,
            totalSpent: state.profile!.totalSpent,
            memberSince: state.profile!.memberSince,
            lastActive: state.profile!.lastActive,
            preferences: state.profile!.preferences,
            createdAt: state.profile!.createdAt,
            updatedAt: DateTime.now(),
          );

          state = state.copyWith(
            isUploadingPhoto: false,
            profile: updatedProfile,
            error: null,
          );
        } else {
          state = state.copyWith(isUploadingPhoto: false, error: null);
        }

        AppLogger.info('Profile photo uploaded successfully');
        return true;
      } else {
        state = state.copyWith(
          isUploadingPhoto: false,
          error: result.message ?? 'Failed to upload profile photo',
        );
        AppLogger.error('Failed to upload profile photo',
            error: result.message);
        return false;
      }
    } catch (e) {
      state = state.copyWith(
        isUploadingPhoto: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Profile photo upload exception', error: e);
      return false;
    }
  }

  Future<void> refreshProfile() async {
    await loadProfile();
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider instance
final profileProvider = NotifierProvider<ProfileNotifier, ProfileState>(
  ProfileNotifier.new,
);

// Current profile provider (for easy access to current profile)
final currentProfileProvider = Provider<ProfileModel?>((ref) {
  return ref.watch(profileProvider).profile;
});

// Profile error provider
final profileErrorProvider = Provider<String?>((ref) {
  return ref.watch(profileProvider).error;
});
