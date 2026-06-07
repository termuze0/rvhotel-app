import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  User? _user;
  String? _token;
  String? _role;
  bool _isLoading = false;
  String? _error;

  User? get user => _user;
  String? get token => _token;
  String? get role => _role;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;

  Future<bool> login(String email, String password) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _authService.login(email, password);
      _user = response.user;
      _token = response.token;
      _role = response.role;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String firstName,
    required String lastName,
    required String email,
    required String phone,
    required String password,
    String role = 'customer',
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _authService.register(
        firstName: firstName,
        lastName: lastName,
        email: email,
        phone: phone,
        password: password,
        role: role,
      );
      _user = response.user;
      _token = response.token;
      _role = response.role;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerHotelManager({
    required String email,
    required String password,
    required String phone,
    required String hotelName,
    required String address,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final response = await _authService.registerHotelManager(
        email: email,
        password: password,
        phone: phone,
        hotelName: hotelName,
        address: address,
      );
      _user = response.user;
      _token = response.token;
      _role = response.role;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> loadUserProfile() async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.getUserProfile();
      _user = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfile(Map<String, dynamic> data) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.updateProfile(data);
      _user = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> updateProfilePicture(String imagePath) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.updateProfilePicture(imagePath);
      _user = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Android / iOS — upload with a file path
  Future<bool> updateProfileWithImage(
    Map<String, dynamic> data, {
    String? imagePath,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.updateProfileWithImage(
        data,
        imagePath: imagePath,
      );
      _user = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  /// Web — upload with raw bytes (dart:io File is unavailable on web)
  Future<bool> updateProfileWithImageBytes(
    Map<String, dynamic> data, {
    required Uint8List imageBytes,
    required String imageName,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      final user = await _authService.updateProfileWithImageBytes(
        data,
        imageBytes: imageBytes,
        imageName: imageName,
      );
      _user = user;
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> changePassword({
    required String currentPassword,
    required String newPassword,
    required String newPasswordConfirmation,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.changePassword(
        currentPassword: currentPassword,
        newPassword: newPassword,
        newPasswordConfirmation: newPasswordConfirmation,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> forgotPassword(String email) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.forgotPassword(email);
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<bool> resetPassword({
    required String email,
    required String token,
    required String password,
    required String passwordConfirmation,
  }) async {
    _setLoading(true);
    _clearError();
    try {
      await _authService.resetPassword(
        email: email,
        token: token,
        password: password,
        passwordConfirmation: passwordConfirmation,
      );
      _setLoading(false);
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _user = null;
      _token = null;
      _role = null;
      _setLoading(false);
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      _setLoading(false);
      notifyListeners();
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
