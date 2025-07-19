import 'dart:io';

import 'package:flutter/material.dart';
import 'package:mediadownloader/manager/InterstitialAdManager.dart';
import 'package:mediadownloader/model/Media.dart';
import 'package:mediadownloader/utils/DirectoryScanner.dart';
import 'package:mediadownloader/utils/FileDialogs.dart';
import 'package:mediadownloader/utils/ShowSnackbar.dart';
import 'package:mediadownloader/widgets/DownloadDialog.dart';
import 'package:path/path.dart' as path;

final InterstitialAdManager _adManager = InterstitialAdManager();
void StartDownload(MediaFile file, BuildContext context) {
  // Show interstitial ad before starting download
  if (_adManager.isAdReady()) {
    // _adManager.onDownloadStarted();
    // Show ad first, then download
    // _adManager.showInterstitialAd(
    //   onAdClosed: () {
    //     print('Ad closed, starting download'); // Debug
    //     showDownloadDialog(file, context);
    //   },
    // );
    _adManager.onDownloadStarted(
      onAdClosed: () {
        showDownloadDialog(file, context);
      },
    );
    // showDownloadDialog(file, context);
  } else {
    // No ad available, proceed directly
    print('No ad available, proceeding with download'); // Debug
    showDownloadDialog(file, context);
  }
}

Future<void> showDownloadDialog(MediaFile file, BuildContext context) async {
  showDialog(
    context: context,
    barrierDismissible: false,
    builder: (context) => Downloaddialog(),
  );

  final result = await downloadFile(file);

  // Close loading dialog

  if (result == 1) {
    showAppSnackbar(context, 'File saved succesfuly');
  } else if (result == 0) {
    showAppSnackbar(context, 'File already Exist');
  } else if (result == -1) {
    // Get the destination directory
    final String downloadsPath = await getDownloadsDirectory(file);

    // Get the original file
    final File originalFile = File(file.path);

    // Create destination file path
    final String fileName = path.basename(file.path);
    String destinationPath = path.join(downloadsPath, fileName);
    showFileExistsDialog(
      context,
      originalFile,
      destinationPath,
      fileName,
      downloadsPath,
    );
  }
  if (context.mounted) {
    Navigator.pop(context);
  }
}
