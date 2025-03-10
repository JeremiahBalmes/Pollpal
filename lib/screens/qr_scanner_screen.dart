import 'package:flutter/material.dart';
import 'package:qr_code_scanner/qr_code_scanner.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({super.key});

  @override
  _QRScannerScreenState createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  // Using GlobalKey for QRViewController
  final GlobalKey qrKey = GlobalKey(debugLabel: 'QRView');


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('QR Scanner'),
      ),
      body: QRView(
        key: qrKey,  // Linking QRView with the key
        onQRViewCreated: _onQRViewCreated,  // Using correct controller
      ),
    );
  }

  void _onQRViewCreated(QRViewController controller) {
    // This controller is of type QRViewController
    controller.scannedDataStream.listen((scanData) {
    if (scanData.code != null) {
      String surveyId = scanData.code!; // Ensure it's not null
      print('Scanned Survey ID: $surveyId');  // Display or handle the scanned data

      // Check if scanData.code contains a valid survey link
      if (scanData.code != null && scanData.code!.contains("survey_id=")) {
        String surveyId = scanData.code!.split("survey_id=").last;

        Navigator.pushNamed(
          context,
          '/survey_details',
          arguments: surveyId, // Pass survey ID to the next screen
        );
      }
    }});
  }

  @override
  void dispose() {
    // Dispose of the QR controller correctly
    qrKey.currentState?.dispose();
    super.dispose();
  }
}
