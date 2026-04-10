import 'package:flutter/material.dart';

class PaymentCard extends StatelessWidget {
  final double amount;
  final String recipientAddress;
  final VoidCallback onTap;
  final VoidCallback? onEdit;
  final VoidCallback? onDelete;

  const PaymentCard({
    Key? key,
    required this.amount,
    required this.recipientAddress,
    required this.onTap,
    this.onEdit,
    this.onDelete,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 4,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    '$amount ALGO',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  if (onEdit != null || onDelete != null)
                    PopupMenuButton(
                      itemBuilder: (BuildContext context) => [
                        if (onEdit != null)
                          PopupMenuItem(
                            child: const Text('Edit'),
                            onTap: onEdit,
                          ),
                        if (onDelete != null)
                          PopupMenuItem(
                            child: const Text('Delete'),
                            onTap: onDelete,
                          ),
                      ],
                    ),
                ],
              ),
              const SizedBox(height: 12),
              Text(
                'To: ${recipientAddress.substring(0, 10)}...',
                style: const TextStyle(
                  fontSize: 12,
                  color: Colors.grey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
