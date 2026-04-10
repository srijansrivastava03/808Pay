import 'dart:convert';
import 'package:cryptography/cryptography.dart';

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
      rethrow;
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
}
