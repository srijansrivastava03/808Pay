class Transaction {
  final String id;
  final String senderAddress;
  final String recipientAddress;
  final double amount;
  final String category;           // NEW: tax category (food, electronics, etc.)
  final String status;              // pending, offlineSigned, submitted, completed, failed
  final DateTime timestamp;
  final Map<String, double>? splits; // merchant, tax, loyalty
  
  // NEW: Offline signing fields
  final String? signature;          // Hex-encoded Ed25519 signature
  final String? publicKey;          // Public key that signed this
  final DateTime? offlineSignedAt;  // When it was signed offline
  final String? qrCode;             // QR code data with signature
  final bool isOfflineSigned;       // Whether signed without internet

  Transaction({
    required this.id,
    required this.senderAddress,
    required this.recipientAddress,
    required this.amount,
    required this.category,
    required this.status,
    required this.timestamp,
    this.splits,
    this.signature,
    this.publicKey,
    this.offlineSignedAt,
    this.qrCode,
    this.isOfflineSigned = false,
  });

  factory Transaction.fromJson(Map<String, dynamic> json) {
    return Transaction(
      id: json['id'] ?? '',
      senderAddress: json['senderAddress'] ?? '',
      recipientAddress: json['recipientAddress'] ?? '',
      amount: (json['amount'] ?? 0).toDouble(),
      category: json['category'] ?? 'services',
      status: json['status'] ?? 'pending',
      timestamp: DateTime.parse(json['timestamp'] ?? DateTime.now().toIso8601String()),
      splits: json['splits'] != null ? Map<String, double>.from(json['splits']) : null,
      signature: json['signature'] as String?,
      publicKey: json['publicKey'] as String?,
      offlineSignedAt: json['offlineSignedAt'] != null 
          ? DateTime.parse(json['offlineSignedAt'] as String)
          : null,
      qrCode: json['qrCode'] as String?,
      isOfflineSigned: json['isOfflineSigned'] ?? false,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderAddress': senderAddress,
      'recipientAddress': recipientAddress,
      'amount': amount,
      'category': category,
      'status': status,
      'timestamp': timestamp.toIso8601String(),
      'splits': splits,
      'signature': signature,
      'publicKey': publicKey,
      'offlineSignedAt': offlineSignedAt?.toIso8601String(),
      'qrCode': qrCode,
      'isOfflineSigned': isOfflineSigned,
    };
  }

  bool get isPending => status == 'pending';
  bool get isOfflineSignedStatus => status == 'offlineSigned';
  bool get isSubmitted => status == 'submitted';
  bool get isCompleted => status == 'completed';
  bool get isFailed => status == 'failed';
}
