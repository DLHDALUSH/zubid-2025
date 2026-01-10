// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'admin_stats_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AdminStatsModel _$AdminStatsModelFromJson(Map<String, dynamic> json) =>
    AdminStatsModel(
      totalUsers: (json['total_users'] as num).toInt(),
      totalAdmins: (json['total_admins'] as num).toInt(),
      totalAuctions: (json['total_auctions'] as num).toInt(),
      activeAuctions: (json['active_auctions'] as num).toInt(),
      endedAuctions: (json['ended_auctions'] as num).toInt(),
      totalBids: (json['total_bids'] as num).toInt(),
      recentUsers: (json['recent_users'] as num).toInt(),
    );

Map<String, dynamic> _$AdminStatsModelToJson(AdminStatsModel instance) =>
    <String, dynamic>{
      'total_users': instance.totalUsers,
      'total_admins': instance.totalAdmins,
      'total_auctions': instance.totalAuctions,
      'active_auctions': instance.activeAuctions,
      'ended_auctions': instance.endedAuctions,
      'total_bids': instance.totalBids,
      'recent_users': instance.recentUsers,
    };
