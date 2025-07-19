import 'dart:io';
import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:mediadownloader/model/Media.dart';
import 'package:video_thumbnail/video_thumbnail.dart';

Future<Widget> buildThumbnail(MediaFile file) async {
  if (file.type == MediaType.image) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(8),
      child: Image.file(
        File(file.path),
        fit: BoxFit.cover,
        width: double.infinity,
        height: double.infinity,
        errorBuilder: (context, error, stackTrace) {
          return buildFallbackIcon(file);
        },
      ),
    );
  } else if (file.type == MediaType.video) {
    final Uint8List? thumbnail = await VideoThumbnail.thumbnailData(
      video: file.path,
      imageFormat: ImageFormat.JPEG,
      maxWidth: 128,
      quality: 75,
    );

    if (thumbnail == null) {
      print("failed");
      return buildFallbackIcon(file);
    }
    return Stack(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(8),
          child: Image.memory(
            thumbnail,
            fit: BoxFit.cover,
            width: double.infinity,
            height: double.infinity,
            errorBuilder: (context, error, stackTrace) {
              return buildFallbackIcon(file);
            },
          ),
        ),
        // Play button overlay for videos
        Positioned.fill(
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              color: Colors.black26,
            ),
            child: Center(
              child: Container(
                padding: EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black54,
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.play_arrow, color: Colors.white, size: 24),
              ),
            ),
          ),
        ),
      ],
    );
  }

  return buildFallbackIcon(file);
}

Widget buildFallbackIcon(MediaFile file) {
  return Container(
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(8),
      color: file.type == MediaType.image ? Colors.blue[100] : Colors.red[100],
    ),
    child: Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            file.type == MediaType.image ? Icons.image : Icons.video_file,
            color: file.type == MediaType.image ? Colors.blue : Colors.red,
            size: 32,
          ),
          SizedBox(height: 4),
          Text(
            file.type == MediaType.image ? 'IMG' : 'VID',
            style: TextStyle(
              color: file.type == MediaType.image ? Colors.blue : Colors.red,
              fontSize: 10,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    ),
  );
}
