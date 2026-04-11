import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Model for queued transaction
class QueuedTransaction {
  final String id;
  final String dealId;
  final String amount;
  final String receiver;
  final String category;
  final String signature;
  final String publicKey;
  final String data;
  final String signer;
  final DateTime createdAt;
  DateTime? submittedAt;
  bool isSubmitted;

  QueuedTransaction({
    required this.id,
    required this.dealId,
    required this.amount,
    required this.receiver,
    required this.category,
    required this.signature,
    required this.publicKey,
    required this.data,
    required this.signer,
    required this.createdAt,
    this.submittedAt,
    this.isSubmitted = false,
  });

  /// Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'dealId': dealId,
      'amount': amount,
      'receiver': receiver,
      'category': category,
      'signature': signature,
      'publicKey': publicKey,
      'data': data,
      'signer': signer,
      'createdAt': createdAt.toIso8601String(),
      'submittedAt': submittedAt?.toIso8601String(),
      'isSubmitted': isSubmitted,
    };
  }

  /// Create from JSON
  factory QueuedTransaction.fromJson(Map<String, dynamic> json) {
    return QueuedTransaction(
      id: json['id'] as String,
      dealId: json['dealId'] as String,
      amount: json['amount'] as String,
      receiver: json['receiver'] as String,
      category: json['category'] as String,
      signature: json['signature'] as String,
      publicKey: json['publicKey'] as String,
      data: json['data'] as String,
      signer: json['signer'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      submittedAt: json['submittedAt'] != null
          ? DateTime.parse(json['submittedAt'] as String)
          : null,
      isSubmitted: json['isSubmitted'] as bool? ?? false,
    );
  }
}

/// Transaction Queue Service
/// Manages offline transaction queuing and synchronization
class TransactionQueueService {
  static const String _queueKey = 'transaction_queue';
  static const String _submittedKey = 'submitted_transactions';
  late SharedPreferences _prefs;

  /// Initialize service
  Future<void> initialize() async {
    _prefs = await SharedPreferences.getInstance();
    print('✅ Transaction Queue Service initialized');
  }

  /// Queue a transaction for later settlement
  Future<void> queueTransaction(
    String dealId,
    String amount,
    String receiver,
    String category,
    String signature,
    String publicKey,
    String data,
    String signer,
  ) async {
    try {
      final transaction = QueuedTransaction(
        id: 'txn_${DateTime.now().millisecondsSinceEpoch}',
        dealId: dealId,
        amount: amount,
        receiver: receiver,
        category: category,
        signature: signature,
        publicKey: publicKey,
        data: data,
        signer: signer,
        createdAt: DateTime.now(),
      );

      // Get existing queue
      final queue = await getQueue();
      queue.add(transaction);

      // Save to local storage
      final queueJson = queue.map((t) => jsonEncode(t.toJson())).toList();
      await _prefs.setStringList(_queueKey, queueJson);

      print('✅ Transaction queued: ${transaction.id}');
      print('   Deal: $dealId, Amount: ₹$amount');
      print('   Queue size: ${queue.length}');
    } catch (e) {
      print('❌ Error queuing transaction: $e');
      rethrow;
    }
  }

  /// Get all queued transactions
  Future<List<QueuedTransaction>> getQueue() async {
    try {
      final queueJson = _prefs.getStringList(_queueKey) ?? [];
      return queueJson
          .map((json) => QueuedTransaction.fromJson(jsonDecode(json)))
          .toList();
    } catch (e) {
      print('❌ Error retrieving queue: $e');
      return [];
    }
  }

  /// Get pending (unsubmitted) transactions
  Future<List<QueuedTransaction>> getPendingTransactions() async {
    try {
      final queue = await getQueue();
      return queue.where((t) => !t.isSubmitted).toList();
    } catch (e) {
      print('❌ Error getting pending transactions: $e');
      return [];
    }
  }

  /// Mark transaction as submitted
  Future<void> markAsSubmitted(String transactionId) async {
    try {
      final queue = await getQueue();
      final index = queue.indexWhere((t) => t.id == transactionId);
      if (index != -1) {
        queue[index].isSubmitted = true;
        queue[index].submittedAt = DateTime.now();

        final queueJson = queue.map((t) => jsonEncode(t.toJson())).toList();
        await _prefs.setStringList(_queueKey, queueJson);

        print('✅ Transaction marked as submitted: $transactionId');
      }
    } catch (e) {
      print('❌ Error marking transaction submitted: $e');
      rethrow;
    }
  }

  /// Clear submitted transactions
  Future<void> clearSubmitted() async {
    try {
      final queue = await getQueue();
      final pending = queue.where((t) => !t.isSubmitted).toList();

      final queueJson = pending.map((t) => jsonEncode(t.toJson())).toList();
      await _prefs.setStringList(_queueKey, queueJson);

      print('✅ Cleared submitted transactions');
    } catch (e) {
      print('❌ Error clearing transactions: $e');
      rethrow;
    }
  }

  /// Clear all transactions
  Future<void> clearAll() async {
    try {
      await _prefs.remove(_queueKey);
      print('✅ Cleared all queued transactions');
    } catch (e) {
      print('❌ Error clearing all: $e');
      rethrow;
    }
  }

  /// Get queue statistics
  Future<Map<String, dynamic>> getStats() async {
    try {
      final queue = await getQueue();
      final pending = queue.where((t) => !t.isSubmitted).toList();
      final submitted = queue.where((t) => t.isSubmitted).toList();

      return {
        'total': queue.length,
        'pending': pending.length,
        'submitted': submitted.length,
        'totalAmount': queue
            .fold<double>(0, (sum, t) => sum + double.parse(t.amount)),
      };
    } catch (e) {
      print('❌ Error getting stats: $e');
      return {'total': 0, 'pending': 0, 'submitted': 0, 'totalAmount': 0};
    }
  }
}
