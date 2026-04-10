import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  // Mock pending transactions data
  late List<Map<String, dynamic>> pendingTransactions;
  bool _isSyncing = false;
  final ApiService _apiService = ApiService();
  int _syncedCount = 0;
  int _failedCount = 0;

  @override
  void initState() {
    super.initState();
    pendingTransactions = [
      {
        'id': '1',
        'amount': 50.00,
        'receiver': 'John Doe',
        'time': '2:30 PM',
        'status': 'pending',
      },
      {
        'id': '2',
        'amount': 75.00,
        'receiver': 'Sarah Smith',
        'time': '1:15 PM',
        'status': 'syncing',
      },
      {
        'id': '3',
        'amount': 45.00,
        'receiver': 'Mike Johnson',
        'time': '11:45 AM',
        'status': 'completed',
      },
      {
        'id': '4',
        'amount': 30.00,
        'receiver': 'Alex Kumar',
        'time': '10:20 AM',
        'status': 'failed',
      },
    ];
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
          'Sync',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header spacing
            const SizedBox(height: 24),

            // Main content area
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Sync Summary Card
                  _buildSummaryCard(),

                  const SizedBox(height: 40),

                  // Pending Transactions List or Empty State
                  pendingTransactions.isEmpty
                      ? _buildEmptyState()
                      : _buildTransactionsList(),

                  const SizedBox(height: 40),

                  // Sync Now Button
                  _buildSyncButton(),

                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== SUMMARY CARD SECTION ==========
  Widget _buildSummaryCard() {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: AppColors.red.withOpacity(0.25),
          width: 1.5,
        ),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          // Pending Transactions
          Text(
            '3 Pending',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),

          const SizedBox(height: 16),

          // Divider with red accent
          Container(
            height: 1,
            color: AppColors.red.withOpacity(0.2),
          ),

          const SizedBox(height: 16),

          // Total Amount Label
          Text(
            'Total Amount',
            style: TextStyle(
              color: AppColors.lightGrey,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),

          const SizedBox(height: 8),

          // Total Amount Value
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                '₹ ',
                style: TextStyle(
                  color: AppColors.red,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Text(
                '170',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ========== PENDING TRANSACTIONS LIST ==========
  Widget _buildTransactionsList() {
    return Column(
      children: [
        // Section Title
        Align(
          alignment: Alignment.centerLeft,
          child: Text(
            'Pending Transactions',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 14,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),

        const SizedBox(height: 16),

        // Transaction Items
        Column(
          children: pendingTransactions.map((transaction) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTransactionItem(transaction),
            );
          }).toList(),
        ),
      ],
    );
  }

  // ========== EMPTY STATE ==========
  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Empty State Icon
            Icon(
              Icons.check_circle_outline,
              size: 48,
              color: AppColors.lightGrey,
            ),

            const SizedBox(height: 16),

            // Empty State Message
            Text(
              'No pending transactions',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),

            const SizedBox(height: 8),

            // Subtitle
            Text(
              'All transactions are synced',
              style: TextStyle(
                color: AppColors.lightGrey,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== TRANSACTION ITEM CARD ==========
  Widget _buildTransactionItem(Map<String, dynamic> transaction) {
    return Container(
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(12),
      ),
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          // Left side: Amount and Receiver
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Amount
                Row(
                  children: [
                    const Text(
                      '₹ ',
                      style: TextStyle(
                        color: AppColors.red,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    Text(
                      transaction['amount'].toStringAsFixed(0),
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 6),

                // Receiver ID
                Text(
                  transaction['receiver'],
                  style: TextStyle(
                    color: AppColors.lightGrey,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          // Right side: Time and Status
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Time
              Text(
                transaction['time'],
                style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 11,
                ),
              ),

              const SizedBox(height: 8),

              // Status Indicator (dynamic based on status)
              _buildStatusIndicator(transaction['status']),
            ],
          ),
        ],
      ),
    );
  }

  // ========== STATUS INDICATOR WIDGET ==========
  Widget _buildStatusIndicator(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.red,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Pending',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case 'syncing':
        return Row(
          children: [
            SizedBox(
              width: 12,
              height: 12,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                valueColor: AlwaysStoppedAnimation<Color>(AppColors.red),
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Syncing...',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case 'completed':
        return Row(
          children: [
            Container(
              width: 14,
              height: 14,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.white,
              ),
              child: const Icon(
                Icons.check,
                size: 10,
                color: AppColors.black,
              ),
            ),
            const SizedBox(width: 6),
            const Text(
              'Completed',
              style: TextStyle(
                color: AppColors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      case 'failed':
        return Row(
          children: [
            const Icon(
              Icons.error_outline,
              size: 12,
              color: AppColors.red,
            ),
            const SizedBox(width: 6),
            const Text(
              'Failed',
              style: TextStyle(
                color: AppColors.red,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        );

      default:
        return const SizedBox.shrink();
    }
  }

  // ========== SYNC NOW BUTTON ==========
  Widget _buildSyncButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: _isSyncing ? null : _syncNow,
        style: ElevatedButton.styleFrom(
          backgroundColor: _isSyncing ? AppColors.grey : AppColors.red,
          foregroundColor: AppColors.white,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          elevation: 0,
        ),
        child: Text(
          _isSyncing ? 'Syncing...' : 'Sync Now',
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  // ========== SYNC NOW LOGIC ==========
  Future<void> _syncNow() async {
    // Reset counters
    _syncedCount = 0;
    _failedCount = 0;

    // Step 1: Set all pending transactions to "syncing"
    setState(() {
      _isSyncing = true;
      for (var transaction in pendingTransactions) {
        if (transaction['status'] == 'pending') {
          transaction['status'] = 'syncing';
        }
      }
    });

    print('🔄 Starting sync for ${pendingTransactions.length} transactions...');

    // Step 2: Process each transaction
    for (var transaction in pendingTransactions) {
      if (transaction['status'] == 'syncing') {
        await _settleTransaction(transaction);
      }
      // Allow UI to update between requests
      await Future.delayed(const Duration(milliseconds: 300));
    }

    // Step 3: Mark sync as complete
    setState(() {
      _isSyncing = false;
    });

    print('✓ Sync completed! Synced: $_syncedCount, Failed: $_failedCount');

    // Step 4: Show completion summary
    if (mounted) {
      final message = _failedCount == 0
          ? '✓ All transactions synced successfully!'
          : '⚠ Sync completed: $_syncedCount succeeded, $_failedCount failed';

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(message),
          duration: const Duration(seconds: 3),
          backgroundColor: _failedCount == 0 ? AppColors.red : Colors.orange,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          behavior: SnackBarBehavior.floating,
          margin: const EdgeInsets.all(16),
        ),
      );
    }
  }

  // ========== SETTLE INDIVIDUAL TRANSACTION ==========
  Future<void> _settleTransaction(Map<String, dynamic> transaction) async {
    try {
      // Prepare settlement data
      final settlementData = {
        'transactionId': transaction['id'],
        'amount': transaction['amount'],
        'receiver': transaction['receiver'],
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Call backend API
      final response = await _apiService.settlePayment(
        data: settlementData.toString(),
        signature: 'mock_signature', // In real app, this would be from wallet
        publicKey: 'mock_public_key', // In real app, this would be from wallet
      );

      print('✓ Transaction ${transaction['id']} settled: $response');

      // Update transaction status on success
      setState(() {
        transaction['status'] = 'completed';
        _syncedCount++;
      });
    } catch (e) {
      print('✗ Error settling transaction ${transaction['id']}: $e');

      // Update transaction status on failure
      setState(() {
        transaction['status'] = 'failed';
        _failedCount++;
      });
    }
  }
}
