import 'package:flutter/material.dart';
import 'package:pay_808/widgets/signature_progress_widget.dart';
import 'package:pay_808/widgets/party_card_widget.dart';
import 'package:pay_808/services/pera_wallet_service_v2.dart';
import 'package:pay_808/services/transaction_queue_service.dart';
import 'atomic_settlement_confirmation_screen.dart';

class AtomicSigningScreen extends StatefulWidget {
  final Map<String, dynamic> atomicDeal;
  final String userRole;
  final String userAddress;

  const AtomicSigningScreen({
    required this.atomicDeal,
    required this.userRole,
    required this.userAddress,
    Key? key,
  }) : super(key: key);

  @override
  State<AtomicSigningScreen> createState() => _AtomicSigningScreenState();
}

class _AtomicSigningScreenState extends State<AtomicSigningScreen> {
  late Map<String, dynamic> _deal;
  bool isSigning = false;
  late PeraWalletServiceV2 _peraService;
  late TransactionQueueService _queueService;

  @override
  void initState() {
    super.initState();
    _deal = Map.from(widget.atomicDeal);
    _peraService = PeraWalletServiceV2();
    _queueService = TransactionQueueService();
    _initializeServices();
  }

  Future<void> _initializeServices() async {
    await _peraService.initialize();
    await _queueService.initialize();
    
    // Auto-connect to Pera wallet
    if (!_peraService.isConnected) {
      await _peraService.connectWallet();
    }
  }

  void _handleSign() async {
    setState(() => isSigning = true);

    try {
      // Get Pera address
      if (!_peraService.isConnected) {
        throw Exception('Pera Wallet not connected. Please connect first.');
      }

      final peraAddress = _peraService.userAddress;
      if (peraAddress == null) {
        throw Exception('Could not get Pera wallet address');
      }

      // Sign transaction with Pera Wallet
      final signResult = await _peraService.signTransaction(
        dealId: _deal['dealId'] ?? 'deal_${DateTime.now().millisecondsSinceEpoch}',
        amount: _deal['amount'].toString(),
        receiver: _deal['participants']['seller'] ?? '',
        category: _deal['category'] ?? 'general',
        note: _deal['note'],
      );

      // Add signature to deal
      _deal['requiredSignatures'].add(signResult['signature']);
      _deal['signers'] ??= [];
      _deal['signers'].add({
        'address': peraAddress,
        'signature': signResult['signature'],
        'role': widget.userRole,
        'timestamp': DateTime.now().toIso8601String(),
      });

      // Queue transaction if both signatures present
      if (_deal['requiredSignatures'].length >= _deal['requiredSignatureCount']) {
        _deal['signingStatus'] = 'FULLY_SIGNED';
        
        // Queue for later settlement
        await _queueService.queueTransaction(
          _deal['dealId'] ?? 'deal_${DateTime.now().millisecondsSinceEpoch}',
          _deal['amount'].toString(),
          _deal['participants']['seller'] ?? 'unknown',
          _deal['category'] ?? 'general',
          signResult['signature'],
          peraAddress,
          signResult['data'],
          peraAddress,
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('✅ Both signatures collected!\n📱 Transaction queued for settlement'),
              backgroundColor: Colors.green,
              duration: Duration(seconds: 3),
            ),
          );
          // Navigate to confirmation screen
          await Future.delayed(const Duration(milliseconds: 500));
          if (mounted) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AtomicSettlementConfirmationScreen(
                  atomicDeal: _deal,
                  userRole: widget.userRole,
                ),
              ),
            );
          }
        }
      } else {
        _deal['signingStatus'] = 'PARTIALLY_SIGNED';
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                  '✅ Signed with Pera!\n⏳ Waiting for ${widget.userRole == 'buyer' ? 'seller' : 'buyer'} to sign.'),
              backgroundColor: Colors.orange,
              duration: const Duration(seconds: 2),
            ),
          );
        }
      }

      setState(() {});
    } catch (e) {
      print('❌ Signing error: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('❌ Signing failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => isSigning = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final buyerAddress = _deal['participants']['buyer'];
    final sellerAddress = _deal['participants']['seller'];
    final buyerSigned = _deal['requiredSignatures'].isNotEmpty;
    final bothSigned =
        _deal['requiredSignatures'].length >= 2;
    final amount = _deal['amount'];
    final category = _deal['category'];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Sign Atomic Deal'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Signature Progress
            SignatureProgressWidget(
              currentSignatures: _deal['requiredSignatures'].length,
              requiredSignatures: _deal['requiredSignatureCount'],
              isSigned: bothSigned,
            ),
            const SizedBox(height: 24),

            // Deal Summary
            const Text(
              'Deal Summary',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey.shade300),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildInfoRow('Amount', '₹$amount'),
                  Divider(color: Colors.grey.shade300),
                  _buildInfoRow('Category', category.toUpperCase()),
                  Divider(color: Colors.grey.shade300),
                  _buildInfoRow('Buyer',
                      buyerAddress.substring(0, 16) + '...'),
                  Divider(color: Colors.grey.shade300),
                  _buildInfoRow('Seller',
                      sellerAddress.substring(0, 16) + '...'),
                ],
              ),
            ),
            const SizedBox(height: 24),

            // Party Cards
            const Text(
              'Signature Status',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            const SizedBox(height: 12),

            // Buyer
            PartyCardWidget(
              role: 'BUYER',
              icon: '🛍️',
              address: buyerAddress,
              hasSigned: buyerSigned,
            ),
            const SizedBox(height: 12),

            // Seller
            PartyCardWidget(
              role: 'SELLER',
              icon: '📦',
              address: sellerAddress,
              hasSigned: _deal['requiredSignatures'].length >= 2,
            ),
            const SizedBox(height: 24),

            // Sign Button
            if (!bothSigned)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: isSigning ? null : _handleSign,
                  icon: isSigning
                      ? const SizedBox(
                          height: 20,
                          width: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor:
                                AlwaysStoppedAnimation(Colors.white),
                          ),
                        )
                      : const Icon(Icons.edit_note),
                  label:
                      Text('Sign as ${widget.userRole.toUpperCase()}'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

            if (bothSigned) ...[
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.green.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green.shade300),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle,
                        color: Colors.green, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '✅ Ready to Settle!',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.green.shade900,
                            ),
                          ),
                          Text(
                            'Both parties have signed. Ready to submit to blockchain.',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label,
              style: TextStyle(color: Colors.grey.shade600)),
          Text(value, style: const TextStyle(fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
