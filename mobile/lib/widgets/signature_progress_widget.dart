import 'package:flutter/material.dart';

class SignatureProgressWidget extends StatelessWidget {
  final int currentSignatures;
  final int requiredSignatures;
  final bool isSigned;

  const SignatureProgressWidget({
    required this.currentSignatures,
    required this.requiredSignatures,
    required this.isSigned,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final percentage = currentSignatures / requiredSignatures;
    final bothSigned = currentSignatures >= requiredSignatures;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue.shade50,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blue.shade200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                '⚛️ Signatures Required',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              Text(
                '$currentSignatures/$requiredSignatures',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16,
                  color: bothSigned ? Colors.green : Colors.orange,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: percentage,
              minHeight: 8,
            ),
          ),
        ],
      ),
    );
  }
}
