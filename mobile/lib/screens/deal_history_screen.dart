import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class DealHistoryScreen extends StatelessWidget {
  const DealHistoryScreen({Key? key}) : super(key: key);

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
          'Deal History',
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
                  // - Deal list/history
                  // - Deal status indicators
                  // - Deal details view
                  Center(
                    child: Text(
                      'Deal History Screen\n(Atomic Settlement)',
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
