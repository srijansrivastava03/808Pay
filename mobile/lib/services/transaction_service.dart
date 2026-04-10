import 'dart:convert';
import 'package:cryptography/cryptography.dart';
import 'crypto_service.dart';
import 'tax_service.dart';

class TransactionService {
  // Create unsigned transaction data
  Future<String> createUnsignedTransaction({
    required String sender,
    required String recipient,
    required double amount,
    required String merchantName,
  }) async {
    try {
      final transactionData = {
        'sender': sender,
        'recipient': recipient,
        'amount': amount,
        'merchantName': merchantName,
        'timestamp': DateTime.now().toIso8601String(),
      };

      final jsonString = jsonEncode(transactionData);
      return jsonString;
    } catch (e) {
      print('Error creating unsigned transaction: $e');
      rethrow;
    }
  }

  // Hash transaction data
  Future<List<int>> hashTransactionData(String data) async {
    try {
      final algorithm = Sha256();
      final bytes = utf8.encode(data);
      final digest = await algorithm.hash(bytes);
      return digest.bytes;
    } catch (e) {
      print('Error hashing transaction data: $e');
      rethrow;
    }
  }

  // Format data for signing
  Future<String> formatDataForSigning(String transactionData) async {
    try {
      // Hash the transaction data
      final hash = await hashTransactionData(transactionData);
      // Convert to hex string
      return hash.map((e) => e.toRadixString(16).padLeft(2, '0')).join();
    } catch (e) {
      print('Error formatting data for signing: $e');
      rethrow;
    }
  }

  // Verify signature (for testing purposes)
  Future<bool> verifySignature({
    required String data,
    required String signature,
    required String publicKey,
  }) async {
    try {
      // TODO: Implement signature verification
      print('Verifying signature...');
      return true;
    } catch (e) {
      print('Error verifying signature: $e');
      return false;
    }
  }

  // Create transaction for backend submission
  Future<Map<String, dynamic>> createBackendTransaction({
    required String data,
    required String signature,
    required String publicKey,
  }) async {
    try {
      return {
        'data': data,
        'signature': signature,
        'publicKey': publicKey,
      };
    } catch (e) {
      print('Error creating backend transaction: $e');
      rethrow;
    }
  }

  // ==================== NEW: OFFLINE PAYMENT METHODS ====================

  /// Create transaction data for offline signing (including category for tax)
  static Map<String, dynamic> createTransactionData({
    required double amount,
    required String recipientAddress,
    required String senderAddress,
    required String category,
  }) {
    return {
      'amount': amount,
      'recipientAddress': recipientAddress,
      'senderAddress': senderAddress,
      'category': category,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Sign transaction OFFLINE (no internet needed!)
  static Future<Map<String, dynamic>> signTransactionOffline({
    required Map<String, dynamic> transactionData,
    required String seedHex,
    required String publicKeyHex,
  }) async {
    try {
      // Sign using CryptoService (pure math, no internet!)
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
      print('Error signing transaction: $e');
      rethrow;
    }
  }

  /// Calculate payment splits with dynamic tax
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

  /// Format transaction for QR code (includes signature!)
  static String formatTransactionForQR({
    required double amount,
    required String recipientAddress,
    required String signature,
    required String publicKey,
    required String category,
  }) {
    final qrData = {
      'type': 'ALGO_PAY',
      'version': '1.0',
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
}
