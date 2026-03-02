import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Service for uploading files to Cloudinary.
class CloudinaryUploadService {
  // Replace these with actual Cloudinary credentials or load them from env variables
  static String get cloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? '';
  static String get uploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? '';

  /// Uploads a file to Cloudinary and returns the secure URL of the uploaded image.
  /// If the upload fails, it returns null.
  static Future<String?> uploadImage(File file) async {
    final url = Uri.parse(
      'https://api.cloudinary.com/v1_1/$cloudName/image/upload',
    );

    try {
      final request = http.MultipartRequest('POST', url)
        ..fields['upload_preset'] = uploadPreset
        ..files.add(await http.MultipartFile.fromPath('file', file.path));

      final response = await request.send();
      if (response.statusCode == 200 || response.statusCode == 201) {
        final respStr = await response.stream.bytesToString();
        final jsonResult = json.decode(respStr);
        return jsonResult['secure_url'];
      } else {
        final errorStr = await response.stream.bytesToString();
        debugPrint(
          'Cloudinary upload failed: ${response.statusCode} - $errorStr',
        );
        return null;
      }
    } catch (e) {
      debugPrint('Cloudinary upload error: $e');
      return null;
    }
  }
}
