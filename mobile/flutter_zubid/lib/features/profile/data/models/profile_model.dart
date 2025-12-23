import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'profile_model.g.dart';

@HiveType(typeId: 1)
@JsonSerializable()
class ProfileModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  @JsonKey(name: 'first_name')
  final String? firstName;

  @HiveField(4)
  @JsonKey(name: 'last_name')
  final String? lastName;

  @HiveField(5)
  @JsonKey(name: 'phone_number')
  final String? phoneNumber;

  @HiveField(6)
  @JsonKey(name: 'profile_photo_url')
  final String? profilePhotoUrl;

  @HiveField(7)
  @JsonKey(name: 'id_number')
  final String? idNumber;

  @HiveField(8)
  final String? address;

  @HiveField(9)
  final String? city;

  @HiveField(10)
  final String? country;

  @HiveField(11)
  @JsonKey(name: 'postal_code')
  final String? postalCode;

  @HiveField(12)
  @JsonKey(name: 'date_of_birth')
  final DateTime? dateOfBirth;

  @HiveField(13)
  final String? bio;

  @HiveField(14)
  @JsonKey(name: 'preferred_language')
  final String? preferredLanguage;

  @HiveField(15)
  final String? timezone;

  @HiveField(16)
  @JsonKey(name: 'email_verified')
  final bool emailVerified;

  @HiveField(17)
  @JsonKey(name: 'phone_verified')
  final bool phoneVerified;

  @HiveField(18)
  @JsonKey(name: 'profile_completed')
  final bool profileCompleted;

  @HiveField(19)
  final double? rating;

  @HiveField(20)
  @JsonKey(name: 'total_bids')
  final int totalBids;

  @HiveField(21)
  @JsonKey(name: 'total_wins')
  final int totalWins;

  @HiveField(22)
  @JsonKey(name: 'total_spent')
  final double totalSpent;

  @HiveField(23)
  @JsonKey(name: 'member_since')
  final DateTime memberSince;

  @HiveField(24)
  @JsonKey(name: 'last_active')
  final DateTime? lastActive;

  @HiveField(25)
  final Map<String, dynamic>? preferences;

  const ProfileModel({
    required this.id,
    required this.username,
    required this.email,
    this.firstName,
    this.lastName,
    this.phoneNumber,
    this.profilePhotoUrl,
    this.idNumber,
    this.address,
    this.city,
    this.country,
    this.postalCode,
    this.dateOfBirth,
    this.bio,
    this.preferredLanguage,
    this.timezone,
    this.emailVerified = false,
    this.phoneVerified = false,
    this.profileCompleted = false,
    this.rating,
    this.totalBids = 0,
    this.totalWins = 0,
    this.totalSpent = 0.0,
    required this.memberSince,
    this.lastActive,
    this.preferences,
  });

  factory ProfileModel.fromJson(Map<String, dynamic> json) =>
      _$ProfileModelFromJson(json);

  Map<String, dynamic> toJson() => _$ProfileModelToJson(this);

  ProfileModel copyWith({
    int? id,
    String? username,
    String? email,
    String? firstName,
    String? lastName,
    String? phoneNumber,
    String? profilePhotoUrl,
    String? idNumber,
    String? address,
    String? city,
    String? country,
    String? postalCode,
    DateTime? dateOfBirth,
    String? bio,
    String? preferredLanguage,
    String? timezone,
    bool? emailVerified,
    bool? phoneVerified,
    bool? profileCompleted,
    double? rating,
    int? totalBids,
    int? totalWins,
    double? totalSpent,
    DateTime? memberSince,
    DateTime? lastActive,
    Map<String, dynamic>? preferences,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      username: username ?? this.username,
      email: email ?? this.email,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      profilePhotoUrl: profilePhotoUrl ?? this.profilePhotoUrl,
      idNumber: idNumber ?? this.idNumber,
      address: address ?? this.address,
      city: city ?? this.city,
      country: country ?? this.country,
      postalCode: postalCode ?? this.postalCode,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      bio: bio ?? this.bio,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timezone: timezone ?? this.timezone,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      profileCompleted: profileCompleted ?? this.profileCompleted,
      rating: rating ?? this.rating,
      totalBids: totalBids ?? this.totalBids,
      totalWins: totalWins ?? this.totalWins,
      totalSpent: totalSpent ?? this.totalSpent,
      memberSince: memberSince ?? this.memberSince,
      lastActive: lastActive ?? this.lastActive,
      preferences: preferences ?? this.preferences,
    );
  }

  // Computed properties
  String get displayName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else {
      return username;
    }
  }

  String get initials {
    if (firstName != null && lastName != null) {
      return '${firstName![0]}${lastName![0]}'.toUpperCase();
    } else if (firstName != null) {
      return firstName![0].toUpperCase();
    } else {
      return username[0].toUpperCase();
    }
  }

  double get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields = 12; // Essential fields for profile completion

    if (firstName != null && firstName!.isNotEmpty) completedFields++;
    if (lastName != null && lastName!.isNotEmpty) completedFields++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) completedFields++;
    if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) completedFields++;
    if (address != null && address!.isNotEmpty) completedFields++;
    if (city != null && city!.isNotEmpty) completedFields++;
    if (country != null && country!.isNotEmpty) completedFields++;
    if (dateOfBirth != null) completedFields++;
    if (bio != null && bio!.isNotEmpty) completedFields++;
    if (emailVerified) completedFields++;
    if (phoneVerified) completedFields++;
    if (idNumber != null && idNumber!.isNotEmpty) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  bool get isProfileComplete => profileCompletionPercentage >= 80.0;

  String get membershipDuration {
    final now = DateTime.now();
    final difference = now.difference(memberSince);
    
    if (difference.inDays >= 365) {
      final years = (difference.inDays / 365).floor();
      return '$years year${years > 1 ? 's' : ''}';
    } else if (difference.inDays >= 30) {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''}';
    } else {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''}';
    }
  }

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ProfileModel &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          username == other.username &&
          email == other.email;

  @override
  int get hashCode => id.hashCode ^ username.hashCode ^ email.hashCode;

  @override
  String toString() => 'ProfileModel(id: $id, username: $username, email: $email)';
}
