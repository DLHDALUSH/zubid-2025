// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'category_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class CategoryModelAdapter extends TypeAdapter<CategoryModel> {
  @override
  final int typeId = 3;

  @override
  CategoryModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CategoryModel(
      id: fields[0] as int,
      name: fields[1] as String,
      description: fields[2] as String,
      parentId: fields[3] as int?,
      iconUrl: fields[4] as String?,
      imageUrl: fields[5] as String?,
      auctionCount: fields[6] as int,
      isActive: fields[7] as bool,
      sortOrder: fields[8] as int,
      createdAt: fields[9] as DateTime,
      updatedAt: fields[10] as DateTime,
      subcategories: (fields[11] as List?)?.cast<CategoryModel>(),
    );
  }

  @override
  void write(BinaryWriter writer, CategoryModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.parentId)
      ..writeByte(4)
      ..write(obj.iconUrl)
      ..writeByte(5)
      ..write(obj.imageUrl)
      ..writeByte(6)
      ..write(obj.auctionCount)
      ..writeByte(7)
      ..write(obj.isActive)
      ..writeByte(8)
      ..write(obj.sortOrder)
      ..writeByte(9)
      ..write(obj.createdAt)
      ..writeByte(10)
      ..write(obj.updatedAt)
      ..writeByte(11)
      ..write(obj.subcategories);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CategoryModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

CategoryModel _$CategoryModelFromJson(Map<String, dynamic> json) => CategoryModel(
      id: json['id'] as int,
      name: json['name'] as String,
      description: json['description'] as String,
      parentId: json['parent_id'] as int?,
      iconUrl: json['icon_url'] as String?,
      imageUrl: json['image_url'] as String?,
      auctionCount: json['auction_count'] as int,
      isActive: json['is_active'] as bool,
      sortOrder: json['sort_order'] as int,
      createdAt: DateTime.parse(json['created_at'] as String),
      updatedAt: DateTime.parse(json['updated_at'] as String),
      subcategories: (json['subcategories'] as List<dynamic>?)
          ?.map((e) => CategoryModel.fromJson(e as Map<String, dynamic>))
          .toList(),
    );

Map<String, dynamic> _$CategoryModelToJson(CategoryModel instance) =>
    <String, dynamic>{
      'id': instance.id,
      'name': instance.name,
      'description': instance.description,
      'parent_id': instance.parentId,
      'icon_url': instance.iconUrl,
      'image_url': instance.imageUrl,
      'auction_count': instance.auctionCount,
      'is_active': instance.isActive,
      'sort_order': instance.sortOrder,
      'created_at': instance.createdAt.toIso8601String(),
      'updated_at': instance.updatedAt.toIso8601String(),
      'subcategories': instance.subcategories,
    };

AuctionSearchFilters _$AuctionSearchFiltersFromJson(
        Map<String, dynamic> json) =>
    AuctionSearchFilters(
      categoryId: json['category_id'] as int?,
      minPrice: (json['min_price'] as num?)?.toDouble(),
      maxPrice: (json['max_price'] as num?)?.toDouble(),
      hasBuyNow: json['has_buy_now'] as bool?,
      hasReserve: json['has_reserve'] as bool?,
      condition: json['condition'] as String?,
      location: json['location'] as String?,
      sellerId: json['seller_id'] as int?,
      endingSoon: json['ending_soon'] as bool?,
      newlyListed: json['newly_listed'] as bool?,
      featuredOnly: json['featured_only'] as bool?,
      watchedOnly: json['watched_only'] as bool?,
      sortBy: json['sortBy'] as String?,
      sortOrder: json['sortOrder'] as String?,
    );

Map<String, dynamic> _$AuctionSearchFiltersToJson(
        AuctionSearchFilters instance) =>
    <String, dynamic>{
      'category_id': instance.categoryId,
      'min_price': instance.minPrice,
      'max_price': instance.maxPrice,
      'has_buy_now': instance.hasBuyNow,
      'has_reserve': instance.hasReserve,
      'condition': instance.condition,
      'location': instance.location,
      'seller_id': instance.sellerId,
      'ending_soon': instance.endingSoon,
      'newly_listed': instance.newlyListed,
      'featured_only': instance.featuredOnly,
      'watched_only': instance.watchedOnly,
      'sortBy': instance.sortBy,
      'sortOrder': instance.sortOrder,
    };
