class User {
  final String id;
  final String username;
  final String? email;
  final String? phone;
  final String? profilePhoto;
  final String role;
  final double balance;
  final String? firstName;
  final String? lastName;

  User({
    required this.id,
    required this.username,
    this.email,
    this.phone,
    this.profilePhoto,
    this.role = 'user',
    this.balance = 0.0,
    this.firstName,
    this.lastName,
  });

  bool get isAdmin => role == 'admin';

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id']?.toString() ?? '0',
      username: json['username'] ?? '',
      email: json['email'],
      phone: json['phone'],
      profilePhoto: json['profile_photo'],
      role: json['role'] ?? 'user',
      balance: (json['balance'] ?? 0).toDouble(),
      firstName: json['first_name'],
      lastName: json['last_name'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'username': username,
      'email': email,
      'phone': phone,
      'profile_photo': profilePhoto,
      'role': role,
      'balance': balance,
      'first_name': firstName,
      'last_name': lastName,
    };
  }
}

