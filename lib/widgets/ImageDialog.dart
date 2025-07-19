import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mediadownloader/model/Media.dart';
import 'package:mediadownloader/utils/DownloadDialog.dart';

class ImageDialog extends StatelessWidget {
  final MediaFile file;
  const ImageDialog({super.key, required this.file});

  @override
  Widget build(BuildContext context) {
    return Stack(
      alignment: Alignment.bottomCenter,
      children: [
        Container(
          decoration: BoxDecoration(shape: BoxShape.circle),
          child: InteractiveViewer(child: Image.file(File(file.path))),
        ),
        Positioned(
          top: 8,
          right: 8,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          bottom: 18,
          right: 18,
          child: GestureDetector(
            onTap: () {
              StartDownload(file, context);
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.green[100],
                shape: BoxShape.circle,
              ),
              child: Icon(Icons.download, size: 24, color: Colors.green[700]),
            ),
          ),
        ),
      ],
    );
  }
}
