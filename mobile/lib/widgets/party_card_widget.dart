import 'package:flutter/material.dart';

class PartyCardWidget extends StatelessWidget {
  final String role;
  final String icon;
  final String address;
  final bool hasSigned;

  const PartyCardWidget({
    required this.role,
    required this.icon,
    required this.address,
    required this.hasSigned,
    Key? key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text(icon, style: const TextStyle(fontSize: 20)),
                    const SizedBox(width: 8),
                    Text(role, style: const TextStyle(fontWeight: FontWeight.bold)),
                  ],
                ),
                Icon(
                  hasSigned ? Icons.check_circle : Icons.pending,
                  color: hasSigned ? Colors.green : Colors.orange,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(
              address.length > 20 ? address.substring(0, 20) + '...' : address,
              style: const TextStyle(fontSize: 12, fontFamily: 'monospace'),
            ),
            const SizedBox(height: 12),
            Text(
              hasSigned ? '✅ SIGNED' : '⏳ PENDING',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: hasSigned ? Colors.green : Colors.orange,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
