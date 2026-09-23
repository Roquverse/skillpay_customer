import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

/// Uploads files directly to Cloudinary using an unsigned upload preset.
/// No backend involvement required — credentials come from .env.
class CloudinaryService {
  CloudinaryService._();
  static final CloudinaryService instance = CloudinaryService._();

  String get _cloudName =>
      dotenv.env['CLOUDINARY_CLOUD_NAME'] ?? 'your_cloud_name';
  String get _uploadPreset =>
      dotenv.env['CLOUDINARY_UPLOAD_PRESET'] ?? 'skillpay_chat';

  /// Determine the correct Cloudinary resource type based on extension.
  String _resourceType(String path) {
    final ext = path.split('.').last.toLowerCase();
    if (['jpg', 'jpeg', 'png', 'gif', 'webp', 'heic'].contains(ext)) {
      return 'image';
    }
    if (['mp4', 'mov', 'avi', 'mp3', 'm4a', 'wav', 'aac', 'ogg'].contains(ext)) {
      return 'video'; // Cloudinary uses "video" resource type for audio too
    }
    return 'raw'; // PDFs, docs, etc.
  }

  /// Upload [file] to Cloudinary and return the secure public URL.
  Future<String> upload(File file) async {
    final resourceType = _resourceType(file.path);
    final uri = Uri.parse(
      'https://api.cloudinary.com/v1_1/$_cloudName/$resourceType/upload',
    );

    final bytes = await file.readAsBytes();
    final fileName = file.path.split('/').last;

    final request = http.MultipartRequest('POST', uri)
      ..fields['upload_preset'] = _uploadPreset
      ..fields['folder'] = 'skillpay/chat'
      ..files.add(http.MultipartFile.fromBytes(
        'file',
        bytes,
        filename: fileName,
      ));

    final streamedResponse = await request.send();
    final response = await http.Response.fromStream(streamedResponse);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body) as Map<String, dynamic>;
      final url = data['secure_url'] as String?;
      if (url != null && url.isNotEmpty) return url;
      throw Exception('Cloudinary returned no URL');
    } else {
      debugPrint('[CloudinaryService] Error: \${response.body}');
      throw Exception(
        'Cloudinary upload failed (\${response.statusCode})',
      );
    }
  }

  static bool isVoiceNote(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.m4a') ||
        lower.contains('.mp3') ||
        lower.contains('.wav') ||
        lower.contains('.aac') ||
        lower.contains('.ogg');
  }

  static bool isImage(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.jpg') ||
        lower.contains('.jpeg') ||
        lower.contains('.png') ||
        lower.contains('.gif') ||
        lower.contains('.webp') ||
        lower.contains('/image/upload/');
  }

  static bool isDocument(String url) {
    final lower = url.toLowerCase();
    return lower.contains('.pdf') ||
        lower.contains('.doc') ||
        lower.contains('.docx') ||
        lower.contains('/raw/upload/');
  }
}
