import 'dart:io';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/logger.dart';
import '../data/models/profile_model.dart';
import '../data/models/update_profile_model.dart';
import '../data/repositories/profile_repository.dart';

// Profile State
class ProfileState {
  final ProfileModel? profile;
  final bool isLoading;
  final String? error;
  final bool isUpdating;
  final bool isUploadingPhoto;

  const ProfileState({
    this.profile,
    this.isLoading = false,
    this.error,
    this.isUpdating = false,
    this.isUploadingPhoto = false,
  });

  ProfileState copyWith({
    ProfileModel? profile,
    bool? isLoading,
    String? error,
    bool? isUpdating,
    bool? isUploadingPhoto,
  }) {
    return ProfileState(
      profile: profile ?? this.profile,
      isLoading: isLoading ?? this.isLoading,
      error: error,
      isUpdating: isUpdating ?? this.isUpdating,
      isUploadingPhoto: isUploadingPhoto ?? this.isUploadingPhoto,
    );
  }

  bool get hasProfile => profile != null;
  bool get hasError => error != null;
  bool get isProfileComplete => profile?.isProfileComplete ?? false;
  double get profileCompletionPercentage => profile?.profileCompletionPercentage ?? 0.0;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileState &&
          runtimeType == other.runtimeType &&
          profile == other.profile &&
          isLoading == other.isLoading &&
          error == other.error &&
          isUpdating == other.isUpdating &&
          isUploadingPhoto == other.isUploadingPhoto;

  @override
  int get hashCode =>
      profile.hashCode ^
      isLoading.hashCode ^
      error.hashCode ^
      isUpdating.hashCode ^
      isUploadingPhoto.hashCode;

  @override
  String toString() =>
      'ProfileState(profile: $profile, isLoading: $isLoading, error: $error, isUpdating: $isUpdating, isUploadingPhoto: $isUploadingPhoto)';
}

// Profile Notifier
class ProfileNotifier extends StateNotifier<ProfileState> {
  final ProfileRepository _profileRepository;

  ProfileNotifier(this._profileRepository) : super(const ProfileState());

  /// Load user profile
  Future<void> loadProfile() async {
    if (state.isLoading) return;

    state = state.copyWith(isLoading: true, error: null);

    try {
      AppLogger.info('Loading user profile');

      final result = await _profileRepository.getProfile();

      result.fold(
        (error) {
          AppLogger.error('Failed to load profile', error: error);
          state = state.copyWith(isLoading: false, error: error);
        },
        (profile) {
          AppLogger.info('Profile loaded successfully');
          state = state.copyWith(isLoading: false, profile: profile);
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error loading profile', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'Failed to load profile: ${e.toString()}',
      );
    }
  }

  /// Update user profile
  Future<bool> updateProfile(UpdateProfileRequestModel request) async {
    if (state.isUpdating) return false;

    state = state.copyWith(isUpdating: true, error: null);

    try {
      AppLogger.info('Updating user profile');

      final result = await _profileRepository.updateProfile(request);

      return result.fold(
        (error) {
          AppLogger.error('Failed to update profile', error: error);
          state = state.copyWith(isUpdating: false, error: error);
          return false;
        },
        (profile) {
          AppLogger.info('Profile updated successfully');
          state = state.copyWith(isUpdating: false, profile: profile);
          return true;
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error updating profile', error: e);
      state = state.copyWith(
        isUpdating: false,
        error: 'Failed to update profile: ${e.toString()}',
      );
      return false;
    }
  }

  /// Upload profile photo
  Future<bool> uploadProfilePhoto(File imageFile) async {
    if (state.isUploadingPhoto) return false;

    state = state.copyWith(isUploadingPhoto: true, error: null);

    try {
      AppLogger.info('Uploading profile photo');

      final result = await _profileRepository.uploadProfilePhoto(imageFile);

      return result.fold(
        (error) {
          AppLogger.error('Failed to upload photo', error: error);
          state = state.copyWith(isUploadingPhoto: false, error: error);
          return false;
        },
        (photoUrl) {
          AppLogger.info('Photo uploaded successfully');
          
          // Update profile with new photo URL
          if (state.profile != null) {
            final updatedProfile = state.profile!.copyWith(profilePhotoUrl: photoUrl);
            state = state.copyWith(isUploadingPhoto: false, profile: updatedProfile);
          } else {
            state = state.copyWith(isUploadingPhoto: false);
          }
          
          return true;
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error uploading photo', error: e);
      state = state.copyWith(
        isUploadingPhoto: false,
        error: 'Failed to upload photo: ${e.toString()}',
      );
      return false;
    }
  }

  /// Delete profile photo
  Future<bool> deleteProfilePhoto() async {
    if (state.isUploadingPhoto) return false;

    state = state.copyWith(isUploadingPhoto: true, error: null);

    try {
      AppLogger.info('Deleting profile photo');

      final result = await _profileRepository.deleteProfilePhoto();

      return result.fold(
        (error) {
          AppLogger.error('Failed to delete photo', error: error);
          state = state.copyWith(isUploadingPhoto: false, error: error);
          return false;
        },
        (_) {
          AppLogger.info('Photo deleted successfully');
          
          // Update profile to remove photo URL
          if (state.profile != null) {
            final updatedProfile = state.profile!.copyWith(profilePhotoUrl: null);
            state = state.copyWith(isUploadingPhoto: false, profile: updatedProfile);
          } else {
            state = state.copyWith(isUploadingPhoto: false);
          }
          
          return true;
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error deleting photo', error: e);
      state = state.copyWith(
        isUploadingPhoto: false,
        error: 'Failed to delete photo: ${e.toString()}',
      );
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    state = state.copyWith(error: null);

    try {
      AppLogger.info('Changing password');

      final result = await _profileRepository.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
      );

      return result.fold(
        (error) {
          AppLogger.error('Failed to change password', error: error);
          state = state.copyWith(error: error);
          return false;
        },
        (_) {
          AppLogger.info('Password changed successfully');
          return true;
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error changing password', error: e);
      state = state.copyWith(error: 'Failed to change password: ${e.toString()}');
      return false;
    }
  }

  /// Verify email
  Future<bool> verifyEmail(String token) async {
    try {
      AppLogger.info('Verifying email');

      final result = await _profileRepository.verifyEmail(token);

      return result.fold(
        (error) {
          AppLogger.error('Failed to verify email', error: error);
          state = state.copyWith(error: error);
          return false;
        },
        (_) {
          AppLogger.info('Email verified successfully');
          
          // Update profile to mark email as verified
          if (state.profile != null) {
            final updatedProfile = state.profile!.copyWith(emailVerified: true);
            state = state.copyWith(profile: updatedProfile);
          }
          
          return true;
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error verifying email', error: e);
      state = state.copyWith(error: 'Failed to verify email: ${e.toString()}');
      return false;
    }
  }

  /// Resend email verification
  Future<bool> resendEmailVerification() async {
    try {
      AppLogger.info('Resending email verification');

      final result = await _profileRepository.resendEmailVerification();

      return result.fold(
        (error) {
          AppLogger.error('Failed to resend verification', error: error);
          state = state.copyWith(error: error);
          return false;
        },
        (_) {
          AppLogger.info('Email verification resent successfully');
          return true;
        },
      );
    } catch (e) {
      AppLogger.error('Unexpected error resending verification', error: e);
      state = state.copyWith(error: 'Failed to resend verification: ${e.toString()}');
      return false;
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Refresh profile
  Future<void> refreshProfile() async {
    await loadProfile();
  }
}

// Providers
final profileProvider = StateNotifierProvider<ProfileNotifier, ProfileState>((ref) {
  final repository = ref.read(profileRepositoryProvider);
  return ProfileNotifier(repository);
});

// Convenience providers
final currentProfileProvider = Provider<ProfileModel?>((ref) {
  return ref.watch(profileProvider).profile;
});

final profileLoadingProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).isLoading;
});

final profileErrorProvider = Provider<String?>((ref) {
  return ref.watch(profileProvider).error;
});

final profileCompletionProvider = Provider<double>((ref) {
  return ref.watch(profileProvider).profileCompletionPercentage;
});

final isProfileCompleteProvider = Provider<bool>((ref) {
  return ref.watch(profileProvider).isProfileComplete;
});
