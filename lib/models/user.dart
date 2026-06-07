class User {
  final int id;
  final String firstName;
  final String lastName;
  final String email;
  final String phone;
  final String? avatar;
  final int loyaltyPoints;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final String? role;
  final String? hotelName;

  User({
    required this.id,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.phone,
    this.avatar,
    required this.loyaltyPoints,
    required this.createdAt,
    this.updatedAt,
    this.role,
    this.hotelName,
  });

  String get fullName {
    // Handle null or empty names
    final first = firstName.trim();
    final last = lastName.trim();

    if (first.isNotEmpty && last.isNotEmpty) {
      return '$first $last';
    } else if (first.isNotEmpty) {
      return first;
    } else if (last.isNotEmpty) {
      return last;
    }
    // If no name, use hotel name or email
    if (hotelName != null && hotelName!.isNotEmpty) {
      return hotelName!;
    }
    // Use email prefix as fallback
    return email.split('@').first;
  }

  factory User.fromJson(Map<String, dynamic> json) {
    print('User.fromJson: $json');

    // Helper function to safely get string values (handle null)
    String getString(dynamic value, {String defaultValue = ''}) {
      if (value == null) return defaultValue;
      return value.toString();
    }

    // Helper function to safely get int values
    int getInt(dynamic value, {int defaultValue = 0}) {
      if (value == null) return defaultValue;
      if (value is int) return value;
      if (value is String) return int.tryParse(value) ?? defaultValue;
      return defaultValue;
    }

    // Helper function to safely get DateTime
    DateTime getDateTime(dynamic value) {
      if (value == null) return DateTime.now();
      if (value is DateTime) return value;
      if (value is String) return DateTime.tryParse(value) ?? DateTime.now();
      return DateTime.now();
    }

    return User(
      id: getInt(json['id']),
      firstName: getString(json['first_name']),
      lastName: getString(json['last_name']),
      email: getString(json['email']),
      phone: getString(json['phone']),
      avatar: json['avatar'] != null ? getString(json['avatar']) : null,
      loyaltyPoints: getInt(json['loyalty_pts']),
      createdAt: getDateTime(json['created_at']),
      updatedAt:
          json['updated_at'] != null ? getDateTime(json['updated_at']) : null,
      role: getString(json['role'], defaultValue: 'customer'),
      hotelName:
          json['hotel_name'] != null ? getString(json['hotel_name']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'first_name': firstName,
      'last_name': lastName,
      'email': email,
      'phone': phone,
      'avatar': avatar,
    };
  }
}
