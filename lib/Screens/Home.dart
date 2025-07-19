import 'package:flutter/material.dart';
import 'package:mediadownloader/Services/AudioScanner.dart';
import 'package:mediadownloader/manager/InterstitialAdManager.dart';
import 'package:mediadownloader/model/Media.dart';
import 'package:mediadownloader/utils/FileDetails.dart';
import 'package:mediadownloader/utils/PermissionHandler.dart';
import 'package:mediadownloader/utils/ShowSnackbar.dart';
import 'package:mediadownloader/widgets/FileDetails.dart';
import 'package:mediadownloader/widgets/MusicPlayer.dart';
import 'package:mediadownloader/widgets/PermissionDialog.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<StatefulWidget> createState() => _Home();
}

class _Home extends State<Home> {
  List<MediaFile> mediaFiles = [];
  bool isScanning = false;
  bool hasPermissions = false;
  String currentFilter = 'All';

  @override
  void initState() {
    super.initState();
    if (mediaFiles.isEmpty) {
      setState(() {
        _initAsync();
      });
    }
  }

  Future<void> _initAsync() async {
    final granted = await Permissionhandler.checkPermissions();
    if (granted) {
      setState(() {
        hasPermissions = true;
      });
      scanWhatsAppMedia();
    }
  }

  Future<void> scanWhatsAppMedia() async {
    if (!hasPermissions) {
      final granted = await Permissionhandler.checkPermissions();
      setState(() async {
        if (granted) hasPermissions = true;
      });
      if (!hasPermissions) {
        showPermissionDialog(context);
        return;
      }
    }

    setState(() {
      isScanning = true;
      mediaFiles.clear();
    });

    try {
      final scannedFiles = await Audioscanner.scanWhatsAppMedia();

      setState(() {
        mediaFiles = scannedFiles;
      });
    } catch (e) {
      if (mounted) showAppSnackbar(context, 'Error scanning files: $e');
    }

    setState(() {
      isScanning = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('WhatsApp Music'), actions: [

        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: isScanning ? null : scanWhatsAppMedia,
                    icon: isScanning
                        ? SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.search),
                    label: Text(
                      isScanning ? 'Scanning...' : 'Scan WhatsApp Media',
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (!hasPermissions)
            Container(
              padding: EdgeInsets.all(16),
              child: Card(
                color: Colors.orange[100],
                child: Padding(
                  padding: EdgeInsets.all(16),
                  child: Row(
                    children: [
                      Icon(Icons.warning, color: Colors.orange),
                      SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Storage permission is required to scan WhatsApp files',
                          style: TextStyle(color: Colors.orange[800]),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          Expanded(
            child: ListView.builder(
              padding: EdgeInsets.all(16),
              itemCount: mediaFiles.length,
              itemBuilder: (context, index) {
                final file = mediaFiles[index];
                return Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: file.type == MediaType.audio
                          ? Colors.blue
                          : Colors.red,
                      child: Icon(
                        file.type == MediaType.audio
                            ? Icons.music_note
                            : Icons.video_file,
                        color: Colors.white,
                      ),
                    ),
                    title: Text(
                      file.name,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Size: ${details.formatFileSize(file.size)}'),
                        Text(
                          'Modified: ${details.formatDate(file.dateModified)}',
                        ),
                      ],
                    ),

                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: Icon(Icons.play_arrow),
                          onPressed: () {
                            // showMusicPlayer(file);
                            showDialog(
                              context: context,
                              builder: (context) => Player(file: file),
                            );
                          },
                          tooltip: 'Play',
                        ),
                      ],
                    ),
                    onTap: () {
                      showFileDetails(context, file);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
