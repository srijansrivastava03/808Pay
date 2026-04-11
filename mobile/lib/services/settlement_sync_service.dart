import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:pay_808/services/transaction_queue_service.dart';
import 'package:pay_808/services/api_service.dart';
import 'dart:async';

/// Settlement Sync Service
/// Monitors network connectivity and syncs queued transactions when online
class SettlementSyncService {
  final TransactionQueueService queueService;
  final ApiService apiService;
  final Connectivity connectivity;

  late StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  bool _isOnline = false;
  Function? _onSyncComplete;
  Function(String)? _onSyncError;

  SettlementSyncService({
    required this.queueService,
    required this.apiService,
    Connectivity? connectivity,
  }) : connectivity = connectivity ?? Connectivity();

  /// Initialize sync service and start monitoring
  Future<void> initialize() async {
    try {
      // Check initial connectivity
      final result = await connectivity.checkConnectivity();
      _isOnline = result != ConnectivityResult.none;
      print('📡 Initial connectivity: $_isOnline');

      // Monitor connectivity changes
      _connectivitySubscription = connectivity.onConnectivityChanged.listen(
        (ConnectivityResult result) {
          final wasOnline = _isOnline;
          _isOnline = result != ConnectivityResult.none;

          print('📡 Connectivity changed: $result');

          // If came online, try to sync
          if (!wasOnline && _isOnline) {
            print('🔄 Device came online! Syncing queued transactions...');
            syncQueuedTransactions();
          }
        },
      );

      print('✅ Settlement Sync Service initialized');
    } catch (e) {
      print('❌ Error initializing sync service: $e');
    }
  }

  /// Sync all queued transactions to backend
  Future<void> syncQueuedTransactions() async {
    try {
      if (!_isOnline) {
        print('📵 Still offline, cannot sync');
        return;
      }

      final pending = await queueService.getPendingTransactions();
      if (pending.isEmpty) {
        print('✅ No pending transactions to sync');
        return;
      }

      print('🔄 Syncing ${pending.length} transaction(s)...');

      for (final txn in pending) {
        try {
          print('📤 Submitting transaction: ${txn.id}');

          // Call backend with real signatures
          final result = await apiService.settlePayment(
            data: txn.data,
            signature: txn.signature,
            publicKey: txn.publicKey,
          );

          print('✅ Transaction submitted: ${txn.id}');
          print('   Response: ${result['transactionId'] ?? result['message']}');

          // Mark as submitted
          await queueService.markAsSubmitted(txn.id);
        } catch (e) {
          print('❌ Failed to submit ${txn.id}: $e');
          _onSyncError?.call('Failed to submit ${txn.dealId}: $e');
        }
      }

      // Clear submitted transactions
      await queueService.clearSubmitted();

      // Get stats
      final stats = await queueService.getStats();
      print('📊 Queue stats: Pending=${stats['pending']}, Submitted=${stats['submitted']}');

      _onSyncComplete?.call();
    } catch (e) {
      print('❌ Sync error: $e');
      _onSyncError?.call('Sync failed: $e');
    }
  }

  /// Manually trigger sync (for testing)
  Future<void> forceSyncNow() async {
    print('🔄 Forcing sync now...');
    await syncQueuedTransactions();
  }

  /// Get current connectivity status
  bool get isOnline => _isOnline;

  /// Set callback for successful sync
  void onSyncComplete(Function callback) {
    _onSyncComplete = callback;
  }

  /// Set callback for sync errors
  void onSyncError(Function(String) callback) {
    _onSyncError = callback;
  }

  /// Get queue statistics
  Future<Map<String, dynamic>> getQueueStats() async {
    return await queueService.getStats();
  }

  /// Dispose resources
  void dispose() {
    _connectivitySubscription?.cancel();
    print('🛑 Settlement Sync Service disposed');
  }
}
