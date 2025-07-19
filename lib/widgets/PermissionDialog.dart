import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';

void showPermissionDialog(BuildContext context) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return Permissiondialog();
    },
  );
}

class Permissiondialog extends StatelessWidget {
  const Permissiondialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('Storage Permission Required'),
      content: Text(
        'This app needs storage permission to scan WhatsApp media files. '
        'Please grant the permission in Settings.',
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.of(context).pop(),
          child: Text('Cancel'),
        ),
        TextButton(
          onPressed: () {
            Navigator.of(context).pop();
            openAppSettings();
          },
          child: Text('Open Settings'),
        ),
      ],
    );
  }
}
