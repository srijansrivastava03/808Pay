import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/pera_wallet_service.dart';
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
    final walletService = Provider.of<PeraWalletService>(context, listen: false);
    await walletService.initialize();
  }

  Future<void> _handleConnectWallet(BuildContext context) async {
    final walletService = Provider.of<PeraWalletService>(context, listen: false);

    setState(() => _isLoading = true);

    try {
      await walletService.connectWallet();
      
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Connected: ${walletService.userAddress}'),
            backgroundColor: AppColors.success,
            duration: const Duration(seconds: 2),
          ),
        );
        widget.onConnected?.call();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to connect: $e'),
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

  Future<void> _handleDisconnectWallet(BuildContext context) async {
    final walletService = Provider.of<PeraWalletService>(context, listen: false);

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
    return Consumer<PeraWalletService>(
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

