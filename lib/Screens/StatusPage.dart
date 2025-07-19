import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mediadownloader/Services/StatusScanner.dart';
import 'package:mediadownloader/model/Media.dart';
import 'package:mediadownloader/utils/DownloadDialog.dart';
import 'package:mediadownloader/utils/FileDetails.dart';
import 'package:mediadownloader/utils/PermissionHandler.dart';
import 'package:mediadownloader/utils/ShowSnackbar.dart';
import 'package:mediadownloader/utils/ThumnailBuilder.dart';
import 'package:mediadownloader/widgets/ImageDialog.dart';
import 'package:mediadownloader/widgets/VideoDialog.dart';

class StatusPage extends StatefulWidget {
  const StatusPage({super.key});

  @override
  State<StatefulWidget> createState() => _StatusPage();
}

class _StatusPage extends State<StatusPage> {
  List<MediaFile> mediaFiles = [];
  bool isScanning = false;
  String currentFilter = 'All';
  bool hasPermissions = false;

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
    setState(() {
      isScanning = true;
      mediaFiles.clear();
    });

    try {
      final scannedFiles = await Statusscanner.scanWhatsAppMedia();

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

  List<MediaFile> get filteredFiles {
    switch (currentFilter) {
      case 'Video':
        return mediaFiles.where((f) => f.type == MediaType.video).toList();
      case 'Image':
        return mediaFiles.where((f) => f.type == MediaType.image).toList();
      default:
        return mediaFiles;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('WhatsApp Media Scanner'),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              setState(() {
                currentFilter = value;
              });
            },
            itemBuilder: (context) => [
              PopupMenuItem(value: 'All', child: Text('All Files')),
              PopupMenuItem(value: 'Image', child: Text('Images Only')),
              PopupMenuItem(value: 'Video', child: Text('Videos Only')),
            ],
            child: Padding(
              padding: EdgeInsets.all(16),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [Text(currentFilter), Icon(Icons.arrow_drop_down)],
              ),
            ),
          ),
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
          if (filteredFiles.isNotEmpty)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                '${filteredFiles.length} files found',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          Expanded(
            child: filteredFiles.isEmpty
                ? Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.folder_open, size: 64, color: Colors.grey),
                        SizedBox(height: 16),
                        Text(
                          'No media files found',
                          style: TextStyle(fontSize: 18, color: Colors.grey),
                        ),
                        SizedBox(height: 8),
                        Text(
                          'Tap "Scan WhatsApp Media" to search for files',
                          style: TextStyle(color: Colors.grey),
                        ),
                      ],
                    ),
                  )
                : GridView.builder(
                    padding: EdgeInsets.all(16),
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 2,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                      childAspectRatio:
                          0.75, // Adjusted ratio to prevent overflow
                    ),
                    itemCount: filteredFiles.length,
                    itemBuilder: (context, index) {
                      final file = filteredFiles[index];
                      return GestureDetector(
                        onTap: () {
                          if (file.type == MediaType.video) {
                            showVideoDialog(context, file);
                          } else {
                            showDialog(
                              context: context,
                              builder: (context) => Dialog(
                                backgroundColor: Colors.transparent,
                                child: ImageDialog(file: file),
                              ),
                            );
                          }
                        },
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [
                              // Thumbnail section - takes most space
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.all(8),
                                  child: FutureBuilder<Widget>(
                                    future: buildThumbnail(file),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return Center(
                                          child: CircularProgressIndicator(
                                            strokeWidth: 1,
                                          ),
                                        );
                                      } else if (snapshot.hasError) {
                                        return buildFallbackIcon(file);
                                      } else {
                                        return snapshot.data!;
                                      }
                                    },
                                  ),
                                ),
                              ),

                              // Compact info section - fixed height
                              Container(
                                height: 60, // Fixed height to prevent overflow
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 4,
                                ),
                                child: Column(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    // Top row: Type badge + Download button
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // File type badge
                                        Container(
                                          padding: EdgeInsets.symmetric(
                                            horizontal: 6,
                                            vertical: 2,
                                          ),
                                          decoration: BoxDecoration(
                                            color: file.type == MediaType.image
                                                ? Colors.blue[100]
                                                : Colors.red[100],
                                            borderRadius: BorderRadius.circular(
                                              8,
                                            ),
                                          ),
                                          child: Text(
                                            file.type == MediaType.image
                                                ? 'IMG'
                                                : 'VID',
                                            style: TextStyle(
                                              fontSize: 9,
                                              fontWeight: FontWeight.bold,
                                              color:
                                                  file.type == MediaType.image
                                                  ? Colors.blue[700]
                                                  : Colors.red[700],
                                            ),
                                          ),
                                        ),

                                        // Download button
                                        GestureDetector(
                                          onTap: () {
                                            StartDownload(file, context);
                                          },
                                          child: Container(
                                            padding: EdgeInsets.all(4),
                                            decoration: BoxDecoration(
                                              color: Colors.green[100],
                                              shape: BoxShape.circle,
                                            ),
                                            child: Icon(
                                              Icons.download,
                                              size: 14,
                                              color: Colors.green[700],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),

                                    // Bottom row: File size and date
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        // File size
                                        Flexible(
                                          child: Text(
                                            details.formatFileSize(file.size),
                                            style: TextStyle(
                                              fontSize: 10,
                                              color: Colors.grey[600],
                                              fontWeight: FontWeight.w500,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),

                                        // Date (simplified)
                                        Flexible(
                                          child: Text(
                                            '${file.dateModified.day}/${file.dateModified.month}',
                                            style: TextStyle(
                                              fontSize: 9,
                                              color: Colors.grey[500],
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
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
