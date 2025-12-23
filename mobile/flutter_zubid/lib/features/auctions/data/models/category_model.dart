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

// AuctionSearchFilters moved to separate file: auction_search_filters.dart
