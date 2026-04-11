import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/tax_service.dart';

class PaymentCard extends StatelessWidget {
  final TextEditingController amountController;
  final TextEditingController merchantController;
  final bool isLoading;
  final VoidCallback onCreatePayment;
  final String selectedCategory;
  final Function(String)? onCategoryChanged;
  final VoidCallback? onScanQR;

  const PaymentCard({
    Key? key,
    required this.amountController,
    required this.merchantController,
    required this.isLoading,
    required this.onCreatePayment,
    this.selectedCategory = 'electronics',
    this.onCategoryChanged,
    this.onScanQR,
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
          // Amount Input
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

          // Category Selector
          Text(
            'Payment Category',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppColors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            decoration: BoxDecoration(
              color: AppColors.darkGrey,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.red.withOpacity(0.2),
              ),
            ),
            child: DropdownButton<String>(
              value: selectedCategory,
              isExpanded: true,
              underline: const SizedBox(),
              icon: const Padding(
                padding: EdgeInsets.only(right: 12),
                child: Icon(Icons.expand_more, color: AppColors.red),
              ),
              onChanged: (String? cat) {
                if (cat != null && onCategoryChanged != null) {
                  onCategoryChanged!(cat);
                }
              },
              items: TaxCalculationService.gstRates.keys.map((cat) {
                final rate = TaxCalculationService.getGstRate(cat);
                final name = TaxCalculationService.categoryNames[cat] ?? cat;
                return DropdownMenuItem<String>(
                  value: cat,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(name, style: const TextStyle(color: AppColors.white)),
                        Text(
                          '${rate.toStringAsFixed(0)}% GST',
                          style: const TextStyle(color: AppColors.red, fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 16),

          // Merchant Input with QR Button
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: merchantController,
                  enabled: !isLoading,
                  keyboardType: TextInputType.text,
                  style: const TextStyle(color: AppColors.white),
                  decoration: InputDecoration(
                    labelText: 'Recipient Address',
                    hintText: 'Enter merchant address or wallet',
                    prefixIcon: const Icon(Icons.store),
                    labelStyle: const TextStyle(color: AppColors.red),
                  ),
                ),
              ),
              const SizedBox(width: 8),
              if (onScanQR != null)
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.red,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: IconButton(
                    onPressed: isLoading ? null : onScanQR,
                    icon: const Icon(Icons.qr_code_2, color: AppColors.white),
                    tooltip: 'Scan QR Code',
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

