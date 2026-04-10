import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../widgets/payment_card.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({Key? key}) : super(key: key);

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final TextEditingController _amountController = TextEditingController();
  final TextEditingController _merchantController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    super.dispose();
  }

  void _handleCreatePayment() {
    final amount = double.tryParse(_amountController.text);
    final merchant = _merchantController.text;

    if (amount == null || amount <= 0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter a valid amount'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    if (merchant.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter merchant name'),
          backgroundColor: AppColors.red,
        ),
      );
      return;
    }

    print('Creating payment: $amount for merchant: $merchant');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 20),
              Text(
                'Create Payment',
                style: Theme.of(context).textTheme.displayMedium,
              ),
              const SizedBox(height: 12),
              Text(
                'Enter payment details below',
                style: Theme.of(context).textTheme.bodySmall,
              ),
              const SizedBox(height: 30),
              PaymentCard(
                amountController: _amountController,
                merchantController: _merchantController,
                isLoading: _isLoading,
                onCreatePayment: _handleCreatePayment,
              ),
              const SizedBox(height: 30),
              ElevatedButton(
                onPressed: _isLoading ? null : _handleCreatePayment,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(
                            AppColors.white,
                          ),
                        ),
                      )
                    : const Text('Create Payment'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
