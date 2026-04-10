import 'package:flutter/material.dart';
import 'package:pay_808/services/tax_service.dart';

class AtomicSettlementConfirmationScreen extends StatefulWidget {
  final Map<String, dynamic> atomicDeal;
  final String userRole;

  const AtomicSettlementConfirmationScreen({
    required this.atomicDeal,
    required this.userRole,
    Key? key,
  }) : super(key: key);

  @override
  State<AtomicSettlementConfirmationScreen> createState() =>
      _AtomicSettlementConfirmationScreenState();
}

class _AtomicSettlementConfirmationScreenState
    extends State<AtomicSettlementConfirmationScreen> {
  bool isSubmitting = false;

  void _submitSettlement() async {
    setState(() => isSubmitting = true);

    try {
      // TODO: Submit to backend /api/transactions/atomic-settle
      await Future.delayed(const Duration(seconds: 2)); // Simulate submission

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
                '✅ Settlement submitted! Waiting for blockchain confirmation...'),
            backgroundColor: Colors.green,
          ),
        );

        // Navigate to success screen
        await Future.delayed(const Duration(milliseconds: 500));
        if (mounted) {
          Navigator.of(context).popUntil((route) => route.isFirst);
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Submission failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSubmitting = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyerAddress = widget.atomicDeal['participants']['buyer'];
    final sellerAddress = widget.atomicDeal['participants']['seller'];
    final amount = widget.atomicDeal['amount'];
    final category = widget.atomicDeal['category'];
    final splits = TaxCalculationService.calculateBreakdown(
      amount: amount.toDouble(),
      category: category,
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Confirm Settlement'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Success Badge
            Center(
              child: Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.check_circle,
                  size: 64,
                  color: Colors.green.shade600,
                ),
              ),
            ),
            const SizedBox(height: 16),
            const Center(
              child: Text(
                '✅ Both Parties Signed!',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
              ),
            ),
            const SizedBox(height: 24),

            // Deal Summary
            const Text(
              'Deal Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSummaryRow(
                      'Buyer', buyerAddress.substring(0, 20) + '...'),
                  Divider(color: Colors.grey.shade300),
                  _buildSummaryRow(
                      'Seller', sellerAddress.substring(0, 20) + '...'),
                  Divider(color: Colors.grey.shade300),
                  _buildSummaryRow('Amount', '₹$amount'),
                  Divider(color: Colors.grey.shade300),
                  _buildSummaryRow('Category', category.toUpperCase()),
                  Divider(color: Colors.grey.shade300),
                  _buildSummaryRow(
                      'GST Rate',
                      '${TaxCalculationService.getGstRate(category)}%'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Payment Breakdown
            const Text(
              'Payment Breakdown',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  _buildBreakdownRow(
                    'Merchant Amount',
                    '₹${splits['merchant']!.toStringAsFixed(0)}',
                    Colors.green,
                  ),
                  Divider(color: Colors.grey.shade300),
                  _buildBreakdownRow(
                    'Tax (GST)',
                    '₹${splits['tax']!.toStringAsFixed(0)}',
                    Colors.red,
                  ),
                  Divider(color: Colors.grey.shade300),
                  _buildBreakdownRow(
                    'Loyalty',
                    '₹${splits['loyalty']!.toStringAsFixed(0)}',
                    Colors.purple,
                  ),
                  Divider(color: Colors.grey.shade300),
                  _buildBreakdownRow(
                    'Total',
                    '₹$amount',
                    Colors.blue,
                    bold: true,
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Signatures
            const Text(
              'Digital Signatures',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

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
                      Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Buyer Signature: ✅',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '0x${buyerAddress.substring(0, 20)}...',
                    style: const TextStyle(
                        fontSize: 11, fontFamily: 'monospace'),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    children: [
                      Icon(Icons.check_circle,
                          color: Colors.green, size: 20),
                      const SizedBox(width: 8),
                      const Text(
                        'Seller Signature: ✅',
                        style: TextStyle(fontWeight: FontWeight.w600),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '0x${sellerAddress.substring(0, 20)}...',
                    style: const TextStyle(
                        fontSize: 11, fontFamily: 'monospace'),
                  ),
                ],
              ),
            ),
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
                      'Once submitted, this transaction cannot be reversed.',
                      style: TextStyle(
                          fontSize: 12, color: Colors.orange.shade900),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Submit Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: isSubmitting ? null : _submitSettlement,
                icon: isSubmitting
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor:
                              AlwaysStoppedAnimation(Colors.white),
                        ),
                      )
                    : const Icon(Icons.send),
                label: Text(
                    isSubmitting ? 'Submitting...' : 'Submit to Settlement'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.green,
                ),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(
                  color: Colors.grey.shade600, fontSize: 13)),
          Text(value,
              style: const TextStyle(
                  fontWeight: FontWeight.w600, fontSize: 13)),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow(String label, String value, Color color,
      {bool bold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: TextStyle(
              fontWeight: bold ? FontWeight.bold : FontWeight.normal,
            ),
          ),
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: color.withOpacity(0.1),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              value,
              style: TextStyle(fontWeight: FontWeight.bold, color: color),
            ),
          ),
        ],
      ),
    );
  }
}
