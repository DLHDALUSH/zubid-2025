import 'package:json_annotation/json_annotation.dart';

part 'auction_search_filters.g.dart';

@JsonSerializable()
class AuctionSearchFilters {
  @JsonKey(name: 'category_id')
  final int? categoryId;
  
  @JsonKey(name: 'min_price')
  final double? minPrice;
  
  @JsonKey(name: 'max_price')
  final double? maxPrice;
  
  @JsonKey(name: 'condition')
  final String? condition;
  
  @JsonKey(name: 'location')
  final String? location;
  
  @JsonKey(name: 'has_buy_now')
  final bool? hasBuyNow;
  
  @JsonKey(name: 'ending_soon')
  final bool? endingSoon;
  
  @JsonKey(name: 'featured_only')
  final bool? featuredOnly;

  @JsonKey(name: 'has_reserve')
  final bool? hasReserve;

  @JsonKey(name: 'newly_listed')
  final bool? newlyListed;

  @JsonKey(name: 'watched_only')
  final bool? watchedOnly;

  @JsonKey(name: 'sort_by')
  final String? sortBy;

  @JsonKey(name: 'sort_order')
  final String? sortOrder;

  final String? searchQuery;

  const AuctionSearchFilters({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.condition,
    this.location,
    this.hasBuyNow,
    this.endingSoon,
    this.featuredOnly,
    this.hasReserve,
    this.newlyListed,
    this.watchedOnly,
    this.sortBy,
    this.sortOrder,
    this.searchQuery,
  });

  factory AuctionSearchFilters.fromJson(Map<String, dynamic> json) => 
      _$AuctionSearchFiltersFromJson(json);
  
  Map<String, dynamic> toJson() => _$AuctionSearchFiltersToJson(this);

  bool get hasFilters {
    return categoryId != null ||
           minPrice != null ||
           maxPrice != null ||
           condition != null ||
           location != null ||
           hasBuyNow != null ||
           endingSoon != null ||
           featuredOnly != null;
  }

  AuctionSearchFilters copyWith({
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    String? condition,
    String? location,
    bool? hasBuyNow,
    bool? endingSoon,
    bool? featuredOnly,
    bool? hasReserve,
    bool? newlyListed,
    bool? watchedOnly,
    String? sortBy,
    String? sortOrder,
    String? searchQuery,
  }) {
    return AuctionSearchFilters(
      categoryId: categoryId ?? this.categoryId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      hasBuyNow: hasBuyNow ?? this.hasBuyNow,
      endingSoon: endingSoon ?? this.endingSoon,
      featuredOnly: featuredOnly ?? this.featuredOnly,
      hasReserve: hasReserve ?? this.hasReserve,
      newlyListed: newlyListed ?? this.newlyListed,
      watchedOnly: watchedOnly ?? this.watchedOnly,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
      searchQuery: searchQuery ?? this.searchQuery,
    );
  }

  AuctionSearchFilters clear() {
    return const AuctionSearchFilters();
  }

  // Computed properties
  bool get isEmpty {
    return categoryId == null &&
        minPrice == null &&
        maxPrice == null &&
        condition == null &&
        location == null &&
        hasBuyNow == null &&
        endingSoon == null &&
        featuredOnly == null &&
        sortBy == null &&
        sortOrder == null &&
        searchQuery == null;
  }

  int get activeFilterCount {
    int count = 0;
    if (categoryId != null) count++;
    if (minPrice != null) count++;
    if (maxPrice != null) count++;
    if (condition != null) count++;
    if (location != null) count++;
    if (hasBuyNow == true) count++;
    if (endingSoon == true) count++;
    if (featuredOnly == true) count++;
    if (searchQuery != null && searchQuery!.isNotEmpty) count++;
    return count;
  }

  static const AuctionSearchFilters empty = AuctionSearchFilters();

  @override
  String toString() {
    return 'AuctionSearchFilters(categoryId: $categoryId, minPrice: $minPrice, maxPrice: $maxPrice, condition: $condition, location: $location, hasBuyNow: $hasBuyNow, endingSoon: $endingSoon, featuredOnly: $featuredOnly, sortBy: $sortBy, sortOrder: $sortOrder)';
  }
}
