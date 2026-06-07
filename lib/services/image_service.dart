import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:cached_network_image/cached_network_image.dart';
import '../config/api_config.dart';

class ImageService {
  static final Map<String, Uint8List> _imageCache = {};

  // Get full image URL with proper base URL
  static String getFullImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) return '';

    // If it's already a full URL, return it
    if (imagePath.startsWith('http')) {
      return imagePath;
    }

    // Otherwise, prepend the base URL
    return '${ApiConfig.baseUrl}/storage/$imagePath';
  }

  // Load image with custom headers to bypass CORS
  static Future<Uint8List?> loadImage(String url) async {
    if (_imageCache.containsKey(url)) {
      return _imageCache[url];
    }

    try {
      final response = await http.get(
        Uri.parse(url),
        headers: {
          'Accept': 'image/webp,image/apng,image/*,*/*;q=0.8',
          'User-Agent': 'Mozilla/5.0',
        },
      );

      if (response.statusCode == 200) {
        _imageCache[url] = response.bodyBytes;
        return response.bodyBytes;
      }
    } catch (e) {
      print('Failed to load image: $e');
    }
    return null;
  }

  // Check if image exists
  static Future<bool> imageExists(String url) async {
    try {
      final response = await http.head(Uri.parse(url));
      return response.statusCode == 200;
    } catch (e) {
      return false;
    }
  }
}
