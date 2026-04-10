import 'package:flutter/material.dart';

class HistoryScreen extends StatefulWidget {
  const HistoryScreen({Key? key}) : super(key: key);

  @override
  State<HistoryScreen> createState() => _HistoryScreenState();
}

class _HistoryScreenState extends State<HistoryScreen> {
  // TODO: Fetch transactions from API
  final List<Map<String, String>> transactions = [];

  @override
  void initState() {
    super.initState();
    _fetchTransactionHistory();
  }

  Future<void> _fetchTransactionHistory() async {
    // TODO: Call ApiService.getTransactionHistory()
    // Parse and display transactions
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Transaction History'),
        centerTitle: true,
      ),
      body: transactions.isEmpty
          ? const Center(
              child: Text('No transactions yet'),
            )
          : ListView.builder(
              padding: const EdgeInsets.all(8),
              itemCount: transactions.length,
              itemBuilder: (context, index) {
                final tx = transactions[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 0),
                  child: ListTile(
                    title: Text(tx['recipient'] ?? ''),
                    subtitle: Text('Amount: ${tx['amount']} ALGO'),
                    trailing: Text(
                      tx['status'] ?? '',
                      style: TextStyle(
                        color: tx['status'] == 'completed'
                            ? Colors.green
                            : Colors.orange,
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }
}
