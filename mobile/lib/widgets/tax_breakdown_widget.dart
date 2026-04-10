import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/tax_service.dart';

class TaxBreakdownWidget extends StatelessWidget {
  final double amount;
  final String category;

  const TaxBreakdownWidget({
    Key? key,
    required this.amount,
    required this.category,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    if (amount <= 0) {
      return const SizedBox.shrink();
    }

    final breakdown = TaxCalculationService.calculateBreakdown(
      amount: amount,
      category: category,
    );

    final merchant = breakdown['merchant']!;
    final tax = breakdown['tax']!;
    final loyalty = breakdown['loyalty']!;
    final gstRate = breakdown['gstRate']!;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppColors.red.withOpacity(0.3),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Payment Breakdown',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  'GST ${gstRate.toStringAsFixed(0)}%',
                  style: const TextStyle(
                    color: AppColors.red,
                    fontWeight: FontWeight.bold,
                    fontSize: 12,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Total Amount
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.5),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: AppColors.red.withOpacity(0.3),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Total Payment',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                Text(
                  '₹${amount.toStringAsFixed(2)}',
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: AppColors.red,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 20),

          // Breakdown items
          _buildBreakdownRow(
            label: '🏪 Merchant',
            amount: merchant,
            percentage: (merchant / amount * 100),
            color: Colors.green,
          ),
          const SizedBox(height: 12),
          _buildBreakdownRow(
            label: '🏛️ Tax/Government',
            amount: tax,
            percentage: (tax / amount * 100),
            color: AppColors.red,
          ),
          const SizedBox(height: 12),
          _buildBreakdownRow(
            label: '🎁 Loyalty Points',
            amount: loyalty,
            percentage: (loyalty / amount * 100),
            color: Colors.purple,
          ),

          const SizedBox(height: 16),

          // Info box
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.green.withOpacity(0.1),
              borderRadius: BorderRadius.circular(6),
            ),
            child: Row(
              children: const [
                Icon(Icons.check_circle, color: Colors.green, size: 16),
                SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Ready to sign offline - No internet needed!',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBreakdownRow({
    required String label,
    required double amount,
    required double percentage,
    required Color color,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.w500,
              ),
            ),
            Text(
              '₹${amount.toStringAsFixed(2)}',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 13,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        Row(
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: BorderRadius.circular(4),
                child: LinearProgressIndicator(
                  value: percentage / 100,
                  minHeight: 6,
                  backgroundColor: AppColors.darkGrey,
                  valueColor: AlwaysStoppedAnimation<Color>(color),
                ),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '${percentage.toStringAsFixed(1)}%',
              style: const TextStyle(
                color: AppColors.lightGrey,
                fontSize: 11,
              ),
            ),
          ],
        ),
      ],
    );
  }
}
