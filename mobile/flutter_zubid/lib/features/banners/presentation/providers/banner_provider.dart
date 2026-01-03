import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../data/models/banner_model.dart';
import '../../data/repositories/banner_repository.dart';

// Repository provider
final bannerRepositoryProvider = Provider<BannerRepository>((ref) {
  return BannerRepository();
});

// Banner state
class BannerState {
  final List<BannerModel> banners;
  final bool isLoading;
  final String? error;

  BannerState({
    this.banners = const [],
    this.isLoading = false,
    this.error,
  });

  BannerState copyWith({
    List<BannerModel>? banners,
    bool? isLoading,
    String? error,
  }) {
    return BannerState(
      banners: banners ?? this.banners,
      isLoading: isLoading ?? this.isLoading,
      error: error,
    );
  }
}

// Banner notifier
class BannerNotifier extends StateNotifier<BannerState> {
  final BannerRepository _repository;

  BannerNotifier(this._repository) : super(BannerState());

  Future<void> loadBanners() async {
    if (state.isLoading) return;
    
    state = state.copyWith(isLoading: true, error: null);
    
    try {
      final banners = await _repository.getBanners();
      state = state.copyWith(banners: banners, isLoading: false);
    } catch (e) {
      state = state.copyWith(error: e.toString(), isLoading: false);
    }
  }

  Future<void> refresh() async {
    state = state.copyWith(isLoading: false);
    await loadBanners();
  }
}

// Main provider
final bannerProvider = StateNotifierProvider<BannerNotifier, BannerState>((ref) {
  final repository = ref.watch(bannerRepositoryProvider);
  return BannerNotifier(repository);
});

