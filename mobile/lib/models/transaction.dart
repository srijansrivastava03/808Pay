class Transaction {
  final String id;
  final String sender;
  final String recipient;
  final double amount;
  final String status; // pending, settled, failed
  final DateTime createdAt;
  final DateTime? settledAt;
  final TransactionSplits? splits;

  Transaction({
    required this.id,
    required this.sender,
    required this.recipient,
    required this.amount,
    required this.status,
    required this.createdAt,
    this.settledAt,
    this.splits,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      sender: json['sender'] ?? '',
      recipient: json['recipient'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      status: json['status'] ?? 'pending',
      createdAt: DateTime.parse(json['createdAt'] ?? DateTime.now().toIso8601String()),
      settledAt: json['settledAt'] != null ? DateTime.parse(json['settledAt']) : null,
      splits: json['splits'] != null ? TransactionSplits.fromJson(json['splits']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'sender': sender,
      'recipient': recipient,
      'amount': amount,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'settledAt': settledAt?.toIso8601String(),
      'splits': splits?.toJson(),
    };
  }
}

class TransactionSplits {
  final double merchant;
  final double tax;
  final double loyalty;

  TransactionSplits({
    required this.merchant,
    required this.tax,
    required this.loyalty,
  });

  factory TransactionSplits.fromJson(Map<String, dynamic> json) {
    return TransactionSplits(
      merchant: (json['merchant'] ?? 0).toDouble(),
      tax: (json['tax'] ?? 0).toDouble(),
      loyalty: (json['loyalty'] ?? 0).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'merchant': merchant,
      'tax': tax,
      'loyalty': loyalty,
    };
  }
}
