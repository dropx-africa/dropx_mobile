import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import '../app_config.dart';

/// Service for uploading files to Cloudinary.
class CloudinaryUploadService {
  static const String cloudName = AppConfig.cloudinaryCloudName;
  static const String uploadPreset = AppConfig.cloudinaryUploadPreset;

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
