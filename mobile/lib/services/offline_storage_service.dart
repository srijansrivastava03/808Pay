import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

/// Service to manage offline transaction storage
/// Stores signed transactions locally until internet connection available
class OfflineStorageService {
  static const String _pendingTransactionsKey = 'pending_transactions';
  static const String _keyPairKey = 'user_keypair';

  /// Save a signed transaction for later submission
  static Future<void> savePendingTransaction(
    Map<String, dynamic> transaction,
  ) async {
    final prefs = await SharedPreferences.getInstance();
    
    // Get existing pending transactions
    final existingJson = prefs.getString(_pendingTransactionsKey) ?? '[]';
    final transactions = List<Map<String, dynamic>>.from(
      jsonDecode(existingJson) as List,
    );
    
    // Add new transaction with offline timestamp
    final txWithTimestamp = {
      ...transaction,
      'offlineSignedAt': DateTime.now().toIso8601String(),
      'submitted': false,
    };
    
    transactions.add(txWithTimestamp);
    
    // Save back to storage
    await prefs.setString(_pendingTransactionsKey, jsonEncode(transactions));
  }

  /// Get all pending (not yet submitted) transactions
  static Future<List<Map<String, dynamic>>> getPendingTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_pendingTransactionsKey) ?? '[]';
    
    final transactions = List<Map<String, dynamic>>.from(
      jsonDecode(json) as List,
    );
    
    // Filter for pending (not submitted)
    return transactions.where((tx) => tx['submitted'] != true).toList();
  }

  /// Mark a transaction as submitted
  static Future<void> markTransactionSubmitted(String transactionId) async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_pendingTransactionsKey) ?? '[]';
    
    final transactions = List<Map<String, dynamic>>.from(
      jsonDecode(json) as List,
    );
    
    // Mark as submitted
    for (var tx in transactions) {
      if (tx['id'] == transactionId) {
        tx['submitted'] = true;
        tx['submittedAt'] = DateTime.now().toIso8601String();
        break;
      }
    }
    
    await prefs.setString(_pendingTransactionsKey, jsonEncode(transactions));
  }

  /// Save user's key pair locally (for future signing)
  /// WARNING: This is sensitive data - ensure encrypted storage in production!
  static Future<void> saveKeyPair({
    required String seed,
    required String publicKey,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    
    final keyPair = {
      'seed': seed,
      'publicKey': publicKey,
      'createdAt': DateTime.now().toIso8601String(),
    };
    
    await prefs.setString(_keyPairKey, jsonEncode(keyPair));
  }

  /// Get saved key pair
  static Future<Map<String, String>?> getKeyPair() async {
    final prefs = await SharedPreferences.getInstance();
    final json = prefs.getString(_keyPairKey);
    
    if (json == null) return null;
    
    final data = jsonDecode(json) as Map<String, dynamic>;
    return {
      'seed': data['seed'] as String,
      'publicKey': data['publicKey'] as String,
    };
  }

  /// Clear all pending transactions
  static Future<void> clearPendingTransactions() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingTransactionsKey);
  }

  /// Clear all stored data (key pair, pending transactions)
  static Future<void> clearAll() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_pendingTransactionsKey);
    await prefs.remove(_keyPairKey);
  }

  /// Get offline transaction count
  static Future<int> getPendingTransactionCount() async {
    final pending = await getPendingTransactions();
    return pending.length;
  }
}
