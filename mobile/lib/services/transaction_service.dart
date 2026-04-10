import 'package:uuid/uuid.dart';

class TransactionService {
  static const uuid = Uuid();

  /// Generate a unique transaction ID
  static String generateTransactionId() {
    return uuid.v4();
  }

  /// Create transaction data for signing
  static Map<String, dynamic> createTransactionData({
    required double amount,
    required String recipientAddress,
    required String senderAddress,
  }) {
    return {
      'transactionId': generateTransactionId(),
      'timestamp': DateTime.now().toIso8601String(),
      'amount': amount,
      'recipientAddress': recipientAddress,
      'senderAddress': senderAddress,
    };
  }

  /// Validate transaction data
  static bool validateTransactionData(Map<String, dynamic> data) {
    return data.containsKey('amount') &&
        data.containsKey('recipientAddress') &&
        data.containsKey('senderAddress') &&
        data['amount'] > 0;
  }

  /// Format transaction for QR code
  static String formatTransactionForQR({
    required double amount,
    required String recipientAddress,
  }) {
    return 'ALGO_PAY:$recipientAddress:$amount';
  }

  /// Parse transaction from QR code
  static Map<String, dynamic>? parseTransactionFromQR(String qrData) {
    try {
      if (!qrData.startsWith('ALGO_PAY:')) {
        return null;
      }
      final parts = qrData.substring(9).split(':');
      if (parts.length != 2) {
        return null;
      }
      return {
        'recipientAddress': parts[0],
        'amount': double.parse(parts[1]),
      };
    } catch (e) {
      return null;
    }
  }

  /// Calculate payment splits (90/5/5)
  static Map<String, double> calculateSplits(double amount) {
    return {
      'merchant': amount * 0.9,
      'tax': amount * 0.05,
      'loyalty': amount * 0.05,
    };
  }

  /// Check if transaction is pending
  static bool isTransactionPending(Map<String, dynamic> transaction) {
    return transaction['status'] == 'pending';
  }

  /// Check if transaction is completed
  static bool isTransactionCompleted(Map<String, dynamic> transaction) {
    return transaction['status'] == 'completed';
  }

  /// Check if transaction failed
  static bool isTransactionFailed(Map<String, dynamic> transaction) {
    return transaction['status'] == 'failed';
  }
}
