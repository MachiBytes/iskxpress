import 'dart:io';
import 'package:path/path.dart' as path;

class BaseApiService {
  static const String baseUrl = 'http://54.255.209.101:5000';
  
  static const Map<String, String> jsonHeaders = {
    'Content-Type': 'application/json',
  };

  // Helper method to get MIME type based on file extension
  static String? getMimeType(String filePath) {
    final extension = path.extension(filePath).toLowerCase();
    
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return 'image/jpeg';
      case '.png':
        return 'image/png';
      case '.gif':
        return 'image/gif';
      case '.bmp':
        return 'image/bmp';
      case '.webp':
        return 'image/webp';
      case '.heic':
        return 'image/heic';
      case '.heif':
        return 'image/heif';
      case '.tiff':
      case '.tif':
        return 'image/tiff';
      default:
        return 'image/jpeg'; // Default fallback
    }
  }

  // Helper method to check if file exists
  static Future<bool> fileExists(File file) async {
    return await file.exists();
  }

  // Helper method to get file size
  static Future<int> getFileSize(File file) async {
    return await file.length();
  }
} 