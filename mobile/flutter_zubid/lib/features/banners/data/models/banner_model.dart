class BannerModel {
  final int id;
  final String title;
  final String? description;
  final String? imageUrl;
  final String? videoUrl;
  final String? linkUrl;
  final String mediaType;
  final int position;
  final bool isActive;
  final DateTime? startDate;
  final DateTime? endDate;
  final DateTime? createdAt;

  BannerModel({
    required this.id,
    required this.title,
    this.description,
    this.imageUrl,
    this.videoUrl,
    this.linkUrl,
    this.mediaType = 'image',
    this.position = 0,
    this.isActive = true,
    this.startDate,
    this.endDate,
    this.createdAt,
  });

  factory BannerModel.fromJson(Map<String, dynamic> json) {
    return BannerModel(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      description: json['description'],
      imageUrl: json['image_url'],
      videoUrl: json['video_url'],
      linkUrl: json['link_url'],
      mediaType: json['media_type'] ?? 'image',
      position: json['position'] ?? 0,
      isActive: json['is_active'] ?? true,
      startDate: json['start_date'] != null 
          ? DateTime.tryParse(json['start_date']) 
          : null,
      endDate: json['end_date'] != null 
          ? DateTime.tryParse(json['end_date']) 
          : null,
      createdAt: json['created_at'] != null 
          ? DateTime.tryParse(json['created_at']) 
          : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'image_url': imageUrl,
      'video_url': videoUrl,
      'link_url': linkUrl,
      'media_type': mediaType,
      'position': position,
      'is_active': isActive,
      'start_date': startDate?.toIso8601String(),
      'end_date': endDate?.toIso8601String(),
      'created_at': createdAt?.toIso8601String(),
    };
  }

  bool get isImage => mediaType == 'image';
  bool get isVideo => mediaType == 'video';
  
  String? get mediaUrl => isVideo ? videoUrl : imageUrl;
}

