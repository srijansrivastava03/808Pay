import 'package:flutter/material.dart';
import '../theme/app_theme.dart';
import '../services/api_service.dart';
import '../services/transaction_queue_service.dart';

class SyncScreen extends StatefulWidget {
  const SyncScreen({Key? key}) : super(key: key);

  @override
  State<SyncScreen> createState() => _SyncScreenState();
}

class _SyncScreenState extends State<SyncScreen> {
  late List<QueuedTransaction> pendingTransactions = [];
  late List<Map<String, dynamic>> displayTransactions = [];
  bool _isSyncing = false;
  final ApiService _apiService = ApiService();
  final TransactionQueueService _queueService = TransactionQueueService();
  int _syncedCount = 0;
  int _failedCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeQueueService();
  }

  Future<void> _initializeQueueService() async {
    await _queueService.initialize();
    await _loadPendingTransactions();
  }

  Future<void> _loadPendingTransactions() async {
    try {
      final pending = await _queueService.getPendingTransactions();
      setState(() {
        pendingTransactions = pending;
        displayTransactions = pending
            .map((t) => {
                  'id': t.id,
                  'amount': double.tryParse(t.amount) ?? 0.0,
                  'receiver': t.receiver,
                  'dealId': t.dealId,
                  'time': _formatTime(t.createdAt),
                  'status': 'pending',
                  'transaction': t,
                })
            .toList();
      });
    } catch (e) {
      print('❌ Error loading pending transactions: $e');
    }
  }

  String _formatTime(DateTime dateTime) {
    final now = DateTime.now();
    final diff = now.difference(dateTime);
    
    if (diff.inMinutes < 1) {
      return 'just now';
    } else if (diff.inHours < 1) {
      return '${diff.inMinutes}m ago';
    } else if (diff.inDays < 1) {
      return '${diff.inHours}h ago';
    } else {
      return dateTime.toLocal().toString().split(' ')[0];
    }
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
                  displayTransactions.isEmpty
                      ? _buildEmptyState()
                      : _buildTransactionsList(),

                  const SizedBox(height: 40),

                  // Sync Now Button
                  _buildSyncButton(),

                  const SizedBox(height: 16),

                  // Clear Queue Button
                  _buildClearQueueButton(),

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
    final totalAmount = displayTransactions
        .fold<double>(0, (sum, t) => sum + (t['amount'] as double));
    final pendingCount = displayTransactions.length;

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
            '$pendingCount ${pendingCount == 1 ? 'Transaction' : 'Transactions'} Pending',
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
              Text(
                totalAmount.toStringAsFixed(0),
                style: const TextStyle(
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
          children: displayTransactions.map((transaction) {
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
        onPressed: _isSyncing || displayTransactions.isEmpty ? null : _syncNow,
        style: ElevatedButton.styleFrom(
          backgroundColor: (_isSyncing || displayTransactions.isEmpty) ? AppColors.grey : AppColors.red,
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

  // ========== CLEAR QUEUE BUTTON ==========
  Widget _buildClearQueueButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: displayTransactions.isEmpty ? null : _showClearQueueDialog,
        style: ElevatedButton.styleFrom(
          backgroundColor: displayTransactions.isEmpty ? AppColors.grey : Colors.transparent,
          foregroundColor: AppColors.red,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: displayTransactions.isEmpty ? AppColors.grey : AppColors.red,
              width: 2,
            ),
          ),
          elevation: 0,
        ),
        child: const Text(
          'Clear Queue',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Future<void> _showClearQueueDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        backgroundColor: AppColors.grey,
        title: const Text(
          'Clear Transaction Queue?',
          style: TextStyle(
            color: AppColors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will delete ${displayTransactions.length} pending transaction(s) and prevent auto-sync. You cannot undo this action.',
          style: const TextStyle(
            color: AppColors.lightGrey,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AppColors.lightGrey),
            ),
          ),
          TextButton(
            onPressed: _clearQueue,
            child: const Text(
              'Clear',
              style: TextStyle(
                color: AppColors.red,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _clearQueue() async {
    try {
      Navigator.pop(context); // Close dialog
      
      await _queueService.clearPendingTransactions();
      
      setState(() {
        displayTransactions.clear();
        pendingTransactions.clear();
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ Transaction queue cleared'),
            duration: Duration(seconds: 2),
            backgroundColor: AppColors.red,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.all(Radius.circular(12)),
            ),
            behavior: SnackBarBehavior.floating,
            margin: EdgeInsets.all(16),
          ),
        );
      }
    } catch (e) {
      print('❌ Error clearing queue: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Error clearing queue: $e'),
            duration: const Duration(seconds: 3),
            backgroundColor: Colors.red,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  // ========== SYNC NOW LOGIC ==========
  Future<void> _syncNow() async {
    // Reset counters
    _syncedCount = 0;
    _failedCount = 0;

    // Step 1: Set all pending transactions to "syncing"
    setState(() {
      _isSyncing = true;
      for (var transaction in displayTransactions) {
        if (transaction['status'] == 'pending') {
          transaction['status'] = 'syncing';
        }
      }
    });

    print('🔄 Starting sync for ${displayTransactions.length} transactions...');

    // Step 2: Process each transaction
    for (var transaction in displayTransactions) {
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

    // Step 4: Reload pending transactions
    await _loadPendingTransactions();

    // Step 5: Show completion summary
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
      final queuedTxn = transaction['transaction'] as QueuedTransaction;

      print('📤 Submitting transaction: ${queuedTxn.id}');

      // Call backend with real signatures
      final response = await _apiService.settlePayment(
        data: queuedTxn.data,
        signature: queuedTxn.signature,
        publicKey: queuedTxn.publicKey,
      );

      print('✓ Transaction ${queuedTxn.id} settled: $response');

      // Mark as submitted in queue service
      await _queueService.markAsSubmitted(queuedTxn.id);

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
