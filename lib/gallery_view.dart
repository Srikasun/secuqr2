import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'package:secuqr/colors/appcolor.dart';

class GalleryView extends StatefulWidget {
  const GalleryView({
    super.key,
    required this.title,
    this.text,
    required this.onImage,
    required this.onDetectorViewModeChanged,
  });

  final String title;
  final String? text;
  final Function(InputImage inputImage) onImage;
  final Function()? onDetectorViewModeChanged;

  @override
  State<GalleryView> createState() => _GalleryViewState();
}

class _GalleryViewState extends State<GalleryView> {
  File? _image;
  String? _path;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.statusBarColor,
        title: Text(
          widget.title,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 20.0),
            child: GestureDetector(
              onTap: widget.onDetectorViewModeChanged,
              child: const Icon(
                Icons.camera_alt_outlined,
                color: Colors.white,
              ),
            ),
          ),
        ],
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: _galleryBody(),
    );
  }

  Widget _galleryBody() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          if (_image != null)
            Container(
              margin: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(16),
                boxShadow: const [
                  BoxShadow(
                    color: Colors.black26,
                    blurRadius: 8,
                    spreadRadius: 1,
                    offset: Offset(0, 4),
                  ),
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(16),
                child: Image.file(
                  _image!,
                  fit: BoxFit.cover,
                  height: 300,
                  width: double.infinity,
                ),
              ),
            )
          else
            const Icon(
              Icons.image,
              color: Colors.white,
              size: 200,
            ),
          if (_image != null)
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                '${_path == null ? '' : 'Image path: $_path'}\n\n${widget.text ?? ''}',
                style: const TextStyle(color: Colors.white),
              ),
            ),
        ],
      ),
    );
  }

  Future _getImage(File imageFile) async {
    setState(() {
      _image = imageFile;
      _path = imageFile.path;
    });
    final inputImage = InputImage.fromFilePath(imageFile.path);
    widget.onImage(inputImage);
  }

  // Function to update the image for testing or external purposes
  void _updateImage(File imageFile) {
    _getImage(imageFile);
  }
}
