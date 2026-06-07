import 'user.dart';

class AuthResponse {
  final String token;
  final String role;
  final User user;

  AuthResponse({
    required this.token,
    required this.role,
    required this.user,
  });

  factory AuthResponse.fromJson(Map<String, dynamic> json) {
    print('AuthResponse.fromJson: $json');

    // Extract token
    String token = json['token'] ?? '';

    // Extract role
    String role = json['role'] ?? 'customer';

    // Extract user profile
    User user;
    if (json['profile'] != null) {
      user = User.fromJson(json['profile']);
    } else {
      // Create a basic user
      user = User(
        id: 0,
        firstName: '',
        lastName: '',
        email: json['email'] ?? '',
        phone: json['phone'] ?? '',
        avatar: null,
        loyaltyPoints: 0,
        createdAt: DateTime.now(),
        updatedAt: null,
        role: role,
        hotelName: json['hotel_name'],
      );
    }

    print(
        'Parsed - Token: ${token.substring(0, token.length > 20 ? 20 : token.length)}..., Role: $role');
    print('User - Name: ${user.fullName}, Email: ${user.email}');

    return AuthResponse(
      token: token,
      role: role,
      user: user,
    );
  }
}
