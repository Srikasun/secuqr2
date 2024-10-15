import 'dart:typed_data';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_barcode_scanning/google_mlkit_barcode_scanning.dart';
import 'dart:io';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:convert'; // Import for JSON decoding
import 'package:secuqr/colors/appcolor.dart';
import 'barcode_scanner_view.dart';

class DisplayImagePage extends StatefulWidget {
  // final Uint8List imageBytes;
  final File imageFile;
  final InputImage inputImage;

  const DisplayImagePage({
    super.key,
    // required this.imageBytes,

    required this.inputImage,
    required this.imageFile,
  });

  @override
  DisplayImagePageState createState() => DisplayImagePageState();
}

class DisplayImagePageState extends State<DisplayImagePage> {
  late CameraController cameraController;
  final BarcodeScanner _barcodeScanner = BarcodeScanner();
  bool _isChecking = true;
  double _loadingProgress = 0.0; // For percentage-based loading indicator
  Uint8List? _croppedImageBytes;
  int? _qrStatus;

  @override
  void initState() {
    super.initState();

    _checkForQRCode(
        // widget.imageBytes,
        context,
        widget.inputImage,
        widget.imageFile);
  }

  @override
  void dispose() {
    _barcodeScanner.close();
    cameraController.dispose();
    super.dispose();
  }

  Future<void> _checkForQRCode(
      BuildContext context, InputImage inputImage, File imagefile) async {
    final Uint8List imageBytes = await imagefile.readAsBytes();
    setState(() {
      _isChecking = true;
      _loadingProgress = 0.0; // Initialize loading progress
    });

    // final String tempPath = (await getTemporaryDirectory()).path;
    // final File imageFile = File('$tempPath/temp_image.png');
    // await imageFile.writeAsBytes(imageBytes);
    //
    // final inputImage = InputImage.fromFilePath(imageFile.path);
    bool barcodesFound = false; // Track if barcodes are found

    try {
      final List<Barcode> barcodes =
          await _barcodeScanner.processImage(inputImage);

      if (barcodes.isNotEmpty) {
        barcodesFound = true;
        setState(() {
          _loadingProgress = 0.5; // Update loading progress to 50%
        });

        final Barcode qrCode = barcodes.first;
        final Rect boundingBox = qrCode.boundingBox;
        final img.Image? originalImage = img.decodeImage(imageBytes);

        if (originalImage != null) {
          final int cropX = boundingBox.left.toInt();
          final int cropY = boundingBox.top.toInt();
          final int cropWidth = boundingBox.width.toInt();
          final int cropHeight = boundingBox.height.toInt();

          final int adjustedX = cropX.clamp(0, originalImage.width - cropWidth);
          final int adjustedY =
              cropY.clamp(0, originalImage.height - cropHeight);

          final img.Image croppedImage = img.copyCrop(
            originalImage,
            x: adjustedX - 35,
            y: adjustedY - 35,
            width: cropWidth + 70,
            height: cropHeight + 70,
          );

          setState(() {
            _croppedImageBytes =
                Uint8List.fromList(img.encodePng(croppedImage));
            _loadingProgress = 0.75; // Update loading progress to 75%
          });

          // Simulate delay for a smooth transition to 100%
          await Future.delayed(const Duration(milliseconds: 500));

          setState(() {
            _loadingProgress = 1.0; // Update loading progress to 100%
          });

          // Send the cropped image to the API
          await sendImageToApi(_croppedImageBytes!);
        }
      } else {
        // No barcodes found, so we should skip showing progress indicators
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const BarcodeScannerView()),
        );
      }
    } catch (e) {
      setState(() {
        _isChecking = false;
        _loadingProgress = 0.0; // Reset progress on error
      });
    } finally {
      setState(() {
        _isChecking = false;
      });
    }
  }

  Future<void> sendImageToApi(Uint8List imageBytes) async {
    final url = Uri.parse('https://secuqr.xyz/chekit');
    final request = http.MultipartRequest('POST', url);

    request.files.add(
      http.MultipartFile.fromBytes(
        'scnd_img',
        imageBytes,
        filename: 'scanned_image.png',
        contentType: MediaType('image', 'png'),
      ),
    );

    try {
      final response = await request.send();
      final responseData = await http.Response.fromStream(response);

      if (responseData.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(responseData.body);
        final int status = data['status'] ?? -1;

        setState(() {
          _qrStatus = status;
        });
      }
    } catch (e) {
      setState(() {});
    }
  }

  void _scanAgain() {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (context) => const BarcodeScannerView()),
      ModalRoute.withName('/'),
    );
  }

  @override
  Widget build(BuildContext context) {
    final double screenWidth = MediaQuery.of(context).size.width;
    final double screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            SizedBox(height: screenHeight * 0.03), // 5% of screen height
            Center(
              child: Container(
                height: screenWidth * 0.6, // 30% of screen height
                width: screenWidth * 0.6, // 60% of screen width
                margin:
                    EdgeInsets.all(screenWidth * 0.04), // 4% of screen width
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(
                      screenWidth * 0.04), // 4% of screen width
                  color: Colors.grey[200],
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      spreadRadius: 5,
                    ),
                  ],
                ),
                child: _croppedImageBytes != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(
                            screenWidth * 0.04), // 4% of screen width
                        child: Image.memory(
                          _croppedImageBytes!,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Center(
                        child: CircularProgressIndicator(),
                      ),
              ),
            ),
            SizedBox(height: screenHeight * 0.03), // 3% of screen height
            Expanded(
              child: Center(
                child: Card(
                  margin: EdgeInsets.symmetric(
                    horizontal: screenWidth * 0.15, // 15% of screen width
                    vertical: screenHeight * 0.03, // 3% of screen height
                  ),
                  elevation: 12.0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                        screenWidth * 0.05), // 5% of screen width
                  ),
                  color: _isChecking
                      ? AppColors.backGroundColor
                      : Colors.white, // Conditionally set color
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                      horizontal: screenWidth * 0.06, // 6% of screen width
                      vertical: screenHeight * 0.04, // 4% of screen height
                    ),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (_isChecking)
                          Column(
                            children: [
                              TweenAnimationBuilder(
                                tween: Tween<double>(
                                    begin: 0.0, end: _loadingProgress),
                                duration: const Duration(milliseconds: 500),
                                builder: (context, double value, child) {
                                  return CircularPercentIndicator(
                                    radius: screenWidth *
                                        0.15, // 15% of screen width
                                    lineWidth: screenWidth *
                                        0.015, // 1.5% of screen width
                                    percent: value,
                                    center: Text(
                                      "${(value * 100).toInt()}%",
                                      style: TextStyle(
                                          fontSize: screenWidth *
                                              0.05, // 5% of screen width
                                          color: Colors.white),
                                    ),
                                    progressColor: Colors.white,
                                    backgroundColor: AppColors.backGroundColor,
                                  );
                                },
                              ),
                              SizedBox(
                                  height: screenHeight *
                                      0.02), // 2% of screen height
                              Text(
                                "Analyzing QR code...",
                                style: TextStyle(
                                  fontSize: screenWidth *
                                      0.045, // 4.5% of screen width
                                  color: Colors.white,
                                ),
                              ),
                            ],
                          )
                        else
                          _buildResultContent(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildResultContent() {
    Color resultColor;
    IconData resultIcon;
    String resultTitle;
    String resultMessage1;
    String resultMessage2;

    switch (_qrStatus) {
      case 1: // Legitimate QR Code
        resultColor = Colors.green;
        resultIcon = Icons.check_circle;
        resultTitle = "Success!";
        resultMessage1 = "Legitimate Secured QR Code";
        resultMessage2 =
            "Shop with confidence knowing this product is genuine.";
        break;
      case 0: // Counterfeit QR Code
        resultColor = Colors.red;
        resultIcon = Icons.cancel;
        resultTitle = "Sorry :(";
        resultMessage1 = "Found to be Counterfeit";
        resultMessage2 = "This product may be counterfeit. Do not purchase";
        break;
      default: // Error or Unknown
        resultColor = Colors.orange;
        resultIcon = Icons.error;
        resultTitle = "Error!";
        resultMessage1 = "Detection Error";
        resultMessage2 = "Please try again";
        break;
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(resultIcon, color: resultColor, size: 60),
        const SizedBox(height: 10),
        Text(
          resultTitle,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 25,
            fontWeight: FontWeight.bold,
            color: resultColor,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          resultMessage1,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          resultMessage2,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 15),
        ElevatedButton(
          onPressed: _scanAgain,
          style: ElevatedButton.styleFrom(
            backgroundColor: resultColor,
          ),
          child: const Text(
            'Scan Again',
            style: TextStyle(color: Colors.white),
          ),
        ),
      ],
    );
  }
}
