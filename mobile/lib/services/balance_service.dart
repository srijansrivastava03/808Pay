import 'package:http/http.dart' as http;
import 'dart:convert';

/// Balance Service
/// Handles user balance checking and validation
class BalanceService {
  static const String baseUrl = 'http://localhost:3000/api';

  /// Get user's current balance from backend
  /// In production: Queries Algorand blockchain
  /// For demo: Returns from backend ledger
  static Future<double> getUserBalance(String publicKey) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/balance/$publicKey'),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return (data['balance'] ?? 1000).toDouble();
      }

      // Default balance for testing
      return 1000.0;
    } catch (e) {
      print('❌ Balance check failed: $e');
      // Default balance if offline/error
      return 1000.0;
    }
  }

  /// Validate if user has sufficient balance for transaction
  /// Returns: true if balance >= amount, false otherwise
  static Future<bool> hasSufficientBalance(
    String publicKey,
    double amount,
  ) async {
    try {
      final balance = await getUserBalance(publicKey);
      return balance >= amount;
    } catch (e) {
      print('❌ Balance validation failed: $e');
      return false;
    }
  }

  /// Get balance with formatted message
  static Future<String> getFormattedBalance(String publicKey) async {
    try {
      final balance = await getUserBalance(publicKey);
      return '₹${balance.toStringAsFixed(2)}';
    } catch (e) {
      return 'N/A';
    }
  }

  /// Check balance and return validation result
  /// Returns: {valid: true/false, message: "...", balance: amount}
  static Future<Map<String, dynamic>> validateBalance(
    String publicKey,
    double amount,
  ) async {
    try {
      final balance = await getUserBalance(publicKey);

      if (balance < amount) {
        return {
          'valid': false,
          'message':
              '❌ Insufficient balance. Have: ₹${balance.toStringAsFixed(2)}, Need: ₹${amount.toStringAsFixed(2)}',
          'balance': balance,
          'required': amount,
          'shortfall': amount - balance,
        };
      }

      return {
        'valid': true,
        'message': '✅ Sufficient balance available',
        'balance': balance,
        'required': amount,
        'remaining': balance - amount,
      };
    } catch (e) {
      return {
        'valid': false,
        'message': '❌ Balance check failed: $e',
        'error': true,
      };
    }
  }

  /// Cache balance locally (for offline demo)
  static Map<String, double> _balanceCache = {};

  /// Get cached balance
  static double? getCachedBalance(String publicKey) {
    return _balanceCache[publicKey];
  }

  /// Cache balance locally
  static void cacheBalance(String publicKey, double amount) {
    _balanceCache[publicKey] = amount;
  }

  /// Clear cache
  static void clearCache() {
    _balanceCache.clear();
  }

  /// Get balance summary for UI display
  static Future<String> getBalanceSummary(String publicKey) async {
    final balance = await getUserBalance(publicKey);

    if (balance < 100) {
      return '⚠️ Low balance: ₹${balance.toStringAsFixed(2)}';
    } else if (balance < 500) {
      return '📊 Balance: ₹${balance.toStringAsFixed(2)}';
    } else {
      return '✅ Balance: ₹${balance.toStringAsFixed(2)}';
    }
  }
}
