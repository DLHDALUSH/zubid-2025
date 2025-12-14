class Bid {
  final int id;
  final int auctionId;
  final int userId;
  final String? username;
  final double amount;
  final DateTime createdAt;
  final String? auctionTitle;
  final String? auctionImage;
  final String? auctionStatus;

  Bid({
    required this.id,
    required this.auctionId,
    required this.userId,
    this.username,
    required this.amount,
    required this.createdAt,
    this.auctionTitle,
    this.auctionImage,
    this.auctionStatus,
  });

  factory Bid.fromJson(Map<String, dynamic> json) {
    // Try multiple timestamp field names
    DateTime parseTimestamp() {
      if (json['created_at'] != null) {
        return DateTime.parse(json['created_at']);
      }
      if (json['timestamp'] != null) {
        return DateTime.parse(json['timestamp']);
      }
      return DateTime.now();
    }

    return Bid(
      id: json['id'] ?? 0,
      auctionId: json['auction_id'] ?? 0,
      userId: json['user_id'] ?? 0,
      username: json['username'],
      amount: (json['amount'] ?? 0).toDouble(),
      createdAt: parseTimestamp(),
      auctionTitle: json['auction_title'],
      auctionImage: json['auction_image'],
      auctionStatus: json['auction_status'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'auction_id': auctionId,
      'user_id': userId,
      'username': username,
      'amount': amount,
      'created_at': createdAt.toIso8601String(),
      'auction_title': auctionTitle,
      'auction_image': auctionImage,
      'auction_status': auctionStatus,
    };
  }
}

