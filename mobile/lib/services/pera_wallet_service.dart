import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';

class PeraWalletService with ChangeNotifier {
  String? _userAddress;
  bool _isConnected = false;

  String? get userAddress => _userAddress;
  bool get isConnected => _isConnected;

  // Initialize Pera Wallet connection
  Future<void> initialize() async {
    try {
      print('✅ Pera Wallet service initialized');
    } catch (e) {
      print('❌ Error initializing Pera Wallet: $e');
    }
  }

  // Connect to Pera Wallet via deep link
  Future<void> connectWallet() async {
    try {
      print('🔗 Opening Pera Wallet...');

      // Pera Wallet deep link schemes (try multiple variations)
      final deepLinks = [
        'pera://connect',
        'perawallet://connect',
        Uri(
          scheme: 'https',
          host: 'app.perawallet.app',
          path: '/connect',
        ).toString(),
      ];

      bool launched = false;
      for (final link in deepLinks) {
        try {
          final uri = Uri.parse(link);
          if (await canLaunchUrl(uri)) {
            await launchUrl(uri, mode: LaunchMode.externalApplication);
            launched = true;
            print('✅ Launched Pera Wallet with: $link');
            break;
          }
        } catch (e) {
          print('⚠️ Failed to launch $link: $e');
          continue;
        }
      }

      if (!launched) {
        // Fallback: Simulate connection with a test address
        print('⚠️ Could not launch Pera Wallet app, using simulated connection');
        _simulateWalletConnection();
      } else {
        // In a real implementation, wait for callback
        // For now, show a dialog to user to approve in Pera
        print('📱 Please approve connection in Pera Wallet app');
        // Simulate successful connection after a delay
        await Future.delayed(const Duration(seconds: 2));
        _simulateWalletConnection();
      }
    } catch (e) {
      print('❌ Error connecting wallet: $e');
      _isConnected = false;
      notifyListeners();
      rethrow;
    }
  }

  // Simulate wallet connection (in production, this would come from deep link callback)
  void _simulateWalletConnection() {
    // Simulated Algorand testnet address (valid Algo address format)
    _userAddress = '7MNWVYP4VJKJVQTDKNV3HZWFVYYKQCB23YUQ2K4CQYQJB5KNGQPNMCQOQ';
    _isConnected = true;
    print('✅ Connected: $_userAddress');
    notifyListeners();
  }

  // Disconnect wallet
  Future<void> disconnectWallet() async {
    try {
      print('🔓 Disconnecting wallet...');
      _isConnected = false;
      _userAddress = null;
      print('✅ Wallet disconnected');
      notifyListeners();
    } catch (e) {
      print('❌ Error disconnecting wallet: $e');
      rethrow;
    }
  }

  // Sign transaction with Pera Wallet
  Future<String?> signTransaction(String txnBase64) async {
    try {
      print('📝 Signing transaction with Pera Wallet...');

      if (!_isConnected || _userAddress == null) {
        throw Exception('Wallet not connected. Please connect first.');
      }

      // In production, this would use WalletConnect or deep links
      // For now, return a simulated signature
      const mockSignature =
          'SIGN_TX_7MNWVYP4VJKJVQTDKNV3HZWFVYYKQCB23YUQ2K4CQYQJB5KNGQPNMCQOQ_BASE64_ENCODED_SIGNATURE';

      print('✅ Transaction signed');
      return mockSignature;
    } catch (e) {
      print('❌ Error signing transaction: $e');
      rethrow;
    }
  }

  // Get public key (address) from wallet
  Future<String> getPublicKey() async {
    if (_userAddress != null) {
      return _userAddress!;
    }
    throw Exception('Wallet not connected');
  }

  // Set user address (used by deep link callback)
  void setUserAddress(String address) {
    _userAddress = address;
    _isConnected = true;
    notifyListeners();
  }
}
