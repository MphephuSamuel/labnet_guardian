class AppUser {
  final String uid;
  final String firstName;
  final String secondName;
  final String lastName;
  final String role;
  final String email;
  final DateTime? createdAt;

  const AppUser({
    required this.uid,
    required this.firstName,
    required this.secondName,
    required this.lastName,
    required this.role,
    required this.email,
    required this.createdAt,
  });

  String get fullName {
    final parts = [
      firstName,
      secondName,
      lastName,
    ].where((value) => value.trim().isNotEmpty).toList();
    return parts.isEmpty ? 'Unknown User' : parts.join(' ');
  }

  factory AppUser.fromJson(Map<String, dynamic> json) {
    return AppUser(
      uid: (json['uid'] ?? '').toString(),
      firstName: (json['firstName'] ?? '').toString(),
      secondName: (json['secondName'] ?? '').toString(),
      lastName: (json['lastName'] ?? '').toString(),
      role: (json['role'] ?? 'user').toString(),
      email: (json['email'] ?? '').toString(),
      createdAt: _parseCreatedAt(json['createdAt']),
    );
  }

  static DateTime? _parseCreatedAt(dynamic value) {
    if (value == null) {
      return null;
    }

    if (value is String) {
      return DateTime.tryParse(value);
    }

    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }

    if (value is Map<String, dynamic>) {
      final seconds = value['_seconds'];
      if (seconds is int) {
        return DateTime.fromMillisecondsSinceEpoch(seconds * 1000);
      }

      final iso = value[r'$date'];
      if (iso is String) {
        return DateTime.tryParse(iso);
      }
    }

    return null;
  }
}
