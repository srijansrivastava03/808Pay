import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/tax_service.dart';

class CategorySelectorWidget extends StatelessWidget {
  final String selectedCategory;
  final Function(String) onCategoryChanged;

  const CategorySelectorWidget({
    Key? key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Payment Category',
          style: Theme.of(context).textTheme.titleMedium,
        ),
        const SizedBox(height: 12),
        Container(
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: AppColors.red.withOpacity(0.2),
              width: 1,
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
            onChanged: (String? newCategory) {
              if (newCategory != null) {
                onCategoryChanged(newCategory);
              }
            },
            items: TaxCalculationService.gstRates.keys.map((category) {
              final rate = TaxCalculationService.getGstRate(category);
              final displayName = TaxCalculationService.categoryNames[category] ?? category;
              
              return DropdownMenuItem<String>(
                value: category,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        displayName,
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 14,
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 4,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.red.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: Text(
                          'GST ${rate.toStringAsFixed(0)}%',
                          style: const TextStyle(
                            color: AppColors.red,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }
}
