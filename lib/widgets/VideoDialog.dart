import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mediadownloader/model/Media.dart';
import 'package:mediadownloader/utils/DownloadDialog.dart';
import 'package:mediadownloader/utils/ShowSnackbar.dart';
import 'package:video_player/video_player.dart';

void showVideoDialog(BuildContext context, MediaFile videoPath) {
  showDialog(
    context: context,
    builder: (context) => Dialog(
      child: VideoPlayerScreen(videoPath: videoPath.path, file: videoPath),
    ),
  );
}

class VideoPlayerScreen extends StatefulWidget {
  final String videoPath;
  final MediaFile file;

  const VideoPlayerScreen({
    super.key,
    required this.videoPath,
    required this.file,
  });

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreen();
}

class _VideoPlayerScreen extends State<VideoPlayerScreen> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize()
          .then((_) {
            _controller.setVolume(1);
            setState(() {});
            _controller.play();
          })
          .catchError((error) {
            // Handle initialization error
            Navigator.of(context).pop();
            showAppSnackbar(context, 'error happened $error');
          });
    ;
  }

  @override
  void dispose() {
    if (_controller.value.isInitialized) {
      _controller.pause();
    }
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AspectRatio(
      aspectRatio: _controller.value.isInitialized
          ? _controller.value.aspectRatio
          : 16 / 9,
      child: _controller.value.isInitialized
          ? Stack(
              alignment: Alignment.bottomCenter,
              children: [
                VideoPlayer(_controller),
                VideoProgressIndicator(_controller, allowScrubbing: true),
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
                      StartDownload(widget.file, context);
                      Navigator.pop(context);
                    },
                    child: Container(
                      padding: EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: Colors.green[100],
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        Icons.download,
                        size: 24,
                        color: Colors.green[700],
                      ),
                    ),
                  ),
                ),
              ],
            )
          : const Center(child: CircularProgressIndicator()),
    );
  }
}
