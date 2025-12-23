import 'package:hive/hive.dart';
import 'package:json_annotation/json_annotation.dart';

part 'user_model.g.dart';

@HiveType(typeId: 0)
@JsonSerializable()
class UserModel {
  @HiveField(0)
  final int id;

  @HiveField(1)
  final String username;

  @HiveField(2)
  final String email;

  @HiveField(3)
  final String? firstName;

  @HiveField(4)
  final String? lastName;

  @HiveField(5)
  final String? phoneNumber;

  @HiveField(6)
  final String? profilePhotoUrl;

  @HiveField(7)
  final String? idNumber;

  @HiveField(8)
  final String? address;

  @HiveField(9)
  final String? city;

  @HiveField(10)
  final String? country;

  @HiveField(11)
  final String? postalCode;

  @HiveField(12)
  final DateTime? dateOfBirth;

  @HiveField(13)
  final String role;

  @HiveField(14)
  final bool isActive;

  @HiveField(15)
  final bool isVerified;

  @HiveField(16)
  final DateTime createdAt;

  @HiveField(17)
  final DateTime updatedAt;

  @HiveField(18)
  final double? rating;

  @HiveField(19)
  final int? totalBids;

  @HiveField(20)
  final int? totalWins;

  @HiveField(21)
  final double? totalSpent;

  @HiveField(22)
  final bool? emailVerified;

  @HiveField(23)
  final bool? phoneVerified;

  @HiveField(24)
  final String? preferredLanguage;

  @HiveField(25)
  final String? timezone;

  @HiveField(26)
  final Map<String, dynamic>? preferences;

  const UserModel({
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
    this.role = 'user',
    this.isActive = true,
    this.isVerified = false,
    required this.createdAt,
    required this.updatedAt,
    this.rating,
    this.totalBids,
    this.totalWins,
    this.totalSpent,
    this.emailVerified,
    this.phoneVerified,
    this.preferredLanguage,
    this.timezone,
    this.preferences,
  });

  /// Get full name
  String get fullName {
    if (firstName != null && lastName != null) {
      return '$firstName $lastName';
    } else if (firstName != null) {
      return firstName!;
    } else if (lastName != null) {
      return lastName!;
    } else {
      return username;
    }
  }

  /// Get display name
  String get displayName {
    return fullName.isNotEmpty ? fullName : username;
  }

  /// Check if user is admin
  bool get isAdmin => role == 'admin' || role == 'super_admin';

  /// Check if user is moderator
  bool get isModerator => role == 'moderator' || isAdmin;

  /// Check if profile is complete
  bool get isProfileComplete {
    return firstName != null &&
        lastName != null &&
        phoneNumber != null &&
        address != null &&
        city != null &&
        country != null;
  }

  /// Get profile completion percentage
  double get profileCompletionPercentage {
    int completedFields = 0;
    int totalFields = 8;

    if (firstName != null && firstName!.isNotEmpty) completedFields++;
    if (lastName != null && lastName!.isNotEmpty) completedFields++;
    if (phoneNumber != null && phoneNumber!.isNotEmpty) completedFields++;
    if (profilePhotoUrl != null && profilePhotoUrl!.isNotEmpty) completedFields++;
    if (address != null && address!.isNotEmpty) completedFields++;
    if (city != null && city!.isNotEmpty) completedFields++;
    if (country != null && country!.isNotEmpty) completedFields++;
    if (dateOfBirth != null) completedFields++;

    return (completedFields / totalFields) * 100;
  }

  /// Get user initials for avatar
  String get initials {
    String initials = '';
    if (firstName != null && firstName!.isNotEmpty) {
      initials += firstName![0].toUpperCase();
    }
    if (lastName != null && lastName!.isNotEmpty) {
      initials += lastName![0].toUpperCase();
    }
    if (initials.isEmpty) {
      initials = username.isNotEmpty ? username[0].toUpperCase() : 'U';
    }
    return initials;
  }

  /// Get user age
  int? get age {
    if (dateOfBirth == null) return null;
    final now = DateTime.now();
    int age = now.year - dateOfBirth!.year;
    if (now.month < dateOfBirth!.month ||
        (now.month == dateOfBirth!.month && now.day < dateOfBirth!.day)) {
      age--;
    }
    return age;
  }

  /// Copy with method
  UserModel copyWith({
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
    String? role,
    bool? isActive,
    bool? isVerified,
    DateTime? createdAt,
    DateTime? updatedAt,
    double? rating,
    int? totalBids,
    int? totalWins,
    double? totalSpent,
    bool? emailVerified,
    bool? phoneVerified,
    String? preferredLanguage,
    String? timezone,
    Map<String, dynamic>? preferences,
  }) {
    return UserModel(
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
      role: role ?? this.role,
      isActive: isActive ?? this.isActive,
      isVerified: isVerified ?? this.isVerified,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      rating: rating ?? this.rating,
      totalBids: totalBids ?? this.totalBids,
      totalWins: totalWins ?? this.totalWins,
      totalSpent: totalSpent ?? this.totalSpent,
      emailVerified: emailVerified ?? this.emailVerified,
      phoneVerified: phoneVerified ?? this.phoneVerified,
      preferredLanguage: preferredLanguage ?? this.preferredLanguage,
      timezone: timezone ?? this.timezone,
      preferences: preferences ?? this.preferences,
    );
  }

  /// From JSON
  factory UserModel.fromJson(Map<String, dynamic> json) => _$UserModelFromJson(json);

  /// To JSON
  Map<String, dynamic> toJson() => _$UserModelToJson(this);

  @override
  String toString() {
    return 'UserModel(id: $id, username: $username, email: $email, fullName: $fullName)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}
