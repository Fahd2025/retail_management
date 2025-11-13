import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:image_picker/image_picker.dart';
import 'package:image/image.dart' as img;
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart' as path;

/// Service for handling image operations including picking, optimization, and storage
class ImageService {
  static final ImagePicker _picker = ImagePicker();

  // Maximum dimensions for company logo
  static const int maxWidth = 800;
  static const int maxHeight = 800;

  // JPEG quality for compression (0-100)
  static const int quality = 85;

  /// Pick an image from gallery or camera
  /// Returns the picked image file/bytes or null if cancelled
  static Future<XFile?> pickImage({
    ImageSource source = ImageSource.gallery,
  }) async {
    try {
      final XFile? image = await _picker.pickImage(
        source: source,
        maxWidth: maxWidth.toDouble(),
        maxHeight: maxHeight.toDouble(),
        imageQuality: quality,
      );
      return image;
    } catch (e) {
      print('Error picking image: $e');
      return null;
    }
  }

  /// Optimize image: resize and compress
  /// Returns optimized image bytes
  static Future<Uint8List> optimizeImage(Uint8List imageBytes) async {
    try {
      // Decode the image
      img.Image? image = img.decodeImage(imageBytes);

      if (image == null) {
        throw Exception('Failed to decode image');
      }

      // Calculate new dimensions while maintaining aspect ratio
      int targetWidth = image.width;
      int targetHeight = image.height;

      if (image.width > maxWidth || image.height > maxHeight) {
        final aspectRatio = image.width / image.height;

        if (image.width > image.height) {
          targetWidth = maxWidth;
          targetHeight = (maxWidth / aspectRatio).round();
        } else {
          targetHeight = maxHeight;
          targetWidth = (maxHeight * aspectRatio).round();
        }

        // Resize image
        image = img.copyResize(
          image,
          width: targetWidth,
          height: targetHeight,
          interpolation: img.Interpolation.linear,
        );
      }

      // Encode to JPEG with compression
      final optimizedBytes = img.encodeJpg(image, quality: quality);
      return Uint8List.fromList(optimizedBytes);
    } catch (e) {
      print('Error optimizing image: $e');
      rethrow;
    }
  }

  /// Convert image bytes to base64 string (for web storage)
  static String imageToBase64(Uint8List imageBytes) {
    return base64Encode(imageBytes);
  }

  /// Convert base64 string back to image bytes
  static Uint8List base64ToImage(String base64String) {
    return base64Decode(base64String);
  }

  /// Save image to file storage (for mobile)
  /// Returns the file path where the image was saved
  static Future<String> saveImageToFile(
    Uint8List imageBytes,
    String fileName,
  ) async {
    if (kIsWeb) {
      throw Exception('File storage not available on web platform');
    }

    try {
      // Get application documents directory
      final directory = await getApplicationDocumentsDirectory();

      // Create logos subdirectory if it doesn't exist
      final logosDir = Directory(path.join(directory.path, 'logos'));
      if (!await logosDir.exists()) {
        await logosDir.create(recursive: true);
      }

      // Create file path
      final filePath = path.join(logosDir.path, fileName);

      // Write file
      final file = File(filePath);
      await file.writeAsBytes(imageBytes);

      return filePath;
    } catch (e) {
      print('Error saving image to file: $e');
      rethrow;
    }
  }

  /// Load image from file path
  static Future<Uint8List> loadImageFromFile(String filePath) async {
    if (kIsWeb) {
      throw Exception('File storage not available on web platform');
    }

    try {
      final file = File(filePath);
      if (!await file.exists()) {
        throw Exception('Image file not found: $filePath');
      }
      return await file.readAsBytes();
    } catch (e) {
      print('Error loading image from file: $e');
      rethrow;
    }
  }

  /// Delete image file
  static Future<void> deleteImageFile(String filePath) async {
    if (kIsWeb) {
      return; // No file deletion needed on web
    }

    try {
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
    } catch (e) {
      print('Error deleting image file: $e');
    }
  }

  /// Process picked image for storage
  /// For web: returns base64 string
  /// For mobile: saves to file and returns file path
  static Future<String> processImageForStorage(XFile imageFile) async {
    try {
      // Read image bytes
      final bytes = await imageFile.readAsBytes();

      // Optimize image
      final optimizedBytes = await optimizeImage(bytes);

      if (kIsWeb) {
        // For web: convert to base64
        return 'data:image/jpeg;base64,${imageToBase64(optimizedBytes)}';
      } else {
        // For mobile: save to file
        final fileName =
            'company_logo_${DateTime.now().millisecondsSinceEpoch}.jpg';
        final filePath = await saveImageToFile(optimizedBytes, fileName);
        return filePath;
      }
    } catch (e) {
      print('Error processing image for storage: $e');
      rethrow;
    }
  }

  /// Get image bytes from storage path
  /// Handles both base64 strings (web) and file paths (mobile)
  static Future<Uint8List?> getImageBytes(String? storagePath) async {
    if (storagePath == null || storagePath.isEmpty) {
      return null;
    }

    try {
      if (storagePath.startsWith('data:image')) {
        // Base64 string from web
        final base64String = storagePath.split(',').last;
        return base64ToImage(base64String);
      } else if (storagePath.startsWith('assets/')) {
        // Asset image (not implemented here, handle in UI layer)
        return null;
      } else {
        // File path from mobile
        return await loadImageFromFile(storagePath);
      }
    } catch (e) {
      print('Error getting image bytes: $e');
      return null;
    }
  }

  /// Clean up old logo file when updating
  static Future<void> cleanupOldLogo(String? oldLogoPath) async {
    if (oldLogoPath == null || oldLogoPath.isEmpty) {
      return;
    }

    // Don't delete asset images or base64 data
    if (oldLogoPath.startsWith('assets/') ||
        oldLogoPath.startsWith('data:image')) {
      return;
    }

    // Delete file on mobile
    if (!kIsWeb) {
      await deleteImageFile(oldLogoPath);
    }
  }
}
