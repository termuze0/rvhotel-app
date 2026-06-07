import 'dart:typed_data';
import 'api_service.dart';
import '../config/api_config.dart';
import '../models/user.dart';
import '../models/auth_response.dart';

class AuthService {
  final ApiService _api = ApiService();

  Future<AuthResponse> login(String email, String password) async {
    try {
      final response = await _api.post(ApiConfig.login, data: {
        'email': email,
        'password': password,
      });
      final token = response['token'];
      await _api.setToken(token);
      return AuthResponse.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String role = 'customer',
    String? hotelName,
    String? address,
  }) async {
    try {
      final Map<String, dynamic> requestData = {
        'first_name': firstName,
        'last_name': lastName,
        'email': email,
        'phone': phone,
        'password': password,
        'role': role,
      };
      if (role == 'hotel' || role == 'manager') {
        if (hotelName != null) requestData['hotel_name'] = hotelName;
        if (address != null) requestData['address'] = address;
      }
      final response = await _api.post(ApiConfig.register, data: requestData);
      final token = response['token'];
      await _api.setToken(token);
      return AuthResponse.fromJson(response);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<AuthResponse> registerHotelManager({
    required String email,
    required String password,
    required String phone,
    required String hotelName,
    required String address,
  }) async {
    try {
      final requestData = {
        'email': email,
        'password': password,
        'phone': phone,
        'role': 'hotel',
        'hotel_name': hotelName,
        'address': address,
      };
      final response = await _api.post(ApiConfig.register, data: requestData);
      if (response['token'] != null) {
        final token = response['token'];
        await _api.setToken(token);
        return AuthResponse(
          token: token,
          role: 'hotel',
          user: User(
            id: 0,
            firstName: '',
            lastName: '',
            email: email,
            phone: phone,
            avatar: null,
            loyaltyPoints: 0,
            createdAt: DateTime.now(),
            updatedAt: null,
            role: 'hotel',
            hotelName: hotelName,
          ),
        );
      } else {
        throw Exception(response['message'] ?? 'Registration failed');
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> getUserProfile() async {
    try {
      final response = await _api.get(ApiConfig.userProfile);
      return User.fromJson(response['profile']);
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateProfile(Map<String, dynamic> data) async {
    try {
      final response = await _api.post(ApiConfig.updateProfile, data: data);
      return User.fromJson(response['profile'] ?? response['data'] ?? {});
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<User> updateProfilePicture(String imagePath) async {
    try {
      final currentUser = await getUserProfile();
      final fields = {
        'first_name': currentUser.firstName,
        'last_name': currentUser.lastName,
        'phone': currentUser.phone,
      };
      final response = await _api.postMultipart(
        ApiConfig.updateProfile,
        fields: fields,
        filePath: imagePath,
        fileKey: 'avatar',
      );
      return User.fromJson(response['profile'] ?? response['data'] ?? {});
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Android / iOS — sends the image as a file from [imagePath].
  Future<User> updateProfileWithImage(
    Map<String, dynamic> data, {
    String? imagePath,
  }) async {
    try {
      if (imagePath != null) {
        final response = await _api.postMultipart(
          ApiConfig.updateProfile,
          fields: data.map((k, v) => MapEntry(k, v.toString())),
          filePath: imagePath,
          fileKey: 'avatar',
        );
        return User.fromJson(response['profile'] ?? response['data'] ?? {});
      } else {
        final response = await _api.post(ApiConfig.updateProfile, data: data);
        return User.fromJson(response['profile'] ?? response['data'] ?? {});
      }
    } catch (e) {
      throw _handleError(e);
    }
  }

  /// Web — sends the image as raw [Uint8List] bytes.
  /// Uses [postMultipartBytes] on ApiService so dart:io is never touched.
  Future<User> updateProfileWithImageBytes(
    Map<String, dynamic> data, {
    required Uint8List imageBytes,
    required String imageName,
  }) async {
    try {
      final response = await _api.postMultipartBytes(
        ApiConfig.updateProfile,
        fields: data.map((k, v) => MapEntry(k, v.toString())),
        fileBytes: imageBytes,
        fileName: imageName,
        fileKey: 'avatar',
      );
      return User.fromJson(response['profile'] ?? response['data'] ?? {});
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    try {
      await _api.post(ApiConfig.changePassword, data: {
        'current_password': currentPassword,
        'password': newPassword,
        'password_confirmation': newPasswordConfirmation,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> forgotPassword(String email) async {
    try {
      await _api.post(ApiConfig.forgotPassword, data: {'email': email});
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    try {
      await _api.post(ApiConfig.resetPassword, data: {
        'email': email,
        'token': token,
        'password': password,
        'password_confirmation': passwordConfirmation,
      });
    } catch (e) {
      throw _handleError(e);
    }
  }

  Future<void> logout() async {
    try {
      await _api.post(ApiConfig.logout);
      await _api.clearToken();
    } catch (e) {
      throw _handleError(e);
    }
  }

  String _handleError(dynamic error) {
    if (error is ApiException) {
      if (error.errors != null) {
        final firstError = error.errors.values.first.first;
        return firstError;
      }
      return error.message;
    }
    return 'An unexpected error occurred';
  }
}
