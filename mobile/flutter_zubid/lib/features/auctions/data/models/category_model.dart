import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'category_model.g.dart';

@HiveType(typeId: 3)
@JsonSerializable()
class CategoryModel extends HiveObject {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  @JsonKey(name: 'parent_id')
  final int? parentId;

  @HiveField(4)
  @JsonKey(name: 'icon_url')
  final String? iconUrl;

  @HiveField(5)
  @JsonKey(name: 'image_url')
  final String? imageUrl;

  @HiveField(6)
  @JsonKey(name: 'auction_count')
  final int auctionCount;

  @HiveField(7)
  @JsonKey(name: 'is_active')
  final bool isActive;

  @HiveField(8)
  @JsonKey(name: 'sort_order')
  final int sortOrder;

  @HiveField(9)
  @JsonKey(name: 'created_at')
  final DateTime createdAt;

  @HiveField(10)
  @JsonKey(name: 'updated_at')
  final DateTime updatedAt;

  @HiveField(11)
  final List<CategoryModel>? subcategories;

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    this.parentId,
    this.iconUrl,
    this.imageUrl,
    required this.auctionCount,
    required this.isActive,
    required this.sortOrder,
    required this.createdAt,
    required this.updatedAt,
    this.subcategories,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) => _$CategoryModelFromJson(json);
  Map<String, dynamic> toJson() => _$CategoryModelToJson(this);

  // Computed properties
  bool get isParentCategory => parentId == null;
  bool get hasSubcategories => subcategories != null && subcategories!.isNotEmpty;
  bool get hasAuctions => auctionCount > 0;

  String get displayName => name;
  String get auctionCountText => auctionCount == 1 ? '1 auction' : '$auctionCount auctions';

  CategoryModel copyWith({
    int? id,
    String? name,
    String? description,
    int? parentId,
    String? iconUrl,
    String? imageUrl,
    int? auctionCount,
    bool? isActive,
    int? sortOrder,
    DateTime? createdAt,
    DateTime? updatedAt,
    List<CategoryModel>? subcategories,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      parentId: parentId ?? this.parentId,
      iconUrl: iconUrl ?? this.iconUrl,
      imageUrl: imageUrl ?? this.imageUrl,
      auctionCount: auctionCount ?? this.auctionCount,
      isActive: isActive ?? this.isActive,
      sortOrder: sortOrder ?? this.sortOrder,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      subcategories: subcategories ?? this.subcategories,
    );
  }
}

@JsonSerializable()
class AuctionSearchFilters {
  @JsonKey(name: 'category_id')
  final int? categoryId;

  @JsonKey(name: 'min_price')
  final double? minPrice;

  @JsonKey(name: 'max_price')
  final double? maxPrice;

  @JsonKey(name: 'has_buy_now')
  final bool? hasBuyNow;

  @JsonKey(name: 'has_reserve')
  final bool? hasReserve;

  final String? condition;
  final String? location;

  @JsonKey(name: 'seller_id')
  final int? sellerId;

  @JsonKey(name: 'ending_soon')
  final bool? endingSoon;

  @JsonKey(name: 'newly_listed')
  final bool? newlyListed;

  @JsonKey(name: 'featured_only')
  final bool? featuredOnly;

  @JsonKey(name: 'watched_only')
  final bool? watchedOnly;

  final String? sortBy;
  final String? sortOrder;

  AuctionSearchFilters({
    this.categoryId,
    this.minPrice,
    this.maxPrice,
    this.hasBuyNow,
    this.hasReserve,
    this.condition,
    this.location,
    this.sellerId,
    this.endingSoon,
    this.newlyListed,
    this.featuredOnly,
    this.watchedOnly,
    this.sortBy,
    this.sortOrder,
  });

  factory AuctionSearchFilters.fromJson(Map<String, dynamic> json) => _$AuctionSearchFiltersFromJson(json);
  Map<String, dynamic> toJson() => _$AuctionSearchFiltersToJson(this);

  bool get hasFilters {
    return categoryId != null ||
        minPrice != null ||
        maxPrice != null ||
        hasBuyNow == true ||
        hasReserve == true ||
        condition != null ||
        location != null ||
        sellerId != null ||
        endingSoon == true ||
        newlyListed == true ||
        featuredOnly == true ||
        watchedOnly == true;
  }

  int get activeFilterCount {
    int count = 0;
    if (categoryId != null) count++;
    if (minPrice != null) count++;
    if (maxPrice != null) count++;
    if (hasBuyNow == true) count++;
    if (hasReserve == true) count++;
    if (condition != null) count++;
    if (location != null) count++;
    if (sellerId != null) count++;
    if (endingSoon == true) count++;
    if (newlyListed == true) count++;
    if (featuredOnly == true) count++;
    if (watchedOnly == true) count++;
    return count;
  }

  AuctionSearchFilters copyWith({
    int? categoryId,
    double? minPrice,
    double? maxPrice,
    bool? hasBuyNow,
    bool? hasReserve,
    String? condition,
    String? location,
    int? sellerId,
    bool? endingSoon,
    bool? newlyListed,
    bool? featuredOnly,
    bool? watchedOnly,
    String? sortBy,
    String? sortOrder,
  }) {
    return AuctionSearchFilters(
      categoryId: categoryId ?? this.categoryId,
      minPrice: minPrice ?? this.minPrice,
      maxPrice: maxPrice ?? this.maxPrice,
      hasBuyNow: hasBuyNow ?? this.hasBuyNow,
      hasReserve: hasReserve ?? this.hasReserve,
      condition: condition ?? this.condition,
      location: location ?? this.location,
      sellerId: sellerId ?? this.sellerId,
      endingSoon: endingSoon ?? this.endingSoon,
      newlyListed: newlyListed ?? this.newlyListed,
      featuredOnly: featuredOnly ?? this.featuredOnly,
      watchedOnly: watchedOnly ?? this.watchedOnly,
      sortBy: sortBy ?? this.sortBy,
      sortOrder: sortOrder ?? this.sortOrder,
    );
  }

  static AuctionSearchFilters get empty => AuctionSearchFilters();
}
