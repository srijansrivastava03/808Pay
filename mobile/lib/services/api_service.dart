import 'package:http/http.dart' as http;
import 'dart:convert';
import '../models/transaction.dart';

class ApiService {
  static const String baseUrl = 'http://localhost:3000/api';

  // Health check
  Future<bool> healthCheck() async {
    try {
      final response = await http.get(
        Uri.parse('http://localhost:3000/health'),
      ).timeout(const Duration(seconds: 5));

      return response.statusCode == 200;
    } catch (e) {
      print('Health check failed: $e');
      return false;
    }
  }

  // Settle payment with signature
  Future<Map<String, dynamic>> settlePayment({
    required String data,
    required String signature,
    required String publicKey,
  }) async {
    try {
      final response = await http.post(
        Uri.parse('$baseUrl/transactions/settle'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'data': data,
          'signature': signature,
          'publicKey': publicKey,
        }),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to settle payment: ${response.statusCode}');
      }
    } catch (e) {
      print('Error settling payment: $e');
      rethrow;
    }
  }

  // Get transaction by ID
  Future<Transaction> getTransaction(String id) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions/$id'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        return Transaction.fromJson(jsonDecode(response.body));
      } else {
        throw Exception('Failed to fetch transaction: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching transaction: $e');
      rethrow;
    }
  }

  // List all transactions
  Future<List<Transaction>> listTransactions() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transactions'),
      ).timeout(const Duration(seconds: 5));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final List<dynamic> transactions = data['transactions'] ?? [];
        return transactions
            .map((t) => Transaction.fromJson(t as Map<String, dynamic>))
            .toList();
      } else {
        throw Exception('Failed to fetch transactions: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching transactions: $e');
      rethrow;
    }
  }
}
