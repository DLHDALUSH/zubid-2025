import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/network/api_client.dart';
import '../repositories/auction_repository.dart';
import '../repositories/bidding_repository.dart';

final auctionRepositoryProvider = Provider<AuctionRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return AuctionRepository(apiClient);
});

final biddingRepositoryProvider = Provider<BiddingRepository>((ref) {
  final apiClient = ref.read(apiClientProvider);
  return BiddingRepository(apiClient);
});
