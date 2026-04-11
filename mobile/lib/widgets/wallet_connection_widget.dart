import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pera_wallet_service_v2.dart';
import '../theme/app_theme.dart';

class WalletConnectionWidget extends StatefulWidget {
  final VoidCallback? onConnected;
  final VoidCallback? onDisconnected;

  const WalletConnectionWidget({
    Key? key,
    this.onConnected,
    this.onDisconnected,
  }) : super(key: key);

  @override
  State<WalletConnectionWidget> createState() => _WalletConnectionWidgetState();
}

class _WalletConnectionWidgetState extends State<WalletConnectionWidget> {
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _initializeWallet();
  }

  Future<void> _initializeWallet() async {
    final walletService = Provider.of<PeraWalletServiceV2>(context, listen: false);
    await walletService.initialize();
  }

  Future<void> _handleConnectWallet(BuildContext context) async {
    final walletService = Provider.of<PeraWalletServiceV2>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      // Connect to Pera Wallet app
      await walletService.connectWallet();

      if (mounted) {
        // Show dialog asking user for wallet address
        _showWalletAddressDialog(context, walletService);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connection failed:\n$e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showWalletAddressDialog(
    BuildContext context,
    PeraWalletServiceV2 walletService,
  ) {
    final addressController = TextEditingController();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.grey,
        title: const Text(
          'Enter Your Pera Wallet Address',
          style: TextStyle(color: AppColors.white),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'You should see your wallet address in the Pera app.',
              style: TextStyle(color: AppColors.lightGrey, fontSize: 12),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: addressController,
              style: const TextStyle(color: AppColors.white),
              decoration: InputDecoration(
                hintText: 'XXXXXX...XXXXXX (58 characters)',
                hintStyle: const TextStyle(color: AppColors.lightGrey),
                filled: true,
                fillColor: AppColors.black,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                  borderSide: const BorderSide(color: AppColors.red),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel', style: TextStyle(color: AppColors.lightGrey)),
          ),
          ElevatedButton(
            onPressed: () {
              final address = addressController.text.trim();
              if (address.isEmpty) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Please enter your wallet address'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              if (address.length < 50) {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Invalid address length (should be ~58 chars)'),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }

              // Set the real wallet address
              try {
                walletService.setWalletAddress(address);
                Navigator.pop(context);

                ScaffoldMessenger.of(this.context).showSnackBar(
                  SnackBar(
                    content: Text('✅ Wallet connected!\n${address.substring(0, 12)}...${address.substring(address.length - 8)}'),
                    backgroundColor: Colors.green,
                    duration: const Duration(seconds: 2),
                  ),
                );
                widget.onConnected?.call();
              } catch (e) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Error: $e'),
                    backgroundColor: AppColors.error,
                  ),
                );
              }
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.red),
            child: const Text('Confirm'),
          ),
        ],
      ),
    );
  }

  Future<void> _handleDisconnectWallet(BuildContext context) async {
    final walletService = Provider.of<PeraWalletServiceV2>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      await walletService.disconnectWallet();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Wallet disconnected'),
            backgroundColor: AppColors.warning,
            duration: Duration(seconds: 2),
          ),
        );
        widget.onDisconnected?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error: $e'),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 2),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<PeraWalletServiceV2>(
      builder: (context, walletService, _) {
        if (walletService.isConnected) {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.5),
              border: Border.all(color: AppColors.success, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.wallet, color: AppColors.success, size: 20),
                    const SizedBox(width: 8),
                    const Text(
                      'Wallet Connected',
                      style: TextStyle(
                        color: AppColors.success,
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                SelectableText(
                  walletService.userAddress ?? '',
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                    fontFamily: 'monospace',
                  ),
                ),
                const SizedBox(height: 12),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.red.withOpacity(0.2),
                      side: const BorderSide(color: AppColors.red),
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => _handleDisconnectWallet(context),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppColors.red),
                            ),
                          )
                        : const Text('Disconnect Wallet'),
                  ),
                ),
              ],
            ),
          );
        } else {
          return Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.black.withOpacity(0.5),
              border: Border.all(color: AppColors.warning, width: 2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Column(
              children: [
                const Icon(
                  Icons.wallet_outlined,
                  color: AppColors.warning,
                  size: 32,
                ),
                const SizedBox(height: 12),
                const Text(
                  'Wallet Not Connected',
                  style: TextStyle(
                    color: AppColors.warning,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Connect your Pera Wallet to create deals and sign transactions',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.warning,
                    ),
                    onPressed: _isLoading
                        ? null
                        : () => _handleConnectWallet(context),
                    child: _isLoading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor: AlwaysStoppedAnimation(AppColors.black),
                            ),
                          )
                        : const Text('Connect Pera Wallet'),
                  ),
                ),
              ],
            ),
          );
        }
      },
    );
  }
}

