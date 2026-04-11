import 'dart:async';
import 'dart:convert';
import 'package:nfc_manager/nfc_manager.dart';

/// Model for NFC transfer data
class NFCTransferData {
  final String recipient;
  final String amount;
  final String category;
  final String sender;

  NFCTransferData({
    required this.recipient,
    required this.amount,
    required this.category,
    required this.sender,
  });

  /// Convert to JSON for NFC transmission
  Map<String, dynamic> toJson() {
    return {
      'type': '808PAY_TRANSFER',
      'recipient': recipient,
      'amount': amount,
      'category': category,
      'sender': sender,
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Parse from NFC record
  factory NFCTransferData.fromJson(Map<String, dynamic> json) {
    return NFCTransferData(
      recipient: json['recipient'] as String,
      amount: json['amount'] as String,
      category: json['category'] as String,
      sender: json['sender'] as String,
    );
  }
}

/// NFC Transfer Service
/// Enables tap-to-transfer between two devices
class NFCTransferService {
  static final NFCTransferService _instance = NFCTransferService._internal();
  static Completer<NFCTransferData?>? _completer;

  factory NFCTransferService() {
    return _instance;
  }

  NFCTransferService._internal();

  /// Check if device supports NFC
  Future<bool> get isNFCAvailable async {
    try {
      bool isAvailable = await NfcManager.instance.isAvailable();
      print('📱 NFC: Available=$isAvailable');
      return isAvailable;
    } catch (e) {
      print('❌ NFC availability check failed: $e');
      return false;
    }
  }

  /// Start listening for NFC tap (Receiver mode)
  /// Returns the transfer data when another device taps
  Future<NFCTransferData?> readTransferData() async {
    try {
      print('📱 NFC: Starting NFC session...');

      // Create a fresh completer for this read
      _completer = Completer<NFCTransferData?>();

      // Start session and handle the future
      NfcManager.instance.startSession(
        onDiscovered: (NfcTag tag) async {
          print('📱 NFC: Tag discovered!');
          await _handleTagDiscovered(tag);
        },
      ).catchError((error) {
        print('❌ NFC session error: $error');
        if (_completer != null && !_completer!.isCompleted) {
          _completer!.complete(null);
        }
      });

      // Return the future that will complete when tag is detected or timeout
      return _completer!.future.timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          print('⏱️  NFC: Timeout waiting for tag');
          // Stop the session on timeout
          stopNFC();
          return null;
        },
      );
    } catch (e) {
      print('❌ NFC: Error starting session: $e');
      return null;
    }
  }

  /// Handle NFC tag discovery
  Future<void> _handleTagDiscovered(NfcTag tag) async {
    try {
      print('📱 NFC: Processing tag...');

      // Try to read NDEF message
      final ndef = Ndef.from(tag);
      if (ndef == null) {
        print('⚠️  NFC: Tag is not NDEF formatted');
        return;
      }

      print('📱 NFC: NDEF tag detected');

      // Read cached message
      final cachedMessage = ndef.cachedMessage;
      if (cachedMessage == null) {
        print('⚠️  NFC: No cached message on tag');
        return;
      }

      print('📱 NFC: Found ${cachedMessage.records.length} records');

      // Parse records to find 808PAY_TRANSFER data
      for (final record in cachedMessage.records) {
        print(
            '📱 NFC: Record type format: ${record.typeNameFormat}, type: ${record.type}');

        // Try different type name formats
        if (record.typeNameFormat == NdefTypeNameFormat.media ||
            record.typeNameFormat == NdefTypeNameFormat.unknown) {
          try {
            final payload = String.fromCharCodes(record.payload);
            print('📱 NFC: Payload: $payload');

            // Try to parse as JSON
            try {
              final json = jsonDecode(payload);
              print('📱 NFC: Parsed JSON: $json');

              if (json['type'] == '808PAY_TRANSFER') {
                print('✅ NFC: Valid 808PAY_TRANSFER data received!');
                final transferData = NFCTransferData.fromJson(json);

                // Complete the future
                if (_completer != null && !_completer!.isCompleted) {
                  _completer!.complete(transferData);
                }

                // Stop the session
                await stopNFC();
                return;
              }
            } catch (parseError) {
              print('⚠️  NFC: Not JSON format: $parseError');
            }
          } catch (e) {
            print('⚠️  NFC: Error processing record: $e');
          }
        }
      }

      print('⚠️  NFC: No 808PAY_TRANSFER data found in records');
    } catch (e) {
      print('❌ NFC: Error handling tag: $e');
    }
  }

  /// Stop NFC session
  Future<void> stopNFC() async {
    try {
      await NfcManager.instance.stopSession();
      print('📱 NFC: Session stopped');
    } catch (e) {
      print('❌ NFC: Error stopping session: $e');
    }
  }

  /// Write transfer data to NFC tag (Sender mode)
  Future<bool> writeTransferData(NFCTransferData data) async {
    try {
      print('📝 NFC: Writing transfer data...');
      print('⚠️  Note: NFC writing not supported in this version');
      return false;
    } catch (e) {
      print('❌ NFC: Error writing data: $e');
      return false;
    }
  }
}
