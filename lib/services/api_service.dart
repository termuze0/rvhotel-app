import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../config/api_config.dart';

class ApiService {
  static final ApiService _instance = ApiService._internal();
  factory ApiService() => _instance;
  ApiService._internal();

  String? _token;

  Future<String?> getToken() async {
    if (_token != null) return _token;
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('auth_token');
    return _token;
  }

  Future<void> setToken(String token) async {
    _token = token;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('auth_token', token);
  }

  Future<void> clearToken() async {
    _token = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('auth_token');
  }

  Future<Map<String, String>> _getHeaders({String? baseUrl}) async {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };
    if (baseUrl != null && baseUrl.contains('ngrok')) {
      headers['ngrok-skip-browser-warning'] = 'true';
    }
    final token = await getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  Future<Map<String, String>> _getMultipartHeaders({String? baseUrl}) async {
    final headers = <String, String>{
      'Accept': 'application/json',
    };
    if (baseUrl != null && baseUrl.contains('ngrok')) {
      headers['ngrok-skip-browser-warning'] = 'true';
    }
    final token = await getToken();
    if (token != null) {
      headers['Authorization'] = 'Bearer $token';
    }
    return headers;
  }

  String _buildUrl(String endpoint, {String? baseUrl}) {
    final base = baseUrl ?? ApiConfig.baseUrl;
    return base + endpoint;
  }

  Future<Map<String, dynamic>> get(
    String endpoint, {
    Map<String, dynamic>? queryParams,
    String? baseUrl,
  }) async {
    try {
      final uri = Uri.parse(_buildUrl(endpoint, baseUrl: baseUrl)).replace(
          queryParameters:
              queryParams?.map((k, v) => MapEntry(k, v.toString())));
      final response = await http.get(
        uri,
        headers: await _getHeaders(baseUrl: baseUrl),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> post(
    String endpoint, {
    dynamic data,
    String? baseUrl,
  }) async {
    try {
      final response = await http.post(
        Uri.parse(_buildUrl(endpoint, baseUrl: baseUrl)),
        headers: await _getHeaders(baseUrl: baseUrl),
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> put(
    String endpoint, {
    dynamic data,
    String? baseUrl,
  }) async {
    try {
      final response = await http.put(
        Uri.parse(_buildUrl(endpoint, baseUrl: baseUrl)),
        headers: await _getHeaders(baseUrl: baseUrl),
        body: json.encode(data),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> delete(
    String endpoint, {
    String? baseUrl,
  }) async {
    try {
      final response = await http.delete(
        Uri.parse(_buildUrl(endpoint, baseUrl: baseUrl)),
        headers: await _getHeaders(baseUrl: baseUrl),
      );
      return _handleResponse(response);
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

  /// Android / iOS — upload a file from a local [filePath].
  Future<Map<String, dynamic>> postMultipart(
    String endpoint, {
    Map<String, String>? fields,
    String? filePath,
    String? fileKey,
    String? baseUrl,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_buildUrl(endpoint, baseUrl: baseUrl)),
      );
      request.headers.addAll(await _getMultipartHeaders(baseUrl: baseUrl));
      if (fields != null) request.fields.addAll(fields);
      if (filePath != null && fileKey != null) {
        final file = await http.MultipartFile.fromPath(fileKey, filePath);
        request.files.add(file);
      }
      return await _sendMultipartRequest(request);
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

  /// Web — upload a file from raw [Uint8List] bytes.
  /// Uses [http.MultipartFile.fromBytes] so dart:io is never touched.
  Future<Map<String, dynamic>> postMultipartBytes(
    String endpoint, {
    required Map<String, String> fields,
    required Uint8List fileBytes,
    required String fileName,
    required String fileKey,
    String? baseUrl,
  }) async {
    try {
      final request = http.MultipartRequest(
        'POST',
        Uri.parse(_buildUrl(endpoint, baseUrl: baseUrl)),
      );
      request.headers.addAll(await _getMultipartHeaders(baseUrl: baseUrl));
      request.fields.addAll(fields);
      request.files.add(
        http.MultipartFile.fromBytes(
          fileKey,
          fileBytes,
          filename: fileName,
        ),
      );
      return await _sendMultipartRequest(request);
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

  Future<Map<String, dynamic>> putMultipart(
    String endpoint, {
    Map<String, String>? fields,
    String? filePath,
    String? fileKey,
    String? baseUrl,
  }) async {
    try {
      final request = http.MultipartRequest(
        'PUT',
        Uri.parse(_buildUrl(endpoint, baseUrl: baseUrl)),
      );
      request.headers.addAll(await _getMultipartHeaders(baseUrl: baseUrl));
      if (fields != null) request.fields.addAll(fields);
      if (filePath != null && fileKey != null) {
        final file = await http.MultipartFile.fromPath(fileKey, filePath);
        request.files.add(file);
      }
      return await _sendMultipartRequest(request);
    } catch (e) {
      throw ApiException(message: 'Network error: ${e.toString()}');
    }
  }

  /// Shared helper — sends a prepared [MultipartRequest] and handles the response.
  Future<Map<String, dynamic>> _sendMultipartRequest(
      http.MultipartRequest request) async {
    final streamed = await request.send();
    final body = await streamed.stream.bytesToString();
    final Map<String, dynamic> data = json.decode(body);
    if (streamed.statusCode >= 200 && streamed.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        message: data['message'] ?? 'Something went wrong',
        statusCode: streamed.statusCode,
        errors: data['errors'],
      );
    }
  }

  Map<String, dynamic> _handleResponse(http.Response response) {
    final Map<String, dynamic> data = json.decode(response.body);
    if (response.statusCode >= 200 && response.statusCode < 300) {
      return data;
    } else {
      throw ApiException(
        message: data['message'] ?? 'Something went wrong',
        statusCode: response.statusCode,
        errors: data['errors'],
      );
    }
  }
}

class ApiException implements Exception {
  final String message;
  final int? statusCode;
  final dynamic errors;

  ApiException({
    required this.message,
    this.statusCode,
    this.errors,
  });

  @override
  String toString() => message;
}
