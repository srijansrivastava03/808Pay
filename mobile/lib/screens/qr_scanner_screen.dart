import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_theme.dart';

class QRScannerScreen extends StatefulWidget {
  const QRScannerScreen({Key? key}) : super(key: key);

  @override
  State<QRScannerScreen> createState() => _QRScannerScreenState();
}

class _QRScannerScreenState extends State<QRScannerScreen> {
  late MobileScannerController _cameraController;
  String? _lastScannedCode;
  bool _isProcessing = false;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      autoStart: true,
      torchEnabled: false,
    );
  }

  void _handleBarcode(BarcodeCapture barcodes) {
    if (_isProcessing) return;

    final List<Barcode> barcodesDetected = barcodes.barcodes;
    if (barcodesDetected.isEmpty) return;

    final String scannedCode = barcodesDetected.first.rawValue ?? '';
    if (scannedCode.isEmpty) return;

    // Prevent duplicate scans
    if (_lastScannedCode == scannedCode) return;
    _lastScannedCode = scannedCode;

    setState(() => _isProcessing = true);

    print('✅ QR Scanned: $scannedCode');
    
    // Return the scanned code
    Navigator.pop(context, scannedCode);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Scan QR Code'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pop(context),
        ),
        backgroundColor: AppColors.black,
      ),
      backgroundColor: AppColors.black,
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Camera view
                  MobileScanner(
                    controller: _cameraController,
                    onDetect: _handleBarcode,
                    errorBuilder: (context, error, child) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(
                              Icons.error_outline,
                              size: 64,
                              color: AppColors.red,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Camera Error',
                              style: Theme.of(context)
                                  .textTheme
                                  .titleLarge
                                  ?.copyWith(color: AppColors.white),
                            ),
                            const SizedBox(height: 8),
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 32),
                              child: Text(
                                error.toString(),
                                style: Theme.of(context)
                                    .textTheme
                                    .bodySmall
                                    ?.copyWith(color: AppColors.lightGrey),
                                textAlign: TextAlign.center,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                  // QR frame overlay
                  Container(
                    width: 300,
                    height: 300,
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.red,
                        width: 3,
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  // Corner indicators
                  Positioned(
                    top: MediaQuery.of(context).size.height / 2 - 150,
                    left: MediaQuery.of(context).size.width / 2 - 150,
                    child: Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        border: Border(
                          top: BorderSide(color: AppColors.red, width: 3),
                          left: BorderSide(color: AppColors.red, width: 3),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            // Instructions
            Container(
              padding: const EdgeInsets.all(24),
              color: AppColors.black,
              child: Column(
                children: [
                  Text(
                    'Position QR code in frame',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppColors.white,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'QR will be scanned automatically',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.lightGrey,
                        ),
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () => Navigator.pop(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.red,
                        padding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                      child: const Text('Cancel'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }
}
