import 'package:uuid/uuid.dart';
import 'crypto_service.dart';
import 'tax_service.dart';
import 'dart:convert';

class TransactionService {
  static const uuid = Uuid();

  /// Generate a unique transaction ID
  static String generateTransactionId() {
    return uuid.v4();
  }

  /// Create transaction data for offline signing
  static Map<String, dynamic> createTransactionData({
    required double amount,
    required String recipientAddress,
    required String senderAddress,
    required String category,
  }) {
    return {
      'transactionId': generateTransactionId(),
      'timestamp': DateTime.now().toIso8601String(),
      'amount': amount,
      'recipientAddress': recipientAddress,
      'senderAddress': senderAddress,
      'category': category,
    };
  }

  /// Sign transaction OFFLINE (no internet needed!)
  /// Returns signed transaction with signature and public key
  static Future<Map<String, dynamic>> signTransactionOffline({
    required Map<String, dynamic> transactionData,
    required String seedHex,
    required String publicKeyHex,
  }) async {
    try {
      // Sign the transaction (pure cryptographic math, NO INTERNET!)
      final signature = CryptoService.signTransaction(
        transactionData: transactionData,
        seedHex: seedHex,
      );

      return {
        ...transactionData,
        'signature': signature,
        'publicKey': publicKeyHex,
        'isOfflineSigned': true,
        'offlineSignedAt': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to sign transaction: $e');
    }
  }

  /// Validate transaction data
  static bool validateTransactionData(Map<String, dynamic> data) {
    return data.containsKey('amount') &&
        data.containsKey('recipientAddress') &&
        data.containsKey('senderAddress') &&
        data.containsKey('category') &&
        (data['amount'] as num) > 0;
  }

  /// Format transaction for QR code (includes signature!)
  static String formatTransactionForQR({
    required String transactionId,
    required double amount,
    required String recipientAddress,
    required String signature,
    required String publicKey,
    required String category,
  }) {
    final qrData = {
      'type': 'ALGO_PAY',
      'version': '1.0',
      'transactionId': transactionId,
      'amount': amount,
      'recipient': recipientAddress,
      'category': category,
      'signature': signature,
      'publicKey': publicKey,
      'timestamp': DateTime.now().toIso8601String(),
    };
    return jsonEncode(qrData);
  }

  /// Parse transaction from QR code
  static Map<String, dynamic>? parseTransactionFromQR(String qrData) {
    try {
      final data = jsonDecode(qrData) as Map<String, dynamic>;
      
      if (data['type'] != 'ALGO_PAY') {
        return null;
      }
      
      return {
        'transactionId': data['transactionId'],
        'amount': (data['amount'] as num).toDouble(),
        'recipientAddress': data['recipient'],
        'category': data['category'],
        'signature': data['signature'],
        'publicKey': data['publicKey'],
      };
    } catch (e) {
      return null;
    }
  }

  /// Calculate payment splits and tax for amount (using category-based GST)
  static Map<String, double> calculateSplitsWithTax({
    required double amount,
    required String category,
  }) {
    final breakdown = TaxCalculationService.calculateBreakdown(
      amount: amount,
      category: category,
    );
    
    return {
      'total': breakdown['total']!,
      'merchant': breakdown['merchant']!,
      'tax': breakdown['tax']!,
      'loyalty': breakdown['loyalty']!,
      'gstRate': breakdown['gstRate']!,
    };
  }

  /// Check if transaction is pending
  static bool isTransactionPending(Map<String, dynamic> transaction) {
    return transaction['status'] == 'pending';
  }

  /// Check if transaction is offline signed
  static bool isTransactionOfflineSigned(Map<String, dynamic> transaction) {
    return transaction['isOfflineSigned'] == true;
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
