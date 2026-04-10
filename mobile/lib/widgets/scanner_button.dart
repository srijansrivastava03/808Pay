import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScannerButton extends StatefulWidget {
  final VoidCallback onPressed;

  const ScannerButton({
    Key? key,
    required this.onPressed,
  }) : super(key: key);

  @override
  State<ScannerButton> createState() => _ScannerButtonState();
}

class _ScannerButtonState extends State<ScannerButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return MouseRegion(
      onEnter: (_) => setState(() => _isPressed = true),
      onExit: (_) => setState(() => _isPressed = false),
      child: GestureDetector(
        onTapDown: (_) => setState(() => _isPressed = true),
        onTapUp: (_) => setState(() => _isPressed = false),
        onTapCancel: () => setState(() => _isPressed = false),
        onTap: widget.onPressed,
        child: Container(
          width: 280,
          height: 280,
          decoration: BoxDecoration(
            color: _isPressed ? AppColors.red : AppColors.grey,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(
              color: AppColors.red,
              width: 2,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: AppColors.red.withOpacity(0.6),
                      blurRadius: 20,
                      spreadRadius: 4,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.red.withOpacity(0.3),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.qr_code_2,
                size: 80,
                color: _isPressed ? AppColors.white : AppColors.red,
              ),
              const SizedBox(height: 16),
              Text(
                'Scan to Pay',
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: _isPressed ? AppColors.white : AppColors.white,
                  fontSize: 20,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Tap to scan QR',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: _isPressed ? AppColors.white : AppColors.lightGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
