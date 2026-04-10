import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class ScanSignScreen extends StatelessWidget {
  const ScanSignScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.white, size: 24),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Scan & Sign',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Header spacing
            const SizedBox(height: 24),

            // Main content area (placeholder for now)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  // Future sections will be added here
                  // - QR scanner
                  // - Deal details display
                  // - Signature confirmation
                  // - Sign button
                  Center(
                    child: Text(
                      'Scan & Sign Screen\n(Atomic Settlement)',
                      style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        color: AppColors.lightGrey,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
