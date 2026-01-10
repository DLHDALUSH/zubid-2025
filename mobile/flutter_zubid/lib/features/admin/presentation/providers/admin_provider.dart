import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/utils/logger.dart';
import '../../data/models/admin_stats_model.dart';
import '../../data/repositories/admin_repository.dart';

// Admin State
class AdminState {
  final bool isLoading;
  final AdminStatsModel? stats;
  final String? error;
  final DateTime? lastUpdated;

  const AdminState({
    this.isLoading = false,
    this.stats,
    this.error,
    this.lastUpdated,
  });

  AdminState copyWith({
    bool? isLoading,
    AdminStatsModel? stats,
    String? error,
    DateTime? lastUpdated,
  }) {
    return AdminState(
      isLoading: isLoading ?? this.isLoading,
      stats: stats ?? this.stats,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  bool get hasError => error != null;
  bool get hasStats => stats != null;
}

// Admin Notifier
class AdminNotifier extends StateNotifier<AdminState> {
  final AdminRepository _adminRepository;

  AdminNotifier(this._adminRepository) : super(const AdminState());

  /// Load admin statistics
  Future<void> loadStats() async {
    state = state.copyWith(isLoading: true, error: null);

    try {
      final result = await _adminRepository.getAdminStats();

      result.when(
        success: (stats) {
          state = state.copyWith(
            isLoading: false,
            stats: stats,
            lastUpdated: DateTime.now(),
          );
          AppLogger.info('Admin stats loaded successfully');
        },
        error: (error) {
          state = state.copyWith(
            isLoading: false,
            error: error,
          );
          AppLogger.error('Failed to load admin stats: $error');
        },
      );
    } catch (e) {
      state = state.copyWith(
        isLoading: false,
        error: 'An unexpected error occurred',
      );
      AppLogger.error('Admin stats loading exception', error: e);
    }
  }

  /// Refresh admin statistics
  Future<void> refreshStats() async {
    await loadStats();
  }

  /// Clear error
  void clearError() {
    state = state.copyWith(error: null);
  }
}

// Provider
final adminProvider = StateNotifierProvider<AdminNotifier, AdminState>((ref) {
  final adminRepository = ref.read(adminRepositoryProvider);
  return AdminNotifier(adminRepository);
});
