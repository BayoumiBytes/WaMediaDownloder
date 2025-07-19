import 'package:flutter/material.dart';
import 'package:mediadownloader/model/Media.dart';
import 'package:mediadownloader/utils/DownloadDialog.dart';
import 'package:mediadownloader/utils/MusicPlayer.dart';

class Player extends StatefulWidget {
  final MediaFile file;
  const Player({super.key, required this.file});

  @override
  State<StatefulWidget> createState() => _Player();
}

class _Player extends State<Player> {
  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    return AlertDialog(
      title: Text('Music Player'),
      content: Container(
        width: double.maxFinite,
        child: MusicPlayer(filePath: file.path, fileName: file.name),
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.download, color: Colors.green),
          onPressed: () => StartDownload(file, context),
          tooltip: 'Download',
        ),
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
      ],
    );
  }
}
