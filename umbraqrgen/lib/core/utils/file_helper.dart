import 'dart:io';
import 'dart:typed_data';
import 'package:uuid/uuid.dart';
import 'package:path_provider/path_provider.dart';
import 'package:photo_manager/photo_manager.dart';

const _uuid = Uuid();

enum QrType { website, wifi, contact }

class SavedImage {
  final String id;
  final String fileName;
  final String filePath;
  final QrType type;
  final String caption;
  final DateTime createdAt;

  const SavedImage({
    required this.id,
    required this.fileName,
    required this.filePath,
    required this.type,
    required this.caption,
    required this.createdAt,
  });
}

class FileHelper {
  FileHelper._();

  static Future<String?> saveToGallery(
    Uint8List imageData,
    QrType type,
    String caption,
  ) async {
    try {
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final typeStr = type == QrType.website ? 'url' : type.name;
      final fileName = 'UmbraQR_${typeStr}_$timestamp.png';

      final result = await PhotoManager.editor.saveImage(
        imageData,
        filename: fileName,
      );

      return result?.id;
    } catch (e) {
      return null;
    }
  }

  static Future<List<SavedImage>> loadSavedImages() async {
    return [];
  }

  static Future<bool> deleteImage(SavedImage image) async {
    try {
      final file = File(image.filePath);
      if (await file.exists()) {
        await file.delete();
        return true;
      }
    } catch (e) {
      return false;
    }
    return false;
  }

  static Future<String?> saveToTemp(Uint8List imageData) async {
    try {
      final tempDir = await getTemporaryDirectory();
      final fileName = 'share_qr_${_uuid.v4()}.png';
      final file = File('${tempDir.path}/$fileName');
      await file.writeAsBytes(imageData);
      return file.path;
    } catch (e) {
      return null;
    }
  }
}
