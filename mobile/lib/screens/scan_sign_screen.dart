import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../theme/app_theme.dart';
import 'deal_verification_screen.dart';

class ScanSignScreen extends StatefulWidget {
  const ScanSignScreen({Key? key}) : super(key: key);

  @override
  State<ScanSignScreen> createState() => _ScanSignScreenState();
}

class _ScanSignScreenState extends State<ScanSignScreen> {
  late MobileScannerController _cameraController;
  bool _isProcessing = false;
  String? _lastScannedCode;

  @override
  void initState() {
    super.initState();
    _cameraController = MobileScannerController(
      autoStart: true,
      torchEnabled: false,
    );
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
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

    // Parse QR data
    _parseAndVerifyQR(scannedCode);
  }

  void _parseAndVerifyQR(String qrData) {
    try {
      // Expected format: deal_id:12345|amount:500|receiver:Merchant
      final Map<String, String> data = {};
      final parts = qrData.split('|');

      for (final part in parts) {
        if (part.contains(':')) {
          final keyValue = part.split(':');
          if (keyValue.length == 2) {
            data[keyValue[0].trim()] = keyValue[1].trim();
          }
        }
      }

      // Validate required fields
      if (!data.containsKey('deal_id') ||
          !data.containsKey('amount') ||
          !data.containsKey('receiver')) {
        _showError('Invalid QR Code', 'Missing required deal information');
        setState(() => _isProcessing = false);
        return;
      }

      final dealId = data['deal_id']!;
      final amount = data['amount']!;
      final receiver = data['receiver']!;
      final note = data['note'] ?? '';

      // Navigate to verification screen
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => DealVerificationScreen(
            dealId: dealId,
            amount: amount,
            receiver: receiver,
            note: note,
            qrData: qrData,
          ),
        ),
      ).then((_) {
        // Reset state when returning from verification
        setState(() {
          _isProcessing = false;
          _lastScannedCode = null;
        });
      });
    } catch (e) {
      _showError('Parse Error', 'Could not parse QR code: $e');
      setState(() => _isProcessing = false);
    }
  }

  void _showError(String title, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            Text(message),
          ],
        ),
        backgroundColor: AppColors.error,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan Deal',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
        actions: [
          IconButton(
            icon: ValueListenableBuilder(
              valueListenable: _cameraController.torchState,
              builder: (context, state, child) {
                return Icon(
                  state == TorchState.off ? Icons.flash_off : Icons.flash_on,
                  color: state == TorchState.off ? AppColors.lightGrey : AppColors.warning,
                );
              },
            ),
            onPressed: () => _cameraController.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera feed
          MobileScanner(
            controller: _cameraController,
            onDetect: _handleBarcode,
            errorBuilder: (context, error, child) {
              return _buildCameraErrorWidget(error);
            },
          ),

          // Overlay UI
          Column(
            children: [
              // Top info
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Position QR Code',
                      style: TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Align the QR code within the frame to scan',
                      style: TextStyle(
                        color: AppColors.lightGrey,
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Scanner frame overlay (center)
              Center(
                child: Container(
                  width: 260,
                  height: 260,
                  decoration: BoxDecoration(
                    border: Border.all(
                      color: AppColors.warning,
                      width: 2,
                    ),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.qr_code_2,
                        size: 100,
                        color: AppColors.warning.withOpacity(0.3),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Scan QR Code',
                        style: TextStyle(
                          color: AppColors.warning,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const Spacer(),

              // Bottom info & buttons
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Processing indicator
                    if (_isProcessing)
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation(AppColors.success),
                            ),
                          ),
                          const SizedBox(width: 12),
                          const Text(
                            'Processing QR...',
                            style: TextStyle(
                              color: AppColors.success,
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      )
                    else
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Manual input button
                          Container(
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.grey.withOpacity(0.3),
                              border: Border.all(
                                color: AppColors.grey,
                                width: 1,
                              ),
                            ),
                            child: IconButton(
                              icon: const Icon(
                                Icons.edit,
                                color: AppColors.white,
                              ),
                              onPressed: _showManualInputDialog,
                            ),
                          ),
                        ],
                      ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildCameraErrorWidget(MobileScannerException error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.error_outline,
            size: 64,
            color: AppColors.error,
          ),
          const SizedBox(height: 16),
          Text(
            'Camera Error',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Text(
              error.errorDetails?.message ?? 'Could not access camera',
              style: TextStyle(
                color: AppColors.lightGrey,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {
              _cameraController.start();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.warning,
              padding: const EdgeInsets.symmetric(
                horizontal: 32,
                vertical: 12,
              ),
            ),
            child: const Text(
              'Retry',
              style: TextStyle(color: AppColors.black),
            ),
          ),
        ],
      ),
    );
  }

  void _showManualInputDialog() {
    final textController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grey,
        title: const Text(
          'Enter QR Data',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: TextField(
          controller: textController,
          style: const TextStyle(color: AppColors.white),
          decoration: InputDecoration(
            hintText: 'Paste QR data here',
            hintStyle: const TextStyle(color: AppColors.lightGrey),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(color: AppColors.grey),
            ),
          ),
          maxLines: 3,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.lightGrey),
            ),
          ),
          TextButton(
            onPressed: () {
              if (textController.text.isNotEmpty) {
                Navigator.pop(context);
                _parseAndVerifyQR(textController.text);
              }
            },
            child: const Text(
              'Submit',
              style: TextStyle(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }
}
