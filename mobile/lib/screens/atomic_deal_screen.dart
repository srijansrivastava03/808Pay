import 'package:flutter/material.dart';
import 'package:pay_808/services/tax_service.dart';
import 'atomic_signing_screen.dart';

class AtomicDealScreen extends StatefulWidget {
  const AtomicDealScreen({Key? key}) : super(key: key);

  @override
  State<AtomicDealScreen> createState() => _AtomicDealScreenState();
}

class _AtomicDealScreenState extends State<AtomicDealScreen> {
  // Your side (buyer or seller)
  String yourRole = 'buyer';
  String yourAddress = '';

  // Deal terms
  String amount = '';
  String selectedCategory = 'electronics';

  // Other party details
  String recipientAddress = '';
  String productDescription = '';

  bool isCreating = false;

  @override
  void initState() {
    super.initState();
    yourAddress = '0x7f2e8c9a...'; // Demo address
  }

  void _createAtomicDeal() async {
    // Validate inputs
    if (amount.isEmpty || amount == '0') {
      _showError('Amount is required');
      return;
    }

    if (recipientAddress.isEmpty) {
      _showError('Recipient address is required');
      return;
    }

    if (yourRole == 'seller' && productDescription.isEmpty) {
      _showError('Product description is required');
      return;
    }

    setState(() => isCreating = true);

    try {
      final dealAmount = int.parse(amount);

      final atomicDeal = {
        'buyerAddress':
            yourRole == 'buyer' ? yourAddress : recipientAddress,
        'sellerAddress':
            yourRole == 'seller' ? yourAddress : recipientAddress,
        'amount': dealAmount,
        'category': selectedCategory,
        'requiredSignatureCount': 2,
        'requiredSignatures': [],
        'participants': {
          'buyer': yourRole == 'buyer' ? yourAddress : recipientAddress,
          'seller': yourRole == 'seller' ? yourAddress : recipientAddress,
        },
        'signingStatus': 'PENDING_SIGNATURES',
        'timestamp': DateTime.now().millisecondsSinceEpoch,
        'productDescription': productDescription,
      };

      if (mounted) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => AtomicSigningScreen(
              atomicDeal: atomicDeal,
              userRole: yourRole,
              userAddress: yourAddress,
            ),
          ),
        );
      }
    } catch (e) {
      _showError('Failed to create deal: $e');
    } finally {
      if (mounted) {
        setState(() => isCreating = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final gstRate = TaxCalculationService.getGstRate(selectedCategory);

    return Scaffold(
      appBar: AppBar(
        title: const Text('⚛️ Atomic Settlement'),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.shade50,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.blue.shade200),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.lock, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Two-Party Payment',
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Colors.blue.shade900,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Both buyer and seller must sign for the payment to go through.',
                    style: TextStyle(fontSize: 12, color: Colors.blue.shade700),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Your Role Selection
            const Text(
              'Your Role',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(label: Text('🛍️ Buyer'), value: 'buyer'),
                ButtonSegment(label: Text('📦 Seller'), value: 'seller'),
              ],
              selected: {yourRole},
              onSelectionChanged: (value) {
                setState(() => yourRole = value.first);
              },
            ),
            const SizedBox(height: 20),

            // Your Address Display
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey.shade100,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: const [
                  Text(
                    'Your Address',
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  SizedBox(height: 4),
                  Text(
                    '0x7f2e8c9a...',
                    style: TextStyle(fontSize: 11, fontFamily: 'monospace'),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Deal Terms
            const Text(
              'Deal Terms',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Amount Input
            TextField(
              keyboardType: TextInputType.number,
              onChanged: (value) => setState(() => amount = value),
              decoration: InputDecoration(
                labelText: 'Amount (₹)',
                hintText: '50000',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.currency_rupee),
              ),
            ),
            const SizedBox(height: 12),

            // Category Selection
            const Text(
              'Category',
              style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(label: Text('Food'), value: 'food'),
                ButtonSegment(label: Text('Medicine'), value: 'medicine'),
                ButtonSegment(label: Text('Electronics'), value: 'electronics'),
              ],
              selected: {selectedCategory},
              onSelectionChanged: (value) {
                setState(() => selectedCategory = value.first);
              },
            ),
            const SizedBox(height: 8),
            SegmentedButton<String>(
              segments: const [
                ButtonSegment(label: Text('Services'), value: 'services'),
                ButtonSegment(label: Text('Luxury'), value: 'luxury'),
              ],
              selected: selectedCategory == 'services' ||
                      selectedCategory == 'luxury'
                  ? {selectedCategory}
                  : <String>{},
              onSelectionChanged: (value) {
                if (value.isNotEmpty) {
                  setState(() => selectedCategory = value.first);
                }
              },
            ),
            const SizedBox(height: 12),

            // GST Rate Display
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.orange.shade50,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: Colors.orange.shade200),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('GST Rate',
                      style: TextStyle(fontWeight: FontWeight.w600)),
                  Text(
                    '$gstRate%',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.orange.shade700,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Other Party Details
            Text(
              yourRole == 'buyer' ? 'Seller Details' : 'Buyer Details',
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Recipient Address
            TextField(
              onChanged: (value) => setState(() => recipientAddress = value),
              decoration: InputDecoration(
                labelText: 'Their Address',
                hintText: '0xabcd1234...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                prefixIcon: const Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 12),

            // Product Description (for seller)
            if (yourRole == 'seller')
              TextField(
                onChanged: (value) =>
                    setState(() => productDescription = value),
                maxLines: 3,
                decoration: InputDecoration(
                  labelText: 'What are you selling?',
                  hintText: 'e.g., iPhone 15 Pro, 256GB, Space Black',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  prefixIcon: const Icon(Icons.description),
                ),
              ),
            const SizedBox(height: 24),

            // Tax Breakdown Preview
            if (amount.isNotEmpty && amount != '0')
              _buildTaxBreakdown(int.parse(amount), selectedCategory),
            const SizedBox(height: 24),

            // Warning
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.yellow.shade50,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.yellow.shade300),
              ),
              child: Row(
                children: [
                  Icon(Icons.warning_amber, color: Colors.orange, size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Both parties must sign for payment to go through.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => Navigator.pop(context),
                    child: const Text('Cancel'),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: ElevatedButton(
                    onPressed: isCreating ? null : _createAtomicDeal,
                    child: isCreating
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : const Text('Create Deal'),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTaxBreakdown(int amount, String category) {
    final breakdown = TaxCalculationService.calculateBreakdown(
      amount: amount.toDouble(),
      category: category,
    );
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Tax Breakdown',
              style:
                  TextStyle(fontWeight: FontWeight.w600, fontSize: 12)),
          const SizedBox(height: 8),
          _taxBreakdownRow('Merchant',
              '₹${breakdown['merchant']!.toStringAsFixed(0)}', Colors.green),
          _taxBreakdownRow(
              'Tax (GST)',
              '₹${breakdown['tax']!.toStringAsFixed(0)}',
              Colors.red),
          _taxBreakdownRow('Loyalty',
              '₹${breakdown['loyalty']!.toStringAsFixed(0)}', Colors.purple),
        ],
      ),
    );
  }

  Widget _taxBreakdownRow(String label, String value, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: const TextStyle(fontSize: 11)),
          Text(value,
              style: TextStyle(
                  fontWeight: FontWeight.w600, color: color, fontSize: 11)),
        ],
      ),
    );
  }
}
