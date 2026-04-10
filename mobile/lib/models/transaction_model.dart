class Transaction {
  final String id;
  final String senderAddress;
  final String recipientAddress;
  final double amount;
  final String status; // pending, completed, failed
  final DateTime timestamp;
  final Map<String, double>? splits; // merchant, tax, loyalty

  Transaction({
    required this.id,
    required this.senderAddress,
    required this.recipientAddress,
    required this.amount,
    required this.status,
    required this.timestamp,
    this.splits,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      senderAddress: json['senderAddress'] ?? '',
      recipientAddress: json['recipientAddress'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      splits: json['splits'] != null ? Map<String, double>.from(json['splits']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderAddress': senderAddress,
      'recipientAddress': recipientAddress,
      'amount': amount,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'splits': splits,
    };
  }

  bool get isPending => status == 'pending';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}
