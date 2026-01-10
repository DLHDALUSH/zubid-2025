import 'package:json_annotation/json_annotation.dart';

part 'admin_stats_model.g.dart';

@JsonSerializable()
class AdminStatsModel {
  @JsonKey(name: 'total_users')
  final int totalUsers;
  
  @JsonKey(name: 'total_admins')
  final int totalAdmins;
  
  @JsonKey(name: 'total_auctions')
  final int totalAuctions;
  
  @JsonKey(name: 'active_auctions')
  final int activeAuctions;
  
  @JsonKey(name: 'ended_auctions')
  final int endedAuctions;
  
  @JsonKey(name: 'total_bids')
  final int totalBids;
  
  @JsonKey(name: 'recent_users')
  final int recentUsers;

  const AdminStatsModel({
    required this.totalUsers,
    required this.totalAdmins,
    required this.totalAuctions,
    required this.activeAuctions,
    required this.endedAuctions,
    required this.totalBids,
    required this.recentUsers,
  });

  factory AdminStatsModel.fromJson(Map<String, dynamic> json) =>
      _$AdminStatsModelFromJson(json);

  Map<String, dynamic> toJson() => _$AdminStatsModelToJson(this);

  // Computed properties
  double get userGrowthRate => recentUsers / totalUsers * 100;
  double get auctionCompletionRate => 
      totalAuctions > 0 ? endedAuctions / totalAuctions * 100 : 0;
  double get averageBidsPerAuction => 
      totalAuctions > 0 ? totalBids / totalAuctions : 0;
}
