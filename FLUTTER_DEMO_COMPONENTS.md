# Flutter Demo UI Components

## Tax Breakdown Widget

Add this to show how ₹100 splits differently by category:

```dart
// lib/widgets/tax_breakdown_widget.dart

import 'package:flutter/material.dart';

class TaxBreakdownWidget extends StatelessWidget {
  final double amount;
  final String category;
  final double taxRate;

  TaxBreakdownWidget({
    required this.amount,
    required this.category,
    required this.taxRate,
  });

  Map<String, dynamic> calculateBreakdown() {
    // Inclusive tax calculation: tax = (amount * rate) / (100 + rate)
    final taxAmount = (amount * taxRate) / (100 + taxRate);
    final baseAmount = amount - taxAmount;
    
    // Split: 90% merchant, 5% tax, 5% loyalty (from baseAmount)
    final merchantShare = baseAmount * 0.90;
    final loyaltyShare = baseAmount * 0.05;
    
    return {
      'merchant': merchantShare,
      'tax': taxAmount,
      'loyalty': loyaltyShare,
    };
  }

  @override
  Widget build(BuildContext context) {
    final breakdown = calculateBreakdown();
    
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header
            Text(
              'Payment Breakdown',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            
            // Category & Tax Rate
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Category: $category'),
                Text('GST: ${taxRate.toStringAsFixed(1)}%',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
              ],
            ),
            SizedBox(height: 16),
            
            // Total Amount
            Container(
              padding: EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.grey[100],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Total Payment'),
                  Text(
                    '₹${amount.toStringAsFixed(2)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 16),
            
            // Breakdown Chart
            Column(
              children: [
                // Merchant
                _buildBreakdownRow(
                  label: '🏪 Merchant',
                  amount: breakdown['merchant'],
                  percentage: (breakdown['merchant'] / amount * 100),
                  color: Colors.green,
                ),
                SizedBox(height: 12),
                
                // Tax
                _buildBreakdownRow(
                  label: '🏛️ Tax/Government',
                  amount: breakdown['tax'],
                  percentage: (breakdown['tax'] / amount * 100),
                  color: Colors.orange,
                ),
                SizedBox(height: 12),
                
                // Loyalty
                _buildBreakdownRow(
                  label: '🎁 Loyalty Points',
                  amount: breakdown['loyalty'],
                  percentage: (breakdown['loyalty'] / amount * 100),
                  color: Colors.purple,
                ),
              ],
            ),
            
            SizedBox(height: 16),
            
            // Offline Indicator
            Container(
              padding: EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[100],
                borderRadius: BorderRadius.circular(4),
              ),
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 16),
                  SizedBox(width: 8),
                  Text('Signed Offline - Ready to Submit'),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBreakdownRow({
    required String label,
    required double amount,
    required double percentage,
    required Color color,
  }) {
    return Row(
      children: [
        Expanded(
          flex: 2,
          child: Text(label),
        ),
        Expanded(
          flex: 2,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(4),
            child: LinearProgressIndicator(
              value: percentage / 100,
              minHeight: 24,
              backgroundColor: Colors.grey[300],
              valueColor: AlwaysStoppedAnimation(color),
            ),
          ),
        ),
        SizedBox(width: 12),
        Expanded(
          flex: 1,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                '₹${amount.toStringAsFixed(2)}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '${percentage.toStringAsFixed(1)}%',
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
```

---

## Offline Status Indicator

```dart
// lib/widgets/offline_status_widget.dart

import 'package:flutter/material.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class OfflineStatusWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<ConnectivityResult>(
      stream: Connectivity().onConnectivityChanged,
      builder: (context, snapshot) {
        final isOffline = snapshot.data == ConnectivityResult.none;
        
        return Container(
          padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          color: isOffline ? Colors.red[100] : Colors.green[100],
          child: Row(
            children: [
              Icon(
                isOffline ? Icons.wifi_off : Icons.wifi,
                color: isOffline ? Colors.red : Colors.green,
              ),
              SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      isOffline ? 'OFFLINE MODE' : 'Online',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isOffline ? Colors.red[700] : Colors.green[700],
                      ),
                    ),
                    Text(
                      isOffline
                          ? 'Payments can be signed without internet'
                          : 'Ready to submit payments',
                      style: TextStyle(fontSize: 12),
                    ),
                  ],
                ),
              ),
              if (isOffline)
                Icon(Icons.check_circle, color: Colors.green, size: 24),
            ],
          ),
        );
      },
    );
  }
}
```

---

## Category Selector for Tax Demo

```dart
// lib/widgets/category_selector_widget.dart

import 'package:flutter/material.dart';

class CategorySelectorWidget extends StatefulWidget {
  final Function(String category, double taxRate) onCategorySelected;

  CategorySelectorWidget({required this.onCategorySelected});

  @override
  _CategorySelectorWidgetState createState() =>
      _CategorySelectorWidgetState();
}

class _CategorySelectorWidgetState extends State<CategorySelectorWidget> {
  final categories = {
    '🍔 Food': {'rate': 5.0, 'description': 'Food & Groceries'},
    '💊 Medicine': {'rate': 0.0, 'description': 'Healthcare'},
    '⚡ Electronics': {'rate': 12.0, 'description': 'Gadgets & Devices'},
    '💼 Services': {'rate': 18.0, 'description': 'Professional Services'},
    '👜 Luxury': {'rate': 28.0, 'description': 'Premium Goods'},
  };

  String? selectedCategory;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Select Payment Category',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            SizedBox(height: 16),
            Column(
              children: categories.entries.map((entry) {
                final name = entry.key;
                final data = entry.value as Map<String, dynamic>;
                final rate = data['rate'] as double;
                final description = data['description'] as String;
                final isSelected = selectedCategory == name;

                return Padding(
                  padding: EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        selectedCategory = name;
                      });
                      widget.onCategorySelected(name, rate);
                    },
                    child: Container(
                      padding: EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: isSelected ? Colors.blue : Colors.grey[300]!,
                          width: isSelected ? 2 : 1,
                        ),
                        borderRadius: BorderRadius.circular(8),
                        color: isSelected ? Colors.blue[50] : Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                name,
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                description,
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                              ),
                            ],
                          ),
                          Container(
                            padding: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.orange[100],
                              borderRadius: BorderRadius.circular(4),
                            ),
                            child: Text(
                              'GST: ${rate.toStringAsFixed(0)}%',
                              style: TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.orange[700],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
```

---

## How to Use in Demo

Update `lib/screens/payment_screen.dart`:

```dart
import 'package:flutter/material.dart';
import '../widgets/category_selector_widget.dart';
import '../widgets/tax_breakdown_widget.dart';
import '../widgets/offline_status_widget.dart';

class PaymentScreenDemo extends StatefulWidget {
  @override
  _PaymentScreenDemoState createState() => _PaymentScreenDemoState();
}

class _PaymentScreenDemoState extends State<PaymentScreenDemo> {
  double amount = 100.0;
  String selectedCategory = '⚡ Electronics';
  double taxRate = 12.0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('808Pay - Demo')),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Show offline status
            OfflineStatusWidget(),
            SizedBox(height: 16),
            
            Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  // Amount Input
                  TextField(
                    decoration: InputDecoration(
                      label: Text('Amount (₹)'),
                      border: OutlineInputBorder(),
                    ),
                    keyboardType: TextInputType.number,
                    onChanged: (value) {
                      setState(() {
                        amount = double.tryParse(value) ?? 100.0;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  
                  // Category Selector
                  CategorySelectorWidget(
                    onCategorySelected: (category, rate) {
                      setState(() {
                        selectedCategory = category;
                        taxRate = rate;
                      });
                    },
                  ),
                  SizedBox(height: 20),
                  
                  // Tax Breakdown
                  TaxBreakdownWidget(
                    amount: amount,
                    category: selectedCategory,
                    taxRate: taxRate,
                  ),
                  SizedBox(height: 20),
                  
                  // Sign Button
                  ElevatedButton.icon(
                    onPressed: () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('✓ Transaction Signed Offline!'),
                          backgroundColor: Colors.green,
                        ),
                      );
                    },
                    icon: Icon(Icons.security),
                    label: Text('Sign Payment (Offline)'),
                    style: ElevatedButton.styleFrom(
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
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
```

---

## Demo Talking Points

Show these in sequence:

1. **Offline Mode** - "WiFi is off, but the app still works"
2. **Category Selection** - "Pick a category, tax rate changes"
3. **Tax Breakdown** - "₹100 becomes different amounts based on tax"
4. **Sign Button** - "All signed locally, no internet"
5. **Then Online** - "Submit signed transaction to backend"

This makes both ideas crystal clear! 🚀
