import 'package:flutter/material.dart';

class Downloaddialog extends StatelessWidget {
  const Downloaddialog({super.key});

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      content: Row(
        children: [
          CircularProgressIndicator(),
          SizedBox(width: 20),
          Text('Downloading...'),
        ],
      ),
    );
  }
}
