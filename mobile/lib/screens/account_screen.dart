import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_theme.dart';

class AccountScreen extends StatefulWidget {
  const AccountScreen({Key? key}) : super(key: key);

  @override
  State<AccountScreen> createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  // Mock user data
  final String userName = "Suyash";
  final String walletAddress = "7ZZQF7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z7Z"; // Full address
  final double balance = 2450.00; // Mock balance
  
  // Helper to shorten wallet address
  String _shortenAddress(String address) {
    if (address.length <= 16) return address;
    return '${address.substring(0, 8)}...${address.substring(address.length - 8)}';
  }

  // Helper to copy address to clipboard
  void _copyToClipboard() {
    Clipboard.setData(ClipboardData(text: walletAddress));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('✓ Address copied to clipboard'),
        backgroundColor: Colors.green,
        duration: const Duration(seconds: 2),
        behavior: SnackBarBehavior.floating,
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // Helper to build option item
  Widget _buildOptionItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: AppColors.grey,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            // Icon (left)
            Icon(
              icon,
              color: AppColors.red,
              size: 24,
            ),
            const SizedBox(width: 16),
            // Title (center)
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            // Arrow (right)
            const Icon(
              Icons.arrow_forward_ios,
              color: AppColors.lightGrey,
              size: 16,
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.black,
      appBar: AppBar(
        backgroundColor: AppColors.black,
        elevation: 0,
        leading: GestureDetector(
          onTap: () => Navigator.of(context).pop(),
          child: const Icon(
            Icons.arrow_back,
            color: AppColors.lightGrey,
          ),
        ),
        title: const Text(
          'Account',
          style: TextStyle(
            color: AppColors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
          child: Column(
            children: [
            // ========== PROFILE CARD ==========
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Row(
                children: [
                  // Avatar
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColors.red.withOpacity(0.2),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppColors.red.withOpacity(0.5),
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.person,
                      color: AppColors.red,
                      size: 32,
                    ),
                  ),
                  const SizedBox(width: 16),
                  // User info
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          userName,
                          style: const TextStyle(
                            color: AppColors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 8),
                        // Wallet address with copy button
                        Row(
                          children: [
                            Expanded(
                              child: Text(
                                _shortenAddress(walletAddress),
                                style: TextStyle(
                                  color: AppColors.lightGrey,
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            const SizedBox(width: 8),
                            GestureDetector(
                              onTap: _copyToClipboard,
                              child: Icon(
                                Icons.content_copy,
                                color: AppColors.lightGrey.withOpacity(0.7),
                                size: 14,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            
            const SizedBox(height: 20),

            // Divider
            Divider(
              color: AppColors.lightGrey.withOpacity(0.15),
              height: 1,
              thickness: 1,
            ),

            const SizedBox(height: 20),

            // ========== BALANCE CARD ==========
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppColors.grey,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Balance',
                    style: TextStyle(
                      color: AppColors.lightGrey,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        '₹',
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.red,
                          fontSize: 28,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Text(
                        balance.toStringAsFixed(0),
                        style: Theme.of(context).textTheme.displayMedium?.copyWith(
                          color: AppColors.white,
                          fontSize: 36,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ========== ACCOUNT SECTION HEADER ==========
            Align(
              alignment: Alignment.centerLeft,
              child: Text(
                'Account Settings',
                style: TextStyle(
                  color: AppColors.lightGrey,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.5,
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ========== ACCOUNT OPTIONS ==========
            Column(
              children: [
                _buildOptionItem(
                  icon: Icons.receipt_long,
                  title: 'View Deals',
                  onTap: () => print('Clicked: View Deals'),
                ),
                _buildOptionItem(
                  icon: Icons.sync,
                  title: 'Sync Data',
                  onTap: () => print('Clicked: Sync Data'),
                ),
                _buildOptionItem(
                  icon: Icons.download,
                  title: 'Export Data',
                  onTap: () => print('Clicked: Export Data'),
                ),
                _buildOptionItem(
                  icon: Icons.settings,
                  title: 'Settings',
                  onTap: () => print('Clicked: Settings'),
                ),
              ],
            ),

            const SizedBox(height: 56),

            // ========== LOGOUT BUTTON ==========
            GestureDetector(
              onTap: () => print('Clicked: Disconnect Wallet'),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.red.withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: AppColors.red.withOpacity(0.3),
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'Disconnect Wallet',
                    style: TextStyle(
                      color: AppColors.red,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }
}
