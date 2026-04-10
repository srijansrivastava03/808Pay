import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:convert';
import 'package:share_plus/share_plus.dart';
import '../theme/app_theme.dart';

class ReceiveScreen extends StatefulWidget {
  const ReceiveScreen({Key? key}) : super(key: key);

  @override
  State<ReceiveScreen> createState() => _ReceiveScreenState();
}

class _ReceiveScreenState extends State<ReceiveScreen> {
  late TextEditingController _amountController;
  String? _qrData;
  
  // Mock data - in real app, this would come from wallet context
  final String receiverId = '8XK9-3F2A';
  final String walletAddress = 'AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAY5HVY';
  final String appIdentifier = '808pay';

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    // Generate initial QR without amount
    _generateQRData();
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  // Generate QR data structure as JSON
  void _generateQRData() {
    final qrPayload = {
      'app': appIdentifier,
      'receiver_id': receiverId,
      'wallet_address': walletAddress,
      'timestamp': DateTime.now().toIso8601String(),
      if (_amountController.text.isNotEmpty)
        'amount': double.tryParse(_amountController.text) ?? 0,
    };

    setState(() {
      _qrData = jsonEncode(qrPayload);
    });

    print('QR Data Generated: $_qrData');
  }

  // Copy payment ID to clipboard
  void _copyPaymentID() {
    Clipboard.setData(const ClipboardData(text: 'suyash@808pay')).then((_) {
      _showSnackBar('✓ Payment ID copied to clipboard');
    });
  }

  // Share payment ID via system share dialog
  void _sharePaymentID() {
    Share.share(
      'Pay me at suyash@808pay',
      subject: '808Pay Payment Request',
    ).then((_) {
      print('Share Payment ID triggered');
    });
  }

  // Share QR code
  void _shareQR() {
    final shareText = _qrData != null
        ? 'Scan to pay me via 808Pay:\n$_qrData'
        : 'Scan my payment QR on 808Pay';

    Share.share(
      shareText,
      subject: 'Share My 808Pay QR',
    ).then((_) {
      print('Share QR triggered');
    });
  }

  // Show snackbar feedback
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        backgroundColor: AppColors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
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
          'Receive',
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
          children: [
            // Header spacing
            SizedBox(height: 24),

            // Main content area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // User Identity Card
                  _buildIdentityCard(),

                  const SizedBox(height: 40),

                  // QR Code Section
                  _buildQRSection(),

                  const SizedBox(height: 40),

                  // Payment ID Section
                  _buildPaymentIDSection(),

                  const SizedBox(height: 40),

                  // Amount Input Section
                  _buildAmountInputSection(),

                  const SizedBox(height: 40),

                  // Bottom Action Buttons
                  _buildBottomActionButtons(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== IDENTITY CARD SECTION ==========
  Widget _buildIdentityCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.red.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // User Name
          Text(
            'John Doe',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Divider with red accent
          Container(
            height: 1,
            color: AppColors.red.withOpacity(0.2),
          ),

          const SizedBox(height: 16),

          // Unique ID Label
          Text(
            'Unique ID',
            style: TextStyle(
              color: AppColors.lightGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // Unique ID Value
          Text(
            '8XK9-3F2A',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  // ========== QR CODE SECTION ==========
  Widget _buildQRSection() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        children: [
          // QR Code Display
          Container(
            width: 240,
            height: 240,
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(12),
              border: _qrData != null
                  ? Border.all(color: AppColors.red, width: 2)
                  : null,
            ),
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    _qrData != null ? Icons.qr_code_2 : Icons.qr_code_2,
                    size: 120,
                    color: _qrData != null ? AppColors.red : AppColors.grey,
                  ),
                  if (_qrData != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 16),
                      child: Text(
                        '✓ Ready',
                        style: TextStyle(
                          color: AppColors.red,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 24),

          // "Scan to pay" text
          Text(
            'Scan to pay',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),

          if (_qrData != null)
            Padding(
              padding: const EdgeInsets.only(top: 12),
              child: Text(
                'QR data generated',
                style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 12,
                ),
              ),
            ),
        ],
      ),
    );
  }

  // ========== PAYMENT ID SECTION ==========
  Widget _buildPaymentIDSection() {
    return Column(
      children: [
        // Payment ID Display
        Text(
          'suyash@808pay',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
            letterSpacing: 0.5,
          ),
        ),

        const SizedBox(height: 24),

        // Copy and Share Buttons
        Row(
          children: [
            // Copy Button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.red.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _copyPaymentID,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.content_copy,
                            color: AppColors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Copy ID',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(width: 12),

            // Share Button
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.red.withOpacity(0.15),
                    width: 1,
                  ),
                ),
                child: Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: _sharePaymentID,
                    borderRadius: BorderRadius.circular(12),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.share,
                            color: AppColors.red,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          const Text(
                            'Share ID',
                            style: TextStyle(
                              color: AppColors.white,
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========== AMOUNT INPUT SECTION ==========
  Widget _buildAmountInputSection() {
    return Column(
      children: [
        // Amount Input Field
        TextField(
          controller: _amountController,
          onChanged: (value) {
            // Update QR whenever amount changes
            _generateQRData();
          },
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
          ),
          decoration: InputDecoration(
            hintText: 'Enter amount (₹)',
            hintStyle: TextStyle(
              color: AppColors.lightGrey,
              fontSize: 14,
            ),
            prefixText: '₹ ',
            prefixStyle: const TextStyle(
              color: AppColors.red,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: AppColors.grey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 14,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Generate QR Button
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _generateQRData,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: const Text(
              'Generate QR',
              style: TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ========== BOTTOM ACTION BUTTONS ==========
  Widget _buildBottomActionButtons() {
    return Column(
      children: [
        // Share QR Button (Primary - Red)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _shareQR,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.red,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.share, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Share QR',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(height: 12),

        // Download QR Button (Secondary - Grey)
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () => _showSnackBar('Download feature coming soon'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.grey,
              foregroundColor: AppColors.white,
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
                side: BorderSide(
                  color: AppColors.red.withOpacity(0.15),
                  width: 1,
                ),
              ),
              elevation: 0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.download, size: 18),
                const SizedBox(width: 8),
                const Text(
                  'Download QR',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
