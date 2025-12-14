class User {
  final int id;
  final String username;
  final String? email;
  final String? phone;
  final String? avatarUrl;
  final bool isAdmin;
  final DateTime createdAt;

  User({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.avatarUrl,
    this.isAdmin = false,
    required this.createdAt,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'] ?? 0,
      username: json['username'] ?? '',
      email: json['email'],
      phone: json['phone'],
      avatarUrl: json['avatar_url'],
      isAdmin: json['is_admin'] ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'])
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'avatar_url': avatarUrl,
      'is_admin': isAdmin,
      'created_at': createdAt.toIso8601String(),
    };
  }
}

