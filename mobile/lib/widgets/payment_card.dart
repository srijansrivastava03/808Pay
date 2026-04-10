import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class PaymentCard extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController merchantController;
  final bool isLoading;
  final VoidCallback onCreatePayment;

  const PaymentCard({
    Key? key,
    required this.amountController,
    required this.merchantController,
    required this.isLoading,
    required this.onCreatePayment,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.red.withOpacity(0.2),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          TextField(
            controller: amountController,
            enabled: !isLoading,
            keyboardType: TextInputType.number,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              labelText: 'Amount (₹)',
              hintText: 'Enter payment amount',
              prefixIcon: const Icon(Icons.attach_money),
              labelStyle: const TextStyle(color: AppColors.red),
            ),
          ),
          const SizedBox(height: 16),
          TextField(
            controller: merchantController,
            enabled: !isLoading,
            keyboardType: TextInputType.text,
            style: const TextStyle(color: AppColors.white),
            decoration: InputDecoration(
              labelText: 'Merchant Name',
              hintText: 'Enter merchant name',
              prefixIcon: const Icon(Icons.store),
              labelStyle: const TextStyle(color: AppColors.red),
            ),
          ),
        ],
      ),
    );
  }
}
