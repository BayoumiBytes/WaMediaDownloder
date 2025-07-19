import 'dart:async';

import 'package:flutter/services.dart';

class MediaScanner {
  /// Define Method Channel
  static const MethodChannel _channel = const MethodChannel('media_scanner');

  static Future<String?> loadMedia({String? path}) async {
    try {
      return await _channel.invokeMethod('refreshGallery', {"path": path});
    } catch (e) {
      // Log the error but don't fail the operation
      print('Warning: Media scanner refresh failed: $e');
      // Return null instead of throwing
      return null;
    }
  }
}
