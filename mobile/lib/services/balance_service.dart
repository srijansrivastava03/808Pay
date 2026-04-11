import 'package:http/http.dart' as http;
import 'dart:convert';

/// Balance Service Callback for UI updates
typedef BalanceUpdateCallback = void Function(double newBalance);

/// Balance Service
/// Handles user balance checking and validation
class BalanceService {
  static const String baseUrl = 'http://localhost:3000/api';
  
  /// Listeners for balance changes
  static final List<BalanceUpdateCallback> _listeners = [];
  
  /// Current cached balance for demo
  static double _demoBalance = 6850.00;

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
        final balance = (data['balance'] ?? 1000).toDouble();
        _demoBalance = balance;
        return balance;
      }

      // Default balance for testing
      return _demoBalance;
    } catch (e) {
      print('❌ Balance check failed: $e');
      // Default balance if offline/error
      return _demoBalance;
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

  // ==================== NEW: Balance Update Methods ====================

  /// Get current demo balance (for UI display)
  static double getDemoBalance() {
    return _demoBalance;
  }

  /// Update balance after outgoing payment (subtract amount)
  static Future<void> updateBalanceAfterPayment(double amount) async {
    _demoBalance -= amount;
    if (_demoBalance < 0) _demoBalance = 0;
    print('💰 Balance updated after payment: ₹${_demoBalance.toStringAsFixed(2)}');
    _notifyListeners(_demoBalance);
  }

  /// Update balance after receiving payment (add amount)
  static Future<void> updateBalanceAfterReceiving(double amount) async {
    _demoBalance += amount;
    print('💰 Balance updated after receiving: ₹${_demoBalance.toStringAsFixed(2)}');
    _notifyListeners(_demoBalance);
  }

  /// Set balance directly
  static Future<void> setBalance(double amount) async {
    _demoBalance = amount;
    print('💰 Balance set to: ₹${_demoBalance.toStringAsFixed(2)}');
    _notifyListeners(_demoBalance);
  }

  /// Subscribe to balance changes
  static void addListener(BalanceUpdateCallback callback) {
    _listeners.add(callback);
  }

  /// Unsubscribe from balance changes
  static void removeListener(BalanceUpdateCallback callback) {
    _listeners.remove(callback);
  }

  /// Notify all listeners of balance change
  static void _notifyListeners(double newBalance) {
    for (var listener in _listeners) {
      listener(newBalance);
    }
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
