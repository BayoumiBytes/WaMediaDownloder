import 'package:flutter/material.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:async';

class MusicPlayer extends StatefulWidget {
  final String filePath;
  final String fileName;

  const MusicPlayer({Key? key, required this.filePath, required this.fileName})
    : super(key: key);

  @override
  _MusicPlayerState createState() => _MusicPlayerState();
}

class _MusicPlayerState extends State<MusicPlayer> {
  late AudioPlayer _audioPlayer;
  bool _isPlaying = false;
  bool _isPaused = false;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isLoading = true;

  // Stream subscriptions to cancel them properly
  StreamSubscription? _playerStateSubscription;
  StreamSubscription? _durationSubscription;
  StreamSubscription? _positionSubscription;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _initializePlayer();
  }

  Future<void> _initializePlayer() async {
    try {
      // Listen to player state changes
      _playerStateSubscription = _audioPlayer.onPlayerStateChanged.listen((
        PlayerState state,
      ) {
        if (mounted) {
          // Check if widget is still mounted
          setState(() {
            _isPlaying = state == PlayerState.playing;
            _isPaused = state == PlayerState.paused;
            _isLoading = false;
          });
        }
      });

      // Listen to duration changes
      _durationSubscription = _audioPlayer.onDurationChanged.listen((
        Duration duration,
      ) {
        if (mounted) {
          // Check if widget is still mounted
          setState(() {
            _duration = duration;
            _isLoading = false;
          });
        }
      });

      // Listen to position changes
      _positionSubscription = _audioPlayer.onPositionChanged.listen((
        Duration position,
      ) {
        if (mounted) {
          // Check if widget is still mounted
          setState(() {
            _position = position;
          });
        }
      });

      // Load the audio file
      await _audioPlayer.setSourceDeviceFile(widget.filePath);
      if (mounted) {
        await _audioPlayer.resume();
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        // Show error to user
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error loading audio: $e')));
      }
    }
  }

  Future<void> _playPause() async {
    try {
      if (_isPlaying) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.resume();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text('Error playing audio: $e')));
      }
    }
  }

  Future<void> _stop() async {
    try {
      await _audioPlayer.stop();
      if (mounted) {
        setState(() {
          _position = Duration.zero;
        });
      }
    } catch (e) {
      print('Error stopping: $e');
    }
  }

  Future<void> _seek(Duration position) async {
    try {
      await _audioPlayer.seek(position);
    } catch (e) {
      print('Error seeking: $e');
    }
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return '$minutes:$seconds';
  }

  @override
  void dispose() {
    // Cancel all stream subscriptions before disposing
    _playerStateSubscription?.cancel();
    _durationSubscription?.cancel();
    _positionSubscription?.cancel();

    // Stop and dispose the audio player
    _audioPlayer.stop();
    _audioPlayer.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Song title
          Text(
            widget.fileName,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
          SizedBox(height: 20),

          // Progress bar
          Column(
            children: [
              Slider(
                value: _duration.inMilliseconds > 0
                    ? _position.inMilliseconds / _duration.inMilliseconds
                    : 0.0,
                onChanged: _duration.inMilliseconds > 0
                    ? (value) {
                        final position = Duration(
                          milliseconds: (value * _duration.inMilliseconds)
                              .round(),
                        );
                        _seek(position);
                      }
                    : null,
              ),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(_formatDuration(_position)),
                    Text(_formatDuration(_duration)),
                  ],
                ),
              ),
            ],
          ),

          SizedBox(height: 20),

          // Control buttons
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              IconButton(
                onPressed: _stop,
                icon: Icon(Icons.stop),
                iconSize: 32,
              ),
              IconButton(
                onPressed: _isLoading ? null : _playPause,
                icon: _isLoading
                    ? SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : Icon(_isPlaying ? Icons.pause : Icons.play_arrow),
                iconSize: 48,
              ),
              IconButton(
                onPressed: () {
                  // Close player
                  Navigator.of(context).pop();
                },
                icon: Icon(Icons.close),
                iconSize: 32,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
