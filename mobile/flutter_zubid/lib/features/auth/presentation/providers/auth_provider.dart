import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/login_request_model.dart';
import '../../data/models/register_request_model.dart';
import '../../data/models/forgot_password_request_model.dart';
import '../../data/repositories/auth_repository.dart';
import '../../../../core/utils/logger.dart';

// Auth State
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final String? error;
  final String? token;
  final String? userId;
  final dynamic user; // Add user property

  const AuthState({
    this.isLoading = false,
    this.isAuthenticated = false,
    this.error,
    this.token,
    this.userId,
    this.user,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    String? error,
    String? token,
    String? userId,
    dynamic user,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      error: error,
      token: token ?? this.token,
      userId: userId ?? this.userId,
      user: user ?? this.user,
    );
  }
}

// Auth Provider
class AuthNotifier extends StateNotifier<AuthState> {
  final AuthRepository _authRepository;

  AuthNotifier(this._authRepository) : super(const AuthState());

  Future<bool> login(LoginRequestModel request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authRepository.login(request);
      
      return result.when(
        success: (response) {
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            token: response.token,
            userId: response.user?.id.toString(),
            user: response.user,
          );
          AppLogger.info('Login successful for user: ${response.user?.email}');
          return true;
        },
        error: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
          AppLogger.error('Login failed', error: error);
          return false;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Login exception', error: e);
      return false;
    }
  }

  Future<bool> register(RegisterRequestModel request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authRepository.register(request);
      
      return result.when(
        success: (response) {
          state = state.copyWith(
            isLoading: false,
            isAuthenticated: true,
            token: response.token,
            userId: response.user?.id.toString(),
            user: response.user,
          );
          AppLogger.info('Registration successful for user: ${response.user?.email}');
          return true;
        },
        error: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
          AppLogger.error('Registration failed', error: error);
          return false;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Registration exception', error: e);
      return false;
    }
  }

  Future<bool> forgotPassword(ForgotPasswordRequestModel request) async {
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final result = await _authRepository.forgotPassword(request);
      
      return result.when(
        success: (success) {
          state = state.copyWith(isLoading: false);
          AppLogger.info('Password reset email sent to: ${request.email}');
          return true;
        },
        error: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
          AppLogger.error('Forgot password failed', error: error);
          return false;
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Forgot password exception', error: e);
      return false;
    }
  }

  Future<void> logout() async {
    try {
      await _authRepository.logout();
      state = const AuthState();
      AppLogger.info('User logged out successfully');
    } catch (e) {
      AppLogger.error('Logout failed', error: e);
    }
  }

  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider instance
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final authRepository = ref.read(authRepositoryProvider);
  return AuthNotifier(authRepository);
});
