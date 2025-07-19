import 'dart:io';
import 'package:flutter/material.dart';
import 'package:mediadownloader/utils/ShowSnackbar.dart';
import 'package:path/path.dart' as path;

void showFileExistsDialog(
  BuildContext context,
  File originalFile,
  String destinationPath,
  String fileName,
  String downloadsPath,
) {
  showDialog(
    context: context,
    builder: (context) => AlertDialog(
      title: Text('File Already Exists'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'A file with the name "$fileName" already exists in the destination folder.',
          ),
          SizedBox(height: 10),
          Text('What would you like to do?'),
        ],
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () async {
            Navigator.of(context).pop();
            // Replace the existing file
            try {
              await originalFile.copy(destinationPath);
              showAppSnackbar(context, 'File replaced');
            } catch (e) {
              showAppSnackbar(context, 'Error replacing file: $e');
            }
          },
          child: Text('Replace'),
        ),
        ElevatedButton(
          onPressed: () async {
            Navigator.of(context).pop();
            // Save with a new name
            try {
              final String nameWithoutExt = path.basenameWithoutExtension(
                fileName,
              );
              final String extension = path.extension(fileName);
              int counter = 1;
              String newDestinationPath;

              do {
                newDestinationPath = path.join(
                  downloadsPath,
                  '${nameWithoutExt}_$counter$extension',
                );
                counter++;
              } while (await File(newDestinationPath).exists());

              await originalFile.copy(newDestinationPath);
              showAppSnackbar(
                context,
                'Downloaded as: ${nameWithoutExt}_$counter$extension',
              );
            } catch (e) {
              showAppSnackbar(context, 'Error saving file: $e');
            }
          },
          child: Text('Save as New'),
        ),
      ],
    ),
  );
}
