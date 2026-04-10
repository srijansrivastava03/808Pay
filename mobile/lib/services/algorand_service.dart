import 'package:http/http.dart' as http;
import 'dart:convert';

class AlgorandService {
  static const String baseUrl = 'http://localhost:3000/api/algorand';

  /// Get account balance on Algorand
  static Future<Map<String, dynamic>> getBalance(String address) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/balance/$address'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get balance: ${response.body}');
      }
    } catch (e) {
      print('❌ Balance error: $e');
      rethrow;
    }
  }

  /// Get transaction details from blockchain
  static Future<Map<String, dynamic>> getTransaction(String txnId) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/transaction/$txnId'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Failed to get transaction: ${response.body}');
      }
    } catch (e) {
      print('❌ Transaction error: $e');
      rethrow;
    }
  }

  /// Get transaction history for address
  static Future<List<dynamic>> getHistory(
    String address, {
    int limit = 10,
  }) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/history/$address?limit=$limit'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return data['transactions'] ?? [];
      } else {
        throw Exception('Failed to get history: ${response.body}');
      }
    } catch (e) {
      print('❌ History error: $e');
      rethrow;
    }
  }

  /// Check Algorand network health
  static Future<Map<String, dynamic>> checkHealth() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/health'),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        throw Exception('Network unhealthy');
      }
    } catch (e) {
      print('❌ Health check error: $e');
      return {'status': 'error', 'error': e.toString()};
    }
  }

  /// Get explorer URL for transaction
  static String getExplorerUrl(String txnId, {String network = 'testnet'}) {
    if (network == 'mainnet') {
      return 'https://algoexplorer.io/tx/$txnId';
    }
    return 'https://testnet.algoexplorer.io/tx/$txnId';
  }

  /// Get explorer URL for account
  static String getAccountExplorerUrl(String address, {String network = 'testnet'}) {
    if (network == 'mainnet') {
      return 'https://algoexplorer.io/address/$address';
    }
    return 'https://testnet.algoexplorer.io/address/$address';
  }

  /// Format microAlgos to ALGO
  static String formatAlgo(int microAlgos) {
    final algos = microAlgos / 1000000;
    return algos.toStringAsFixed(6).replaceAll(RegExp(r'0+$'), '').replaceAll(RegExp(r'\.$'), '');
  }

  /// Format balance display
  static String getFormattedBalance(int microAlgos) {
    final algos = microAlgos / 1000000;
    if (algos >= 1000) {
      return '${(algos / 1000).toStringAsFixed(2)}K Ⓐ';
    }
    return '${algos.toStringAsFixed(2)} Ⓐ';
  }

  /// Get status indicator (emoji based on balance)
  static String getBalanceStatus(int microAlgos) {
    final algos = microAlgos / 1000000;
    if (algos < 1) {
      return '⚠️ Low'; // Less than 1 ALGO
    } else if (algos < 10) {
      return '📊 Normal'; // 1-10 ALGO
    } else {
      return '✅ High'; // 10+ ALGO
    }
  }
}
