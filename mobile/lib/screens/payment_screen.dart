import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/payment_card.dart';
import '../widgets/tax_breakdown_widget.dart';
import '../widgets/offline_status_widget.dart';
import '../services/transaction_service.dart';
import '../services/tax_service.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _merchantController = TextEditingController();
  String _selectedCategory = 'electronics';
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  void _handleSignPayment() async {
    final amount = double.tryParse(_amountController.text);
    final merchant = _merchantController.text;

    if (amount == null || amount <= 0) {
      _showError('Please enter a valid amount');
      return;
    }

    if (merchant.isEmpty) {
      _showError('Please enter recipient address');
      return;
    }

    if (!TaxCalculationService.isValidCategory(_selectedCategory)) {
      _showError('Invalid category selected');
      return;
    }

    setState(() => _isLoading = true);

    try {
      // Create transaction data
      final txData = TransactionService.createTransactionData(
        amount: amount,
        recipientAddress: merchant,
        senderAddress: 'user_demo', // TODO: Get from wallet
        category: _selectedCategory,
      );

      // TODO: Get actual keypair from OfflineStorageService
      // For demo: use dummy keypair
      const seedHex = 'abcdef1234567890abcdef1234567890abcdef1234567890abcdef1234567890';
      const publicKeyHex = 'fedcba0987654321fedcba0987654321fedcba0987654321fedcba0987654321';

      // Sign offline
      final signed = await TransactionService.signTransactionOffline(
        transactionData: txData,
        seedHex: seedHex,
        publicKeyHex: publicKeyHex,
      );

      if (mounted) {
        _showSuccess(
          'Payment signed offline! ✓\n\n'
          'Amount: ₹${amount.toStringAsFixed(2)}\n'
          'Tax (${TaxCalculationService.getGstRate(_selectedCategory).toStringAsFixed(0)}%): '
          '₹${TaxCalculationService.calculateInclusiveTax(amount: amount, category: _selectedCategory).toStringAsFixed(2)}\n\n'
          'Ready to submit when online.',
        );

        // TODO: Save to OfflineStorageService
        // await OfflineStorageService.savePendingTransaction(signed);

        // Clear inputs
        _amountController.clear();
        _merchantController.clear();
      }
    } catch (e) {
      _showError('Error signing payment: $e');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColors.red,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _showSuccess(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final amount = double.tryParse(_amountController.text) ?? 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Payment'),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Offline status bar
            const OfflineStatusWidget(),

            Padding(
              padding: const EdgeInsets.all(20.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Header
                  const SizedBox(height: 10),
                  Text(
                    'Sign Payment Offline',
                    style: Theme.of(context).textTheme.displayMedium,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'No internet needed to sign. Works even offline! ✓',
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                  const SizedBox(height: 30),

                  // Payment Card
                  PaymentCard(
                    amountController: _amountController,
                    merchantController: _merchantController,
                    isLoading: _isLoading,
                    onCreatePayment: _handleSignPayment,
                    selectedCategory: _selectedCategory,
                    onCategoryChanged: (category) {
                      setState(() => _selectedCategory = category);
                    },
                  ),
                  const SizedBox(height: 30),

                  // Tax Breakdown
                  if (amount > 0)
                    Column(
                      children: [
                        TaxBreakdownWidget(
                          amount: amount,
                          category: _selectedCategory,
                        ),
                        const SizedBox(height: 30),
                      ],
                    ),

                  // Sign Button
                  ElevatedButton.icon(
                    onPressed: _isLoading ? null : _handleSignPayment,
                    icon: _isLoading
                        ? const SizedBox(
                            height: 16,
                            width: 16,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(AppColors.white),
                            ),
                          )
                        : const Icon(Icons.security),
                    label: Text(_isLoading ? 'Signing...' : 'Sign Payment (Offline)'),
                    style: ElevatedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      backgroundColor: AppColors.red,
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Info text
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.grey,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: AppColors.red.withOpacity(0.2),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'ℹ️ How it works:',
                          style: Theme.of(context).textTheme.titleSmall,
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          '1. Enter amount and select category\n'
                          '2. Review the tax breakdown\n'
                          '3. Click "Sign Payment (Offline)"\n'
                          '4. Payment gets signed without internet\n'
                          '5. QR code generated locally\n'
                          '6. Submit when online',
                          style: TextStyle(
                            color: AppColors.lightGrey,
                            fontSize: 12,
                            height: 1.6,
                          ),
                        ),
                      ],
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
}
