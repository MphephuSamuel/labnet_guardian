class UserProfile {
  final String email;
  final String role;
  String firstName;
  String lastName;
  String displayName;
  String avatar;

  UserProfile({
    required this.email,
    required this.role,
    required this.firstName,
    required this.lastName,
    required this.displayName,
    required this.avatar,
  });

  factory UserProfile.fromJson(Map<String, dynamic> json) {
    return UserProfile(
      email: json['email'] ?? 'admin@ump.ac.za',
      role: json['role'] ?? 'Network Administrator',
      firstName: json['firstName'] ?? '',
      lastName: json['lastName'] ?? '',
      displayName: json['displayName'] ?? 'Admin User',
      avatar: json['avatar'] ?? 'A',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'firstName': firstName,
      'lastName': lastName,
      'displayName': displayName,
      'avatar': avatar,
    };
  }

  UserProfile copyWith({
    String? email,
    String? role,
    String? firstName,
    String? lastName,
    String? displayName,
    String? avatar,
  }) {
    return UserProfile(
      email: email ?? this.email,
      role: role ?? this.role,
      firstName: firstName ?? this.firstName,
      lastName: lastName ?? this.lastName,
      displayName: displayName ?? this.displayName,
      avatar: avatar ?? this.avatar,
    );
  }
}
