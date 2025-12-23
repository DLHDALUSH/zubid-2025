// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'auction_search_filters.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

AuctionSearchFilters _$AuctionSearchFiltersFromJson(
        Map<String, dynamic> json) =>
    AuctionSearchFilters(
      categoryId: (json['category_id'] as num?)?.toInt(),
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      condition: json['condition'] as String?,
      location: json['location'] as String?,
      hasBuyNow: json['has_buy_now'] as bool?,
      endingSoon: json['ending_soon'] as bool?,
      featuredOnly: json['featured_only'] as bool?,
      hasReserve: json['has_reserve'] as bool?,
      newlyListed: json['newly_listed'] as bool?,
      watchedOnly: json['watched_only'] as bool?,
      sortBy: json['sort_by'] as String?,
      sortOrder: json['sort_order'] as String?,
      searchQuery: json['searchQuery'] as String?,
    );

Map<String, dynamic> _$AuctionSearchFiltersToJson(
        AuctionSearchFilters instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'min_price': instance.minPrice,
      'max_price': instance.maxPrice,
      'condition': instance.condition,
      'location': instance.location,
      'has_buy_now': instance.hasBuyNow,
      'ending_soon': instance.endingSoon,
      'featured_only': instance.featuredOnly,
      'has_reserve': instance.hasReserve,
      'newly_listed': instance.newlyListed,
      'watched_only': instance.watchedOnly,
      'sort_by': instance.sortBy,
      'sort_order': instance.sortOrder,
      'searchQuery': instance.searchQuery,
    };
