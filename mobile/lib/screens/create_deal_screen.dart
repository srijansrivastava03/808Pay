import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import 'deal_qr_screen.dart';
import 'qr_scanner_screen.dart';

class CreateDealScreen extends StatefulWidget {
  const CreateDealScreen({Key? key}) : super(key: key);

  @override
  State<CreateDealScreen> createState() => _CreateDealScreenState();
}

class _CreateDealScreenState extends State<CreateDealScreen> {
  late TextEditingController _amountController;
  late TextEditingController _counterpartyController;
  late TextEditingController _noteController;

  @override
  void initState() {
    super.initState();
    _amountController = TextEditingController();
    _counterpartyController = TextEditingController();
    _noteController = TextEditingController();
  }

  @override
  void dispose() {
    _amountController.dispose();
    _counterpartyController.dispose();
    _noteController.dispose();
    super.dispose();
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
          'Create Deal',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: Column(
        children: [
          // Header spacing
          const SizedBox(height: 24),

          // Main content area (scrollable form)
          Expanded(
            child: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Amount Input Field
                    _buildAmountField(),

                    const SizedBox(height: 24),

                    // Counterparty Input Field
                    _buildCounterpartyField(),

                    const SizedBox(height: 24),

                    // Note Input Field
                    _buildNoteField(),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),

          // Spacer to push button to bottom
          const Spacer(),

          // Generate Deal Button
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
            child: _buildGenerateDealButton(),
          ),
        ],
      ),
    );
  }

  // ========== AMOUNT INPUT FIELD ==========
  Widget _buildAmountField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Amount Label
        Text(
          'Amount',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        // Amount Input Field
        TextField(
          controller: _amountController,
          keyboardType: TextInputType.number,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
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
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
            filled: true,
            fillColor: AppColors.grey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.red.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ========== COUNTERPARTY INPUT FIELD ==========
  Widget _buildCounterpartyField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Counterparty Label
        Text(
          'Counterparty',
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),

        const SizedBox(height: 12),

        // Counterparty Input Field with QR Button
        Row(
          children: [
            // Text input
            Expanded(
              child: TextField(
                controller: _counterpartyController,
                keyboardType: TextInputType.text,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  hintText: 'Enter counterparty name or ID',
                  hintStyle: TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 14,
                  ),
                  filled: true,
                  fillColor: AppColors.grey,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide.none,
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(
                      color: AppColors.red.withOpacity(0.3),
                      width: 1.5,
                    ),
                  ),
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 16,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 12),
            // QR Scan Button
            Container(
              decoration: BoxDecoration(
                color: AppColors.red,
                borderRadius: BorderRadius.circular(12),
              ),
              child: IconButton(
                onPressed: _scanCounterpartyQR,
                icon: const Icon(Icons.qr_code_2, color: AppColors.white),
                tooltip: 'Scan QR Code',
              ),
            ),
          ],
        ),
      ],
    );
  }

  // ========== QR SCAN FOR COUNTERPARTY ==========
  Future<void> _scanCounterpartyQR() async {
    try {
      print('📱 Launching QR scanner for counterparty...');
      // Open QR scanner
      final result = await Navigator.push<String>(
        context,
        MaterialPageRoute(
          builder: (context) => const QRScannerScreen(),
        ),
      );

      if (result != null && result.isNotEmpty) {
        // Parse QR data (could be address or format: "address|name")
        String counterparty = result;
        if (result.contains('|')) {
          // Extract address from "address|name" format
          counterparty = result.split('|')[0].trim();
        }

        setState(() {
          _counterpartyController.text = counterparty;
        });

        print('✅ Counterparty set: $counterparty');

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('✅ Counterparty set: ${counterparty.substring(0, 16)}...'),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } catch (e) {
      print('❌ QR scan error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Scan failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  // ========== NOTE INPUT FIELD ==========
  Widget _buildNoteField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Note Label with optional text
        Row(
          children: [
            Text(
              'Note',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 6),
            Text(
              '(optional)',
              style: TextStyle(
                color: AppColors.lightGrey,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
          ],
        ),

        const SizedBox(height: 12),

        // Note Input Field
        TextField(
          controller: _noteController,
          keyboardType: TextInputType.text,
          maxLines: 3,
          minLines: 1,
          style: const TextStyle(
            color: AppColors.white,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Add deal notes or terms',
            hintStyle: TextStyle(
              color: AppColors.lightGrey,
              fontSize: 14,
            ),
            filled: true,
            fillColor: AppColors.grey,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: BorderSide(
                color: AppColors.red.withOpacity(0.3),
                width: 1.5,
              ),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
        ),
      ],
    );
  }

  // ========== GENERATE DEAL BUTTON ==========
  Widget _buildGenerateDealButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _validateAndCreateDeal,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.red,
          elevation: 4,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: const Text(
          'Generate Deal',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 17,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.5,
          ),
        ),
      ),
    );
  }

  // ========== VALIDATION & DEAL CREATION ==========
  void _validateAndCreateDeal() {
    // Check if amount is empty
    if (_amountController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter amount'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // Check if counterparty is empty
    if (_counterpartyController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Enter counterparty'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    // All validation passed - navigate to Deal QR screen
    print('Deal created');
    String amount = _amountController.text;
    String receiver = _counterpartyController.text;
    String note = _noteController.text;
    String dealId = DateTime.now().millisecondsSinceEpoch.toString();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DealQRScreen(
          amount: amount,
          receiver: receiver,
          note: note,
          dealId: dealId,
        ),
      ),
    );
  }
}
