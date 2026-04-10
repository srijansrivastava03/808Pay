import 'package:http/http.dart' as http;
import 'dart:convert';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  /// Create a new payment transaction
  static Future<Map<String, dynamic>> createPayment({
    required double amount,
    required String recipientAddress,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions/settle'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'amount': amount,
          'recipientAddress': recipientAddress,
          // TODO: Add transaction data and signature
        }),
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to create payment: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get transaction status
  static Future<Map<String, dynamic>> getTransactionStatus(String txId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$txId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get transaction status: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Get all transactions
  static Future<List<Map<String, dynamic>>> getTransactionHistory() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        } else if (data is Map && data['transactions'] != null) {
          return List<Map<String, dynamic>>.from(data['transactions']);
        }
        return [];
      } else {
        throw Exception('Failed to get transaction history: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }

  /// Settle a transaction
  static Future<Map<String, dynamic>> settleTransaction({
    required String transactionData,
    required String signature,
    required String publicKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions/settle'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'transactionData': transactionData,
          'signature': signature,
          'publicKey': publicKey,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to settle transaction: ${response.statusCode}');
      }
    } catch (e) {
      rethrow;
    }
  }
}
