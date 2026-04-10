import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';

class DealQRScreen extends StatelessWidget {
  final String amount;
  final String receiver;
  final String note;
  final String dealId;

  const DealQRScreen({
    Key? key,
    required this.amount,
    required this.receiver,
    required this.note,
    required this.dealId,
  }) : super(key: key);

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
          'Deal QR',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 20),

            // Deal Summary Card
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // Amount (big and bold) - Visually dominant
                    Text(
                      '₹ $amount',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 56,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),

                    const SizedBox(height: 16),

                    // Receiver name
                    Text(
                      'To: $receiver',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    // Note (if not empty)
                    if (note.isNotEmpty) ...[
                      const SizedBox(height: 16),
                      Text(
                        'Note: $note',
                        style: TextStyle(
                          color: AppColors.lightGrey,
                          fontSize: 14,
                          fontWeight: FontWeight.w400,
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 28),

            // QR Code
            QrImageView(
              data: _generateQRData(),
              version: QrVersions.auto,
              size: 260,
              backgroundColor: AppColors.white,
              errorCorrectionLevel: QrErrorCorrectLevel.H,
            ),

            const SizedBox(height: 28),

            // Instruction text
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Text(
                'Ask the other party to scan this code',
                style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
                textAlign: TextAlign.center,
              ),
            ),

            const SizedBox(height: 28),

            // Share QR Button
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _shareQR,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.red,
                    elevation: 4,
                    padding: const EdgeInsets.symmetric(vertical: 18),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: const Text(
                    'Share QR',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0.5,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Generate QR data string
  String _generateQRData() {
    return 'deal_id:$dealId|amount:$amount|receiver:$receiver';
  }

  // Share QR code
  void _shareQR() {
    final qrData = _generateQRData();
    final shareMessage = '''
808Pay Deal QR

Amount: ₹$amount
Receiver: $receiver
Deal ID: $dealId

QR Data: $qrData

Scan this QR code to complete the atomic settlement.
    ''';
    
    Share.share(
      shareMessage,
      subject: '808Pay Deal - ₹$amount to $receiver',
    );
  }
}
