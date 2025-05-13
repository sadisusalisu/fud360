enum UserRole { donor, receiver, volunteer, admin }

class User {
  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;
  final String? organization;
  final String? profileImageUrl;
  final DateTime joinedDate;
  final int impactPoints;

  User({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.role,
    this.organization,
    this.profileImageUrl,
    required this.joinedDate,
    this.impactPoints = 0,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['id'],
      name: json['name'],
      email: json['email'],
      phone: json['phone'],
      role: UserRole.values.firstWhere(
        (e) => e.toString() == 'UserRole.${json['role']}',
        orElse: () => UserRole.receiver,
      ),
      organization: json['organization'],
      profileImageUrl: json['profileImageUrl'],
      joinedDate: DateTime.parse(json['joinedDate']),
      impactPoints: json['impactPoints'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.toString().split('.').last,
      'organization': organization,
      'profileImageUrl': profileImageUrl,
      'joinedDate': joinedDate.toIso8601String(),
      'impactPoints': impactPoints,
    };
  }

  User copyWith({
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? organization,
    String? profileImageUrl,
    int? impactPoints,
  }) {
    return User(
      id: this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      organization: organization ?? this.organization,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      joinedDate: this.joinedDate,
      impactPoints: impactPoints ?? this.impactPoints,
    );
  }
}
