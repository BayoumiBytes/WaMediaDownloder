import 'package:flutter/material.dart';
import 'package:mediadownloader/model/Media.dart';
import 'package:mediadownloader/utils/DownloadDialog.dart';
import 'package:mediadownloader/utils/FileDetails.dart';
import 'package:mediadownloader/widgets/MusicPlayer.dart';

void showFileDetails(BuildContext context, MediaFile file) {
  showDialog(
    context: context,
    builder: (context) => Filedetails(file: file),
  );
}

class Filedetails extends StatefulWidget {
  final MediaFile file;
  const Filedetails({super.key, required this.file});

  @override
  State<Filedetails> createState() => _FiledetailsState();
}

class _FiledetailsState extends State<Filedetails> {
  @override
  Widget build(BuildContext context) {
    final file = widget.file;
    return AlertDialog(
      title: Text('File Details'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Name: ${file.name}'),
          SizedBox(height: 8),
          Text('Size: ${details.formatFileSize(file.size)}'),
          SizedBox(height: 8),
          Text('Type: ${file.type == MediaType.audio ? 'Audio' : 'Video'}'),
          SizedBox(height: 8),
          Text('Modified: ${details.formatDate(file.dateModified)}'),
          SizedBox(height: 8),
          Text('Path: ${file.path}'),
        ],
      ),

      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Close'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            StartDownload(file, context);
          },
          child: Text('Download'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            showDialog(
              context: context,
              builder: (context) => Player(file: file),
            );
          },
          child: Text('Play'),
        ),
      ],
    );
  }
}
