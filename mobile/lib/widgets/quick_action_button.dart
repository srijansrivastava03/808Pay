import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class QuickActionButton extends StatefulWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final double height;
  final bool isMainAction;

  const QuickActionButton({
    Key? key,
    required this.icon,
    required this.label,
    required this.onTap,
    this.height = 100,
    this.isMainAction = false,
  }) : super(key: key);

  @override
  State<QuickActionButton> createState() => _QuickActionButtonState();
}

class _QuickActionButtonState extends State<QuickActionButton> {
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      onTap: widget.onTap,
      child: MouseRegion(
        onEnter: (_) => setState(() => _isPressed = true),
        onExit: (_) => setState(() => _isPressed = false),
        child: Container(
          height: widget.height,
          decoration: BoxDecoration(
            color: AppColors.grey,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: _isPressed ? AppColors.red : AppColors.red.withOpacity(0.4),
              width: _isPressed ? 2 : 2,
            ),
            boxShadow: _isPressed
                ? [
                    BoxShadow(
                      color: AppColors.red.withOpacity(0.5),
                      blurRadius: 12,
                      spreadRadius: 2,
                    ),
                  ]
                : [
                    BoxShadow(
                      color: AppColors.red.withOpacity(0.2),
                      blurRadius: 8,
                      spreadRadius: 1,
                    ),
                  ],
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                widget.icon,
                size: widget.isMainAction ? 48 : 32,
                color: _isPressed ? AppColors.red : AppColors.white,
              ),
              const SizedBox(height: 12),
              Text(
                widget.label,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: _isPressed ? AppColors.red : AppColors.white,
                  fontWeight: _isPressed ? FontWeight.bold : FontWeight.w600,
                  fontSize: widget.isMainAction ? 16 : 13,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
