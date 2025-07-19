import 'dart:io';

import 'package:mediadownloader/model/Media.dart';
import 'package:mediadownloader/utils/DirectoryScanner.dart';

class Statusscanner {
  // Video extensions

  static Future<String> getStatusPath() async {
    List<String> paths = [
      '/storage/emulated/0/Android/media/com.whatsapp/WhatsApp/Media/.Statuses/',
      '/storage/emulated/0/WhatsApp/Media/.Statuses/',
      '/sdcard/WhatsApp/Media/.Statuses/',
      '/sdcard/Android/media/com.whatsapp/WhatsApp/Media/.Statuses/',
    ];
    String result = '';

    for (String path in paths) {
      final dir = Directory(path);
      if (await dir.exists()) {
        result = path;
      }
    }

    return result;
  }

  /// Scan WhatsApp media directories and return list of media files
  static Future<List<MediaFile>> scanWhatsAppMedia() async {
    List<MediaFile> mediaFiles = [];

    try {
      final whatsappPaths = await getStatusPath();

      if (whatsappPaths.isEmpty) {
        throw Exception('WhatsApp media folders not found');
      }

      final files = await scanDirectory(whatsappPaths);
      mediaFiles.addAll(files);

      // Sort files by date (newest first)
      mediaFiles.sort((a, b) => b.dateModified.compareTo(a.dateModified));

      return mediaFiles;
    } catch (e) {
      print('Error scanning WhatsApp media: $e');
      rethrow;
    }
  }
}
