import 'package:flutter/material.dart';
import 'dart:io';
import 'package:photo_view/photo_view.dart';

class ReceiptViewerScreen extends StatelessWidget {
  final String imagePath;
  final String expenseDescription;

  const ReceiptViewerScreen({
    super.key,
    required this.imagePath,
    required this.expenseDescription,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(expenseDescription)),
      body: Container(
        child: PhotoView(
          imageProvider: FileImage(File(imagePath)),
          backgroundDecoration: BoxDecoration(color: Colors.black),
          minScale: PhotoViewComputedScale.contained * 0.8,
          maxScale: PhotoViewComputedScale.covered * 2.0,
        ),
      ),
    );
  }
}
