import 'package:device_preview/device_preview.dart';
import 'package:flutter/material.dart';
import 'package:path/path.dart';
import 'barcode_scanner_view.dart';
import 'package:secuqr/colors/appcolor.dart';
import 'package:flutter/services.dart';
import 'package:secuqr/gradient/gradient.dart';

Future<void> main() async {
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: AppColors.statusBarColor,
    statusBarIconBrightness: Brightness.light,
  ));
  WidgetsFlutterBinding.ensureInitialized();
  runApp(DevicePreview(enabled: true, builder: (context) => const MyApp()));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'SecuQR',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const HomePage(),
    );
  }
}

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backGroundColor,
      body: Column(
        children: <Widget>[
          Expanded(
            child: Container(), // Empty container to take up space at the top
          ),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const BarcodeScannerView()),
              );
            },
            child: Stack(
              alignment: Alignment.center,
              children: <Widget>[
                CustomPaint(
                  size: const Size(140, 140),
                  painter: GradientShadowPainter(
                    gradient: LinearGradient(
                      colors: [
                        Colors.purple.withOpacity(0.8),
                        Colors.blue.withOpacity(0.8),
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                    blurRadius: 12.0,
                  ),
                ),
                Container(
                  width: 140,
                  height: 140,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    gradient: LinearGradient(
                      colors: [Colors.purple, Colors.blue],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    ),
                  ),
                  child: Center(
                    child: Container(
                      height: 100,
                      width: 100,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.transparent,
                        border: Border.all(
                          color: Colors.white, // Border color
                          width: 1.0, // Border width
                        ),
                      ),
                      child: const Padding(
                        padding: EdgeInsets.all(6.0),
                        child: Center(
                          child: Text(
                            'Start Scanning',
                            style: TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.white),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 90), // Space between container and text
          const Text(
            'Click on Start Scanning',
            style: TextStyle(
                color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 5),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 30.0, vertical: 15),
            child: Text(
              'Scan products you want to buy at your favourite store and check authenticity from your phone & enjoy happy, friendly and safe shopping!',
              textAlign: TextAlign.center,
              style: TextStyle(color: Colors.white, fontSize: 13),
            ),
          ),
          const SizedBox(height: 80),
        ],
      ),
    );
  }
}
