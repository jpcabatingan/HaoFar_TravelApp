import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart'; // Ensure this import is present

class QrScannerScreen extends StatefulWidget {
  const QrScannerScreen({super.key});

  @override
  State<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends State<QrScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    controller.barcodes.listen(_handleBarcode);
  }

  void _handleBarcode(BarcodeCapture capture) {
    if (_isProcessing) return;

    final List<Barcode> barcodes = capture.barcodes;
    if (barcodes.isNotEmpty) {
      final Barcode firstBarcode = barcodes.first;
      final String? scannedValue = firstBarcode.rawValue;

      if (scannedValue != null && scannedValue.isNotEmpty) {
        setState(() {
          _isProcessing = true;
        });
        controller.stop();
        Navigator.pop(context, scannedValue);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan Travel Plan QR Code'),
        backgroundColor: Colors.black.withOpacity(0.7),
        elevation: 0,
      ),
      extendBodyBehindAppBar: true,
      body: Stack(
        children: [
          MobileScanner(controller: controller),
          Center(
            child: Container(
              width: MediaQuery.of(context).size.width * 0.7,
              height: MediaQuery.of(context).size.width * 0.7,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.greenAccent, width: 3),
                borderRadius: BorderRadius.circular(12),
              ),
            ),
          ),
          // Torch button and related ValueListenableBuilder have been removed for this test.
        ],
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}
