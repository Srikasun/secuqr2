import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_mlkit_commons/google_mlkit_commons.dart';
import 'square_clipper.dart'; // Import the custom clipper
import 'border_painter.dart'; // Import the custom border painter

class CameraView extends StatefulWidget {
  const CameraView({
    super.key,
    required this.customPaint,
    required this.onImage,
    this.onCameraFeedReady,
    this.initialCameraLensDirection = CameraLensDirection.back,
    required this.onBarcodeCenterUpdated,
  });

  final CustomPaint? customPaint;
  final Function(InputImage inputImage) onImage;
  final VoidCallback? onCameraFeedReady;
  final CameraLensDirection initialCameraLensDirection;
  final void Function(Offset qrCenter) onBarcodeCenterUpdated;

  @override
  State<CameraView> createState() => _CameraViewState();
}

class _CameraViewState extends State<CameraView> {
  static List<CameraDescription> _cameras = [];
  CameraController? _controller;
  int _cameraIndex = -1;

  @override
  void initState() {
    super.initState();
    _initialize();
  }

  void _initialize() async {
    if (_cameras.isEmpty) {
      _cameras = await availableCameras();
    }
    for (var i = 0; i < _cameras.length; i++) {
      if (_cameras[i].lensDirection == widget.initialCameraLensDirection) {
        _cameraIndex = i;
        break;
      }
    }
    if (_cameraIndex != -1) {
      _startLiveFeed();
    }
  }

  @override
  void dispose() {
    _stopLiveFeed();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final squareSize = screenWidth * 0.7; // Proportional to screen width
    final borderRadius = screenWidth * 0.05; // Proportional to screen width
    final borderWidth = screenWidth * 0.02; // Proportional to screen width

    return Scaffold(
      backgroundColor: Colors.transparent,
      body: Stack(
        fit: StackFit.expand,
        children: [
          // Camera preview
          Align(
            alignment: Alignment.center,
            child: SizedBox(
              width: screenWidth,
              height: screenHeight,
              child: _controller == null || !_controller!.value.isInitialized
                  ? Container()
                  : CameraPreview(
                      _controller!,
                      child: widget.customPaint,
                    ),
            ),
          ),
          // Transparent overlay with a rounded clear square
          ClipPath(
            clipper: RoundedSquareClipper(
              squareSize: squareSize,
              borderRadius: borderRadius,
            ),
            child: Container(
              color: Colors.black.withOpacity(0.7),
            ),
          ),
          // Blue border on the corners of the clear square
          CustomPaint(
            painter: CornerBorderPainter(
              squareSize: squareSize,
              borderWidth: borderWidth,
              borderColor: Colors.purple,
              cornerRadius: borderRadius,
            ),
            size: Size(screenWidth, screenHeight),
          ),
        ],
      ),
    );
  }

  Future _startLiveFeed() async {
    final camera = _cameras[_cameraIndex];
    _controller = CameraController(
      camera,
      ResolutionPreset.high,
      enableAudio: false,
      imageFormatGroup: Platform.isAndroid
          ? ImageFormatGroup.nv21
          : ImageFormatGroup.bgra8888,
    );
    _controller?.initialize().then((_) {
      if (!mounted) return;
      _controller?.startImageStream(_processCameraImage).then((_) {
        if (widget.onCameraFeedReady != null) {
          widget.onCameraFeedReady!();
        }
      });
      setState(() {});
    });
  }

  Future _stopLiveFeed() async {
    await _controller?.stopImageStream();
    await _controller?.dispose();
    _controller = null;
  }

  void _processCameraImage(CameraImage image) {
    final inputImage = _inputImageFromCameraImage(image);
    if (inputImage == null) return;
    widget.onImage(inputImage);
  }

  final _orientations = {
    DeviceOrientation.portraitUp: 0,
    DeviceOrientation.landscapeLeft: 90,
    DeviceOrientation.portraitDown: 180,
    DeviceOrientation.landscapeRight: 270,
  };

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    if (_controller == null) return null;

    final camera = _cameras[_cameraIndex];
    final sensorOrientation = camera.sensorOrientation;
    InputImageRotation? rotation;
    if (Platform.isIOS) {
      rotation = InputImageRotationValue.fromRawValue(sensorOrientation);
    } else if (Platform.isAndroid) {
      var rotationCompensation =
          _orientations[_controller!.value.deviceOrientation];
      if (rotationCompensation == null) return null;
      if (camera.lensDirection == CameraLensDirection.front) {
        rotationCompensation = (sensorOrientation + rotationCompensation) % 360;
      } else {
        rotationCompensation =
            (sensorOrientation - rotationCompensation + 360) % 360;
      }
      rotation = InputImageRotationValue.fromRawValue(rotationCompensation);
    }
    if (rotation == null) return null;

    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null ||
        (Platform.isAndroid && format != InputImageFormat.nv21) ||
        (Platform.isIOS && format != InputImageFormat.bgra8888)) return null;

    if (image.planes.length != 1) return null;
    final plane = image.planes.first;

    return InputImage.fromBytes(
      bytes: plane.bytes,
      metadata: InputImageMetadata(
        size: Size(image.width.toDouble(), image.height.toDouble()),
        rotation: rotation,
        format: format,
        bytesPerRow: plane.bytesPerRow,
      ),
    );
  }
}
