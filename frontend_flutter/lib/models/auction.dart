class Auction {
  final int id;
  final String title;
  final String description;
  final double startingPrice;
  final double currentBid;
  final double? buyNowPrice;
  final String? imageUrl;
  final List<String> images;
  final String? videoUrl;
  final DateTime endTime;
  final String status;
  final int sellerId;
  final String? sellerName;
  final int? categoryId;
  final String? categoryName;
  final int bidCount;
  final int? highestBidderId;
  final DateTime createdAt;

  Auction({
    required this.id,
    required this.title,
    required this.description,
    required this.startingPrice,
    required this.currentBid,
    this.buyNowPrice,
    this.imageUrl,
    this.images = const [],
    this.videoUrl,
    required this.endTime,
    required this.status,
    required this.sellerId,
    this.sellerName,
    this.categoryId,
    this.categoryName,
    this.bidCount = 0,
    this.highestBidderId,
    required this.createdAt,
  });

  bool get isActive => status == 'active' && DateTime.now().isBefore(endTime);
  bool get hasEnded => DateTime.now().isAfter(endTime) || status == 'ended';

  Duration get timeRemaining {
    final now = DateTime.now();
    if (now.isAfter(endTime)) return Duration.zero;
    return endTime.difference(now);
  }

  factory Auction.fromJson(Map<String, dynamic> json) {
    // Parse images - can be list of strings or list of objects with 'url' property
    List<String> parseImages(dynamic imagesData) {
      if (imagesData == null) return [];
      if (imagesData is List) {
        return imagesData.map((img) {
          if (img is String) return img;
          if (img is Map) return img['url']?.toString() ?? '';
          return '';
        }).where((url) => url.isNotEmpty).toList();
      }
      return [];
    }

    // Get image URL - try multiple field names
    String? getImageUrl(Map<String, dynamic> json) {
      return json['image_url'] ?? json['imageUrl'] ?? json['featured_image_url'];
    }

    return Auction(
      id: json['id'] ?? 0,
      title: json['title'] ?? json['item_name'] ?? '',
      description: json['description'] ?? '',
      startingPrice: (json['starting_price'] ?? json['starting_bid'] ?? 0).toDouble(),
      currentBid: (json['current_bid'] ?? json['currentPrice'] ?? json['starting_bid'] ?? json['starting_price'] ?? 0).toDouble(),
      buyNowPrice: json['buy_now_price']?.toDouble(),
      imageUrl: getImageUrl(json),
      images: parseImages(json['images']),
      videoUrl: json['video_url'],
      endTime: json['end_time'] != null
          ? DateTime.parse(json['end_time'])
          : DateTime.now().add(const Duration(days: 7)),
      status: json['status'] ?? 'active',
      sellerId: json['seller_id'] ?? json['sellerId'] ?? 0,
      sellerName: json['seller_name'],
      categoryId: json['category_id'] ?? json['categoryId'],
      categoryName: json['category_name'],
      bidCount: json['bid_count'] ?? json['bidCount'] ?? 0,
      highestBidderId: json['highest_bidder_id'] ?? json['winner_id'],
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : (json['start_time'] != null
              ? DateTime.parse(json['start_time'])
              : DateTime.now()),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'starting_price': startingPrice,
      'current_bid': currentBid,
      'buy_now_price': buyNowPrice,
      'image_url': imageUrl,
      'images': images,
      'video_url': videoUrl,
      'end_time': endTime.toIso8601String(),
      'status': status,
      'seller_id': sellerId,
      'seller_name': sellerName,
      'category_id': categoryId,
      'category_name': categoryName,
      'bid_count': bidCount,
      'highest_bidder_id': highestBidderId,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

class Category {
  final int id;
  final String name;
  final String? icon;

  Category({required this.id, required this.name, this.icon});

  factory Category.fromJson(Map<String, dynamic> json) {
    return Category(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      icon: json['icon'],
    );
  }
}

