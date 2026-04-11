import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Confirmation circle overlay for NFC transfers
class NFCConfirmationOverlay extends StatefulWidget {
  final String message;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Duration displayDuration;

  const NFCConfirmationOverlay({
    Key? key,
    this.message = 'Transfer Detected',
    this.onConfirm,
    this.onCancel,
    this.displayDuration = const Duration(seconds: 5),
  }) : super(key: key);

  @override
  State<NFCConfirmationOverlay> createState() => _NFCConfirmationOverlayState();
}

class _NFCConfirmationOverlayState extends State<NFCConfirmationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    // Animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    // Scale animation (grows from 0 to 1)
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );

    // Fade animation
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeIn),
    );

    // Start animation
    _controller.forward();

    // Auto-close after duration
    Future.delayed(widget.displayDuration, () {
      if (mounted) {
        Navigator.of(context).pop();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Scaffold(
          backgroundColor: Colors.black.withOpacity(0.6),
          body: Center(
            child: ScaleTransition(
              scale: _scaleAnimation,
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: GestureDetector(
                  onTap: () {
                    widget.onConfirm?.call();
                    Navigator.pop(context, true);
                  },
                  child: Container(
                    width: 280,
                    height: 280,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          AppColors.red.withOpacity(0.9),
                          AppColors.red.withOpacity(0.7),
                        ],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.red.withOpacity(0.6),
                          blurRadius: 40,
                          spreadRadius: 10,
                        ),
                      ],
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Pulsing ring effect
                        ...List.generate(3, (index) {
                          return AnimatedBuilder(
                            animation: _controller,
                            builder: (context, child) {
                              final opacity =
                                  (1 - _controller.value) * 0.5;
                              final size = 280 + (_controller.value * 60);
                              return Container(
                                width: size,
                                height: size,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  border: Border.all(
                                    color: AppColors.red
                                        .withOpacity(opacity * 0.3),
                                    width: 2,
                                  ),
                                ),
                              );
                            },
                          );
                        }),
                        // Center content
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Checkmark icon
                            ScaleTransition(
                              scale: Tween<double>(begin: 0.8, end: 1.0)
                                  .animate(_controller),
                              child: const Icon(
                                Icons.check_circle,
                                color: AppColors.white,
                                size: 80,
                              ),
                            ),
                            const SizedBox(height: 16),
                            // Message
                            Text(
                              widget.message,
                              textAlign: TextAlign.center,
                              style:
                                  const TextStyle(
                                    color: AppColors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w600,
                                    letterSpacing: 0.5,
                                  ),
                            ),
                            const SizedBox(height: 8),
                            // Sub-message
                            const Text(
                              'Tap to confirm',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: AppColors.lightGrey,
                                fontSize: 12,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Helper function to show NFC confirmation
Future<bool?> showNFCConfirmation({
  required BuildContext context,
  String message = 'Transfer Detected',
  Duration duration = const Duration(seconds: 5),
  VoidCallback? onConfirm,
}) {
  return showGeneralDialog<bool>(
    context: context,
    barrierDismissible: true,
    barrierLabel: 'NFC Confirmation',
    barrierColor: Colors.transparent,
    transitionDuration: const Duration(milliseconds: 300),
    pageBuilder: (context, animation, secondaryAnimation) {
      return NFCConfirmationOverlay(
        message: message,
        displayDuration: duration,
        onConfirm: onConfirm,
      );
    },
    transitionBuilder: (context, animation, secondaryAnimation, child) {
      return FadeTransition(opacity: animation, child: child);
    },
  );
}
