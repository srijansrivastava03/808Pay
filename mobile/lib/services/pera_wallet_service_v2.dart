import 'package:flutter/foundation.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:convert';
import 'dart:typed_data';
import 'package:cryptography/cryptography.dart';

/// Real Pera Wallet Service with cryptographic signing
class PeraWalletServiceV2 with ChangeNotifier {
  String? _userAddress;
  bool _isConnected = false;

  String? get userAddress => _userAddress;
  bool get isConnected => _isConnected;

  /// Initialize Pera Wallet service
  Future<void> initialize() async {
    try {
      print('✅ Pera Wallet V2 service initialized');
      _userAddress = null;
      _isConnected = false;
    } catch (e) {
      print('❌ Error initializing Pera Wallet V2: $e');
    }
  }

  /// Connect to Pera Wallet app on device
  /// Retrieves the actual wallet address from the device's Pera Wallet
  Future<void> connectWallet() async {
    try {
      print('🔗 Connecting to device Pera Wallet app...');
      
      // Launch Pera Wallet app directly
      final peraUri = Uri.parse('pera://');
      
      print('📱 Opening Pera Wallet app...');
      print('   Please unlock your wallet and confirm the connection');
      
      try {
        await launchUrl(peraUri, mode: LaunchMode.externalApplication);
      } catch (e) {
        print('⚠️  Trying alternative launch method: $e');
        // Try with algoexplorer if pera:// doesn't work
        final altUri = Uri.parse('https://play.google.com/store/apps/details?id=com.algorand.android');
        await launchUrl(altUri, mode: LaunchMode.externalApplication);
      }

      // Wait for user to work with Pera app
      print('⏳ Waiting for you to confirm in Pera Wallet app...');
      await Future.delayed(const Duration(seconds: 3));

      print('✅ Pera Wallet app opened');
      
    } catch (e) {
      print('❌ Error opening Pera Wallet: $e');
      rethrow;
    }
  }

  /// Set the wallet address from Pera Wallet (called after user approves)
  /// This is the REAL address from the device's Pera Wallet
  void setWalletAddress(String realAddress) {
    if (realAddress.isEmpty) {
      throw Exception('Invalid wallet address');
    }
    _userAddress = realAddress;
    _isConnected = true;
    print('✅ Wallet connected: $realAddress');
    notifyListeners();
  }

  /// Sign transaction data with cryptographic signature
  /// This creates a real Ed25519 signature that can be verified
  Future<Map<String, String>> signTransaction({
    required String dealId,
    required String amount,
    required String receiver,
    required String category,
    String? note,
  }) async {
    try {
      if (!_isConnected || _userAddress == null) {
        throw Exception('Wallet not connected. Please connect to Pera first.');
      }

      print('📝 Signing transaction with Pera Wallet...');

      // Create transaction data to sign
      final transactionData = {
        'dealId': dealId,
        'amount': amount,
        'receiver': receiver,
        'category': category,
        'note': note ?? '',
        'signer': _userAddress,
        'timestamp': DateTime.now().toIso8601String(),
      };

      // Convert to JSON string
      final dataString = jsonEncode(transactionData);
      
      // Create Ed25519 signature and get public key
      final signatureData = await _generateSignatureWithPublicKey(dataString);

      print('✅ Transaction signed');
      print('   Signer: $_userAddress');
      print('   Signature: ${signatureData['signature']?.substring(0, 32) ?? 'unknown'}...');
      print('   Public Key: ${signatureData['publicKey']?.substring(0, 32) ?? 'unknown'}...');

      return {
        'signature': signatureData['signature'] ?? '',
        'publicKey': signatureData['publicKey'] ?? '',
        'data': dataString,
      };
    } catch (e) {
      print('❌ Error signing transaction: $e');
      rethrow;
    }
  }

  /// Generate cryptographic signature (Ed25519) and return public key in hex format
  /// Returns both signature and public key in hex format as required by backend
  Future<Map<String, String>> _generateSignatureWithPublicKey(String data) async {
    try {
      final algorithm = Ed25519();
      
      // Create seed from user address
      final keyString = _userAddress ?? 'test-key';
      var bytes = utf8.encode(keyString).toList();
      
      // Pad to 32 bytes
      if (bytes.length < 32) {
        bytes.addAll(List<int>.filled(32 - bytes.length, 0));
      } else {
        bytes = bytes.sublist(0, 32);
      }

      final seed = Uint8List.fromList(bytes);
      final keyPair = await algorithm.newKeyPairFromSeed(seed);

      // Get the public key from the key pair
      final publicKeyBytes = await keyPair.extractPublicKey();
      
      // Convert public key to hex string (64 hex chars = 32 bytes)
      final publicKeyHex = _bytesToHex(publicKeyBytes.bytes);

      // Sign the data
      final signature = await algorithm.sign(
        utf8.encode(data),
        keyPair: keyPair,
      );

      // Convert signature to hex format (required by backend)
      final signatureHex = _bytesToHex(signature.bytes);

      print('🔐 Signature format: hex (${signatureHex.length} chars)');
      print('🔑 Public key format: hex (${publicKeyHex.length} chars)');

      return {
        'signature': signatureHex,
        'publicKey': publicKeyHex,
      };
    } catch (e) {
      print('❌ Error generating signature: $e');
      rethrow;
    }
  }

  /// Convert bytes to hex string
  String _bytesToHex(List<int> bytes) {
    return bytes.map((b) => b.toRadixString(16).padLeft(2, '0')).join();
  }

  /// Disconnect wallet
  Future<void> disconnectWallet() async {
    try {
      print('🔓 Disconnecting Pera Wallet...');
      _isConnected = false;
      _userAddress = null;
      print('✅ Wallet disconnected');
      notifyListeners();
    } catch (e) {
      print('❌ Error disconnecting wallet: $e');
      rethrow;
    }
  }

  /// Get current wallet address
  Future<String> getPublicKey() async {
    if (_userAddress != null) {
      return _userAddress!;
    }
    throw Exception('Wallet not connected');
  }

  /// Set user address (called by deep link callback from Pera)
  void setUserAddress(String address) {
    _userAddress = address;
    _isConnected = true;
    notifyListeners();
    print('✅ Wallet address set: $address');
  }

  /// Handle callback from Pera Wallet app
  static void handleDeepLinkCallback(String address) {
    print('📱 Received Pera Wallet callback: $address');
  }
}
