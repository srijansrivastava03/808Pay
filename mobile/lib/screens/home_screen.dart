import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../theme/app_theme.dart';
import '../widgets/quick_action_button.dart';
import '../widgets/wallet_connection_widget.dart';
import '../models/transaction.dart';
import '../services/pera_wallet_service_v2.dart';
import '../services/settlement_sync_service.dart';
import '../services/transaction_queue_service.dart';
import 'create_deal_screen.dart';
import 'scan_sign_screen.dart';
import 'deal_history_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Mock wallet balance
  double walletBalance = 6850.00;

  // Mock recent transactions
  List<Transaction> mockTransactions = [
    Transaction(
      id: '1',
      sender: 'USERADDR123',
      recipient: 'Starbucks Coffee',
      amount: 450.00,
      status: 'settled',
      createdAt: DateTime.now().subtract(const Duration(hours: 2)),
      settledAt: DateTime.now().subtract(const Duration(hours: 1, minutes: 50)),
    ),
    Transaction(
      id: '2',
      sender: 'USERADDR123',
      recipient: 'Amazon Store',
      amount: 2500.00,
      status: 'pending',
      createdAt: DateTime.now().subtract(const Duration(minutes: 30)),
    ),
  ];

  void _handleSeeAll() {
    print('See all transactions tapped');
    // TODO: Navigate to history screen
  }

  void _handleQuickAction(String action) {
    print('$action tapped');
    // Map actions to navigation
    switch (action) {
      case 'Create Deal':
        print('Create Deal clicked');
        // ATOMIC SETTLEMENT: Navigate to Create Deal screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const CreateDealScreen()),
        );
        break;
      case 'Scan Deal':
        // ATOMIC SETTLEMENT: Navigate to Scan & Sign screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanSignScreen()),
        );
        break;
      case 'Add Money':
        print('Navigate to Add Money screen');
        break;
      case 'Favorites':
        print('Open Favorites');
        break;
      case 'Transactions':
        // ATOMIC SETTLEMENT: Navigate to Deal History screen
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const DealHistoryScreen()),
        );
        break;
      case 'Sync':
        // Trigger real settlement sync
        _handleManualSync();
        break;
    }
  }

  Future<void> _handleManualSync() async {
    print('🔄 Manual sync triggered');
    
    try {
      final syncService = Provider.of<SettlementSyncService>(context, listen: false);
      final queueService = Provider.of<TransactionQueueService>(context, listen: false);
      
      // Show loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('🔄 Syncing queued transactions...'),
          backgroundColor: AppColors.warning,
          duration: const Duration(seconds: 10),
        ),
      );
      
      // Get pending transactions
      final pending = await queueService.getPendingTransactions();
      print('📊 Pending transactions: ${pending.length}');
      
      if (pending.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('✅ No pending transactions to sync'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
        return;
      }
      
      // Try to sync
      await syncService.syncQueuedTransactions();
      
      // Show success
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Transactions synced! Check transaction history.'),
          backgroundColor: Colors.green,
          duration: Duration(seconds: 3),
        ),
      );
      
    } catch (e) {
      print('❌ Sync error: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Sync failed: $e'),
          backgroundColor: AppColors.red,
          duration: const Duration(seconds: 4),
        ),
      );
    }
  }

  // Mock refresh UI for Sync button
  void _mockRefreshUI() {
    print('🔄 Mock UI refresh triggered');
    setState(() {
      // Simulate UI refresh/sync
    });
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✓ UI refreshed'),
        duration: const Duration(seconds: 1),
        backgroundColor: AppColors.red,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 🔝 HEADER BAR
            _buildHeader(),
            
            const SizedBox(height: 24),

            // 🔐 PERA WALLET CONNECTION
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: WalletConnectionWidget(
                onConnected: () => _showSnackBar('Wallet connected!'),
                onDisconnected: () => _showSnackBar('Wallet disconnected'),
              ),
            ),

            const SizedBox(height: 40),

            // 🔴 MAIN ACTION BUTTONS (Pay & Receive)
            _buildMainActionButtons(),

            const SizedBox(height: 50),

            // ⚡ QUICK ACTIONS ROW (Secondary)
            _buildQuickActionsRow(),

            const SizedBox(height: 50),

            // 📊 RECENT TRANSACTIONS
            _buildRecentTransactions(),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Helper to show snackbar
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
      ),
    );
  }

  // ========== HEADER SECTION ==========
  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.black,
        border: Border(
          bottom: BorderSide(
            color: AppColors.grey.withOpacity(0.3),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        bottom: false,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // Left: Wallet Balance
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Wallet Balance',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Row(
                  children: [
                    Text(
                      '₹ ',
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        color: AppColors.red,
                        fontSize: 22,
                      ),
                    ),
                    Text(
                      walletBalance.toStringAsFixed(0),
                      style: Theme.of(context).textTheme.displayMedium?.copyWith(
                        fontSize: 22,
                      ),
                    ),
                  ],
                ),
              ],
            ),

            // Right: Profile Icon
            GestureDetector(
              onTap: () => print('Profile tapped'),
              child: Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppColors.grey,
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppColors.red.withOpacity(0.2),
                    width: 1,
                  ),
                ),
                child: const Icon(
                  Icons.person,
                  color: AppColors.lightGrey,
                  size: 24,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ========== MAIN ACTION BUTTONS ==========
  Widget _buildMainActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          // Create Deal Button (with handshake icon)
          Expanded(
            child: QuickActionButton(
              icon: Icons.handshake,
              label: 'Create Deal',
              onTap: () => _handleQuickAction('Create Deal'),
              height: 140,
              isMainAction: true,
            ),
          ),
          const SizedBox(width: 16),
          // Scan Deal Button (with QR code scanner icon)
          Expanded(
            child: QuickActionButton(
              icon: Icons.qr_code_scanner,
              label: 'Scan Deal',
              onTap: () => _handleQuickAction('Scan Deal'),
              height: 140,
              isMainAction: true,
            ),
          ),
        ],
      ),
    );
  }

  // ========== QUICK ACTIONS ROW ==========
  Widget _buildQuickActionsRow() {
    final actions = [
      {'icon': Icons.add_circle_outline, 'label': 'Add Money'},
      {'icon': Icons.history, 'label': 'Transactions'},
      {'icon': Icons.favorite_outline, 'label': 'Favorites'},
      {'icon': Icons.sync, 'label': 'Sync'},
    ];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Row 1: Add Money, Transactions
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  icon: actions[0]['icon'] as IconData,
                  label: actions[0]['label'] as String,
                  onTap: () => _handleQuickAction(actions[0]['label'] as String),
                  height: 90,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: QuickActionButton(
                  icon: actions[1]['icon'] as IconData,
                  label: actions[1]['label'] as String,
                  onTap: () => _handleQuickAction(actions[1]['label'] as String),
                  height: 90,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Row 2: Favorites, Sync (with pending badge)
          Row(
            children: [
              Expanded(
                child: QuickActionButton(
                  icon: actions[2]['icon'] as IconData,
                  label: actions[2]['label'] as String,
                  onTap: () => _handleQuickAction(actions[2]['label'] as String),
                  height: 90,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: FutureBuilder<int>(
                  future: _getPendingTransactionCount(),
                  builder: (context, snapshot) {
                    final pendingCount = snapshot.data ?? 0;
                    return Stack(
                      children: [
                        QuickActionButton(
                          icon: actions[3]['icon'] as IconData,
                          label: pendingCount > 0 
                            ? '${actions[3]['label']}\n($pendingCount)' 
                            : actions[3]['label'] as String,
                          onTap: () => _handleQuickAction(actions[3]['label'] as String),
                          height: 90,
                        ),
                        if (pendingCount > 0)
                          Positioned(
                            right: 8,
                            top: 8,
                            child: Container(
                              padding: const EdgeInsets.all(6),
                              decoration: BoxDecoration(
                                color: AppColors.red,
                                shape: BoxShape.circle,
                              ),
                              child: Text(
                                '$pendingCount',
                                style: const TextStyle(
                                  color: AppColors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Future<int> _getPendingTransactionCount() async {
    try {
      final queueService = Provider.of<TransactionQueueService>(context, listen: false);
      final pending = await queueService.getPendingTransactions();
      return pending.length;
    } catch (e) {
      print('Error getting pending count: $e');
      return 0;
    }
  }

  // ========== RECENT TRANSACTIONS SECTION ==========
  Widget _buildRecentTransactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title + See all link
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Recent Transactions',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              GestureDetector(
                onTap: _handleSeeAll,
                child: Text(
                  'See all',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.red,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Transaction cards
          if (mockTransactions.isEmpty)
            Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(vertical: 24.0),
                child: Text(
                  'No transactions yet',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ),
            )
          else
            ...mockTransactions.map((transaction) {
              return _buildTransactionCard(transaction);
            }).toList(),
        ],
      ),
    );
  }

  Widget _buildTransactionCard(Transaction transaction) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: AppColors.grey,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: _getStatusBorderColor(transaction.status),
          width: 1,
        ),
      ),
      padding: const EdgeInsets.all(14),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left: Status indicator + Transaction details
          Expanded(
            child: Row(
              children: [
                // Status indicator dot
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: _getStatusColor(transaction.status),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        transaction.recipient,
                        style: Theme.of(context).textTheme.bodyMedium,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        transaction.status.toUpperCase(),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: _getStatusTextColor(transaction.status),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Right: Amount (Red)
          Text(
            '₹${transaction.amount.toStringAsFixed(0)}',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              color: AppColors.red,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status) {
      case 'settled':
        return const Color(0xFFE8E8E8); // Subtle white
      case 'pending':
        return AppColors.red;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.lightGrey;
    }
  }

  Color _getStatusTextColor(String status) {
    switch (status) {
      case 'settled':
        return const Color(0xFFE8E8E8);
      case 'pending':
        return AppColors.red;
      case 'failed':
        return AppColors.error;
      default:
        return AppColors.lightGrey;
    }
  }

  Color _getStatusBorderColor(String status) {
    switch (status) {
      case 'settled':
        return const Color(0xFFE8E8E8).withOpacity(0.2);
      case 'pending':
        return AppColors.red.withOpacity(0.2);
      case 'failed':
        return AppColors.error.withOpacity(0.2);
      default:
        return AppColors.lightGrey.withOpacity(0.2);
    }
  }
}
