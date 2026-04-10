import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class OfflineStatusWidget extends StatefulWidget {
  const OfflineStatusWidget({Key? key}) : super(key: key);

  @override
  State<OfflineStatusWidget> createState() => _OfflineStatusWidgetState();
}

class _OfflineStatusWidgetState extends State<OfflineStatusWidget> {
  bool _isOnline = true;

  @override
  void initState() {
    super.initState();
    // Check connectivity on init
    _checkConnectivity();
  }

  void _checkConnectivity() {
    // TODO: Integrate connectivity_plus when needed
    // For demo: just show the widget as if offline
    setState(() {
      _isOnline = false; // Show as offline for demo
    });
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: _isOnline
            ? Colors.green.withOpacity(0.1)
            : Colors.orange.withOpacity(0.1),
        border: Border(
          bottom: BorderSide(
            color: _isOnline ? Colors.green : Colors.orange,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            _isOnline ? Icons.wifi : Icons.wifi_off,
            color: _isOnline ? Colors.green : Colors.orange,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _isOnline ? 'ONLINE' : 'OFFLINE MODE ✓',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: _isOnline ? Colors.green : Colors.orange,
                    fontSize: 12,
                  ),
                ),
                Text(
                  _isOnline
                      ? 'Ready to submit payments'
                      : 'Payments can be signed without internet',
                  style: const TextStyle(
                    fontSize: 11,
                    color: AppColors.lightGrey,
                  ),
                ),
              ],
            ),
          ),
          if (!_isOnline)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green.withOpacity(0.2),
                borderRadius: BorderRadius.circular(4),
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.check_circle, color: Colors.green, size: 14),
                  SizedBox(width: 4),
                  Text(
                    'Feature',
                    style: TextStyle(
                      color: Colors.green,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
