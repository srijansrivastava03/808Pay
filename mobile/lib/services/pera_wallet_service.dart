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
      // Check if Pera Wallet is installed by attempting to launch a deep link
    } catch (e) {
      print('❌ Error initializing Pera Wallet: $e');
    }
  }

  // Connect to Pera Wallet via deep link
  Future<void> connectWallet() async {
    try {
      print('🔗 Opening Pera Wallet...');

      // Deep link to Pera Wallet to connect
      // In production, you'd use WalletConnect or direct integration
      // For now, we'll use a simulated connection
      
      // Example Pera Wallet deep link:
      // pera://connect?callback=pay808://wallet-connected
      
      const peraDeepLink = 'pera://wallet';
      
      if (await canLaunchUrl(Uri.parse(peraDeepLink))) {
        await launchUrl(Uri.parse(peraDeepLink), mode: LaunchMode.externalApplication);
        // In a real app, you'd wait for the wallet to return via deep link
        // For now, simulate a connection
        _simulateWalletConnection();
      } else {
        throw Exception('Pera Wallet is not installed. Please download it from the App Store or Google Play.');
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
    // Simulated Algorand testnet address
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
      // Real signature would be Ed25519
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
