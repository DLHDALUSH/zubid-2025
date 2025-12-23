import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/services/storage_service.dart';
import '../../../core/utils/logger.dart';
import '../data/models/user_model.dart';
import '../data/models/auth_response_model.dart';
import '../data/repositories/auth_repository.dart';

// Auth state
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final UserModel? user;
  final String? error;

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.user,
    this.error,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    UserModel? user,
    String? error,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error,
    );
  }

  @override
  String toString() {
    return 'AuthState(isLoading: $isLoading, isAuthenticated: $isAuthenticated, user: ${user?.username}, error: $error)';
  }
}

// Auth provider
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState()) {
    _checkAuthStatus();
  }

  /// Check if user is already authenticated
  Future<void> _checkAuthStatus() async {
    try {
      state = state.copyWith(isLoading: true);
      
      final isLoggedIn = await StorageService.isLoggedIn();
      if (isLoggedIn) {
        final user = await StorageService.getUserData();
        if (user != null) {
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            user: user,
          );
          AppLogger.auth('User already authenticated', userId: user.id.toString());
          return;
        }
      }
      
      state = state.copyWith(isLoading: false);
    } catch (e) {
      AppLogger.error('Error checking auth status', error: e);
      state = state.copyWith(isLoading: false);
    }
  }

  /// Login user
  Future<bool> login(String username, String password, {bool rememberMe = false}) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final request = LoginRequestModel(
        username: username,
        password: password,
        rememberMe: rememberMe,
      );
      
      final result = await _authRepository.login(request);
      
      if (result.isSuccess) {
        final authResponse = result.data!;
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: authResponse.user,
        );
        AppLogger.auth('Login successful', userId: authResponse.user?.id.toString());
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
        AppLogger.auth('Login failed', success: false);
        return false;
      }
    } catch (e) {
      AppLogger.error('Login error', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred during login',
      );
      return false;
    }
  }

  /// Register user
  Future<bool> register({
    required String username,
    required String email,
    required String password,
    required String confirmPassword,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? idNumber,
    bool acceptTerms = false,
  }) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final request = RegisterRequestModel(
        username: username,
        email: email,
        password: password,
        confirmPassword: confirmPassword,
        firstName: firstName,
        lastName: lastName,
        phoneNumber: phoneNumber,
        idNumber: idNumber,
        acceptTerms: acceptTerms,
      );
      
      final result = await _authRepository.register(request);
      
      if (result.isSuccess) {
        final authResponse = result.data!;
        
        // If auto-login after registration
        if (authResponse.user != null) {
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            user: authResponse.user,
          );
        } else {
          state = state.copyWith(isLoading: false);
        }
        
        AppLogger.auth('Registration successful', userId: username);
        return true;
      } else {
        state = state.copyWith(
          isLoading: false,
          error: result.message,
        );
        AppLogger.auth('Registration failed', success: false);
        return false;
      }
    } catch (e) {
      AppLogger.error('Registration error', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred during registration',
      );
      return false;
    }
  }

  /// Forgot password
  Future<bool> forgotPassword(String email) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final request = ForgotPasswordRequestModel(email: email);
      final result = await _authRepository.forgotPassword(request);
      
      state = state.copyWith(isLoading: false);
      
      if (result.isSuccess) {
        AppLogger.auth('Forgot password request sent');
        return true;
      } else {
        state = state.copyWith(error: result.message);
        return false;
      }
    } catch (e) {
      AppLogger.error('Forgot password error', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Reset password
  Future<bool> resetPassword(String token, String password, String confirmPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final request = ResetPasswordRequestModel(
        token: token,
        password: password,
        confirmPassword: confirmPassword,
      );
      
      final result = await _authRepository.resetPassword(request);
      
      state = state.copyWith(isLoading: false);
      
      if (result.isSuccess) {
        AppLogger.auth('Password reset successful');
        return true;
      } else {
        state = state.copyWith(error: result.message);
        return false;
      }
    } catch (e) {
      AppLogger.error('Reset password error', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Change password
  Future<bool> changePassword(String currentPassword, String newPassword, String confirmPassword) async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      final request = ChangePasswordRequestModel(
        currentPassword: currentPassword,
        newPassword: newPassword,
        confirmPassword: confirmPassword,
      );
      
      final result = await _authRepository.changePassword(request);
      
      state = state.copyWith(isLoading: false);
      
      if (result.isSuccess) {
        AppLogger.auth('Password changed successfully');
        return true;
      } else {
        state = state.copyWith(error: result.message);
        return false;
      }
    } catch (e) {
      AppLogger.error('Change password error', error: e);
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      return false;
    }
  }

  /// Refresh current user data
  Future<void> refreshUser() async {
    try {
      final result = await _authRepository.getCurrentUser();
      
      if (result.isSuccess) {
        state = state.copyWith(user: result.data);
        AppLogger.auth('User data refreshed');
      }
    } catch (e) {
      AppLogger.error('Error refreshing user data', error: e);
    }
  }

  /// Logout user
  Future<void> logout() async {
    try {
      state = state.copyWith(isLoading: true);
      
      await _authRepository.logout();
      
      state = const AuthState();
      AppLogger.auth('Logout completed');
    } catch (e) {
      AppLogger.error('Logout error', error: e);
      // Clear state anyway
      state = const AuthState();
    }
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }

  /// Update user data
  void updateUser(UserModel user) {
    state = state.copyWith(user: user);
  }
}

// Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  return AuthNotifier(ref.read(authRepositoryProvider));
});

// Convenience providers
final isAuthenticatedProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isAuthenticated;
});

final currentUserProvider = Provider<UserModel?>((ref) {
  return ref.watch(authProvider).user;
});

final authLoadingProvider = Provider<bool>((ref) {
  return ref.watch(authProvider).isLoading;
});

final authErrorProvider = Provider<String?>((ref) {
  return ref.watch(authProvider).error;
});
