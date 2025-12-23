import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/utils/logger.dart';
import '../../data/models/auction_model.dart';
import '../../data/repositories/auction_creation_repository.dart';

class MyAuctionsState {
  final bool isLoading;
  final String? error;
  final List<AuctionModel> auctions;
  final bool hasMoreData;
  final int currentPage;

  const MyAuctionsState({
    this.isLoading = false,
    this.error,
    this.auctions = const [],
    this.hasMoreData = true,
    this.currentPage = 1,
  });

  MyAuctionsState copyWith({
    bool? isLoading,
    String? error,
    List<AuctionModel>? auctions,
    bool? hasMoreData,
    int? currentPage,
  }) {
    return MyAuctionsState(
      isLoading: isLoading ?? this.isLoading,
      error: error,
      auctions: auctions ?? this.auctions,
      hasMoreData: hasMoreData ?? this.hasMoreData,
      currentPage: currentPage ?? this.currentPage,
    );
  }

  bool get hasError => error != null;
}

class MyAuctionsNotifier extends StateNotifier<MyAuctionsState> {
  final AuctionCreationRepository _repository;

  MyAuctionsNotifier(this._repository) : super(const MyAuctionsState());

  Future<void> loadAuctions({bool refresh = false}) async {
    if (refresh) {
      state = const MyAuctionsState(isLoading: true);
    } else if (state.isLoading) {
      return; // Already loading
    } else {
      state = state.copyWith(isLoading: true, error: null);
    }

    final result = await _repository.getUserAuctions(
      page: refresh ? 1 : state.currentPage,
      limit: 20,
    );

    result.when(
      success: (auctions) {
        if (refresh) {
          state = MyAuctionsState(
            isLoading: false,
            auctions: auctions,
            hasMoreData: auctions.length >= 20,
            currentPage: 1,
          );
        } else {
          final allAuctions = [...state.auctions, ...auctions];
          state = state.copyWith(
            isLoading: false,
            auctions: allAuctions,
            hasMoreData: auctions.length >= 20,
            currentPage: state.currentPage + 1,
          );
        }
        AppLogger.info('Loaded ${auctions.length} user auctions');
      },
      error: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        AppLogger.error('Failed to load user auctions: $error');
      },
    );
  }

  Future<void> refreshAuctions() async {
    await loadAuctions(refresh: true);
  }

  Future<void> loadMoreAuctions() async {
    if (!state.hasMoreData || state.isLoading) return;
    await loadAuctions();
  }

  Future<bool> deleteAuction(int auctionId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.deleteAuction(auctionId);

    return result.when(
      success: (success) {
        // Remove the auction from the list
        final updatedAuctions = state.auctions
            .where((auction) => auction.id != auctionId)
            .toList();
        
        state = state.copyWith(
          isLoading: false,
          auctions: updatedAuctions,
        );
        
        AppLogger.info('Auction deleted successfully: $auctionId');
        return true;
      },
      error: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        AppLogger.error('Failed to delete auction: $error');
        return false;
      },
    );
  }

  Future<bool> endAuctionEarly(int auctionId) async {
    state = state.copyWith(isLoading: true, error: null);

    final result = await _repository.endAuctionEarly(auctionId);

    return result.when(
      success: (updatedAuction) {
        // Update the auction in the list
        final updatedAuctions = state.auctions.map((auction) {
          return auction.id == auctionId ? updatedAuction : auction;
        }).toList();
        
        state = state.copyWith(
          isLoading: false,
          auctions: updatedAuctions,
        );
        
        AppLogger.info('Auction ended early successfully: $auctionId');
        return true;
      },
      error: (error) {
        state = state.copyWith(
          isLoading: false,
          error: error,
        );
        AppLogger.error('Failed to end auction early: $error');
        return false;
      },
    );
  }

  void clearError() {
    state = state.copyWith(error: null);
  }

  void addAuction(AuctionModel auction) {
    final updatedAuctions = [auction, ...state.auctions];
    state = state.copyWith(auctions: updatedAuctions);
    AppLogger.info('New auction added to list: ${auction.id}');
  }

  void updateAuction(AuctionModel updatedAuction) {
    final updatedAuctions = state.auctions.map((auction) {
      return auction.id == updatedAuction.id ? updatedAuction : auction;
    }).toList();
    
    state = state.copyWith(auctions: updatedAuctions);
    AppLogger.info('Auction updated in list: ${updatedAuction.id}');
  }
}

// Providers
final myAuctionsProvider = StateNotifierProvider<MyAuctionsNotifier, MyAuctionsState>((ref) {
  final repository = ref.read(auctionCreationRepositoryProvider);
  return MyAuctionsNotifier(repository);
});

// Filtered providers for different auction statuses
final activeAuctionsProvider = Provider<List<AuctionModel>>((ref) {
  final auctions = ref.watch(myAuctionsProvider).auctions;
  return auctions.where((auction) => auction.isActive).toList();
});

final endedAuctionsProvider = Provider<List<AuctionModel>>((ref) {
  final auctions = ref.watch(myAuctionsProvider).auctions;
  return auctions.where((auction) => auction.hasEnded && !(auction.hasSold ?? false)).toList();
});

final soldAuctionsProvider = Provider<List<AuctionModel>>((ref) {
  final auctions = ref.watch(myAuctionsProvider).auctions;
  return auctions.where((auction) => auction.hasSold ?? false).toList();
});

final draftAuctionsProvider = Provider<List<AuctionModel>>((ref) {
  final auctions = ref.watch(myAuctionsProvider).auctions;
  return auctions.where((auction) => auction.status == 'draft').toList();
});
