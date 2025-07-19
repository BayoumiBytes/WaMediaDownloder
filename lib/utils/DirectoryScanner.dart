import 'dart:io';

import 'package:mediadownloader/Services/MediaScanner.dart';
import 'package:mediadownloader/model/Media.dart';
import 'package:path/path.dart' as path;

const List<String> audioExtensions = [
  '.mp3',
  '.m4a',
  '.aac',
  '.wav',
  '.flac',
  '.ogg',
  '.wma',
  '.opus',
];

const List<String> videoExtensions = [
  '.mp4',
  '.avi',
  '.mov',
  '.mkv',
  '.wmv',
  '.flv',
  '.webm',
];

const List<String> imageExtensions = ['.jpg', '.png', '.jpeg'];

/// Scan a specific directory for media files
Future<List<MediaFile>> scanDirectory(String dirPath) async {
  List<MediaFile> files = [];

  try {
    final dir = Directory(dirPath);
    if (!await dir.exists()) {
      return files;
    }

    await for (FileSystemEntity entity in dir.list(recursive: true)) {
      if (entity is File) {
        // fileCount++;
        final filePath = entity.path;
        final fileName = filePath.split('/').last.toLowerCase();

        // Check if it's an audio or video file
        bool isAudio = audioExtensions.any((ext) => fileName.endsWith(ext));
        bool isVideo = videoExtensions.any((ext) => fileName.endsWith(ext));
        bool isImage = imageExtensions.any((ext) => fileName.endsWith(ext));

        const int MIN_FILE_SIZE = 1024 * 1024; // 1MB in bytes

        // Get file stats to check size
        final stats = await entity.stat();

        if (stats.size < MIN_FILE_SIZE && isAudio) {
          continue;
        }

        if (isAudio) {
          files.add(
            MediaFile(
              path: filePath,
              name: filePath.split('/').last,
              size: stats.size,
              dateModified: stats.modified,
              type: MediaType.audio,
            ),
          );
        } else if (isImage || isVideo) {
          files.add(
            MediaFile(
              path: filePath,
              name: filePath.split('/').last,
              size: stats.size,
              dateModified: stats.modified,
              type: isImage ? MediaType.image : MediaType.video,
            ),
          );
        }
      }
    }
  } catch (e) {
    print('Error scanning directory $dirPath: $e');
  }

  return files;
}

Future<String> getDownloadsDirectory(MediaFile file) async {
  Directory downloadsDir;
  if (file.type == MediaType.audio) {
    downloadsDir = Directory('/storage/emulated/0/Music/MediaSaver/');
  } else {
    downloadsDir = Directory('/storage/emulated/0/Download/MediaSaver/');
  }
  // Create the directory if it doesn't exist
  if (!await downloadsDir.exists()) {
    await downloadsDir.create(recursive: true);
  }

  return downloadsDir.path;
}

// Add this method right after _getDownloadsDirectory()
Future<int> downloadFile(MediaFile file) async {
  try {
    // Get the destination directory
    final String downloadsPath = await getDownloadsDirectory(file);

    // Get the original file
    final File originalFile = File(file.path);

    // Create destination file path
    final String fileName = path.basename(file.path);
    String destinationPath = path.join(downloadsPath, fileName);

    // Check if file already exists in destination
    final File destinationFile = File(destinationPath);

    if (await destinationFile.exists()) {
      // Check if it's the exact same file by comparing size and content
      final originalStats = await originalFile.stat();
      final destinationStats = await destinationFile.stat();

      // Compare file sizes first (quick check)
      if (originalStats.size == destinationStats.size) {
        // If sizes match, compare file contents to be absolutely sure
        final originalBytes = await originalFile.readAsBytes();
        final destinationBytes = await destinationFile.readAsBytes();

        // Compare byte by byte
        bool filesAreIdentical = true;
        if (originalBytes.length == destinationBytes.length) {
          for (int i = 0; i < originalBytes.length; i++) {
            if (originalBytes[i] != destinationBytes[i]) {
              filesAreIdentical = false;
              break;
            }
          }
        } else {
          filesAreIdentical = false;
        }

        if (filesAreIdentical) {
          // File already exists and is identical
          return 0;
        } else {
          return -1;
        }
      } else {
        return 1;
      }
    }

    // Copy the file to the destination
    await originalFile.copy(destinationPath);

    await MediaScanner.loadMedia(path: destinationPath);

    // Show success message
    return 1;
  } catch (e) {
    // // Show error message
    print('Error downloading file: $e');
    rethrow;
  }
}
