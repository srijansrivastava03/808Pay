import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';

class SettlementResultWidget extends StatefulWidget {
  final Map<String, dynamic> result;
  final VoidCallback? onClose;

  const SettlementResultWidget({
    required this.result,
    this.onClose,
    Key? key,
  }) : super(key: key);

  @override
  State<SettlementResultWidget> createState() => _SettlementResultWidgetState();
}

class _SettlementResultWidgetState extends State<SettlementResultWidget> {
  late Map<String, dynamic> _algoTxn;
  late bool _confirmed;

  @override
  void initState() {
    super.initState();
    _algoTxn = widget.result['algoTransaction'] ?? {};
    _confirmed = _algoTxn['confirmed'] ?? false;
  }

  void _copyToClipboard(String text) {
    Clipboard.setData(ClipboardData(text: text));
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Copied to clipboard'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  void _openExplorerUrl(String url) async {
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not open URL')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      child: SingleChildScrollView(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Header with status
              Row(
                children: [
                  Icon(
                    _confirmed ? Icons.check_circle : Icons.schedule,
                    color: _confirmed ? Colors.green : Colors.orange,
                    size: 28,
                  ),
                  SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      _confirmed ? '✅ Settled!' : '⏳ Processing',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  if (_confirmed)
                    Icon(Icons.verified, color: Colors.blue, size: 24),
                ],
              ),
              SizedBox(height: 24),

              // Transaction ID
              _buildInfoCard(
                label: 'Transaction ID',
                value: widget.result['transactionId'] ?? 'N/A',
                copyable: true,
              ),

              // Algorand Txn ID (if available)
              if (_algoTxn['txId'] != null) ...[
                SizedBox(height: 12),
                _buildInfoCard(
                  label: 'Algo Txn ID',
                  value: (_algoTxn['txId'] as String).substring(0, 16) + '...',
                  fullValue: _algoTxn['txId'],
                  copyable: true,
                ),
              ],

              // Block Number (if available)
              if (_algoTxn['blockNumber'] != null) ...[
                SizedBox(height: 12),
                _buildInfoCard(
                  label: 'Block Number',
                  value: '${_algoTxn['blockNumber']}',
                ),
              ],

              SizedBox(height: 24),

              // Status Badge
              Container(
                padding: EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: _confirmed ? Colors.green.shade50 : Colors.orange.shade50,
                  border: Border.all(
                    color: _confirmed ? Colors.green.shade300 : Colors.orange.shade300,
                  ),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          _confirmed ? Icons.verified : Icons.hourglass_empty,
                          color: _confirmed ? Colors.green : Colors.orange,
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _confirmed
                                ? '✅ Confirmed on Algorand blockchain'
                                : '⏳ Waiting for blockchain confirmation',
                            style: TextStyle(
                              color:
                                  _confirmed ? Colors.green.shade700 : Colors.orange.shade700,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                    if (!_confirmed) ...[
                      SizedBox(height: 8),
                      Text(
                        'Usually takes 5-10 seconds',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.orange.shade600,
                        ),
                      ),
                    ],
                  ],
                ),
              ),

              SizedBox(height: 24),

              // Explorer Link
              if (_confirmed && _algoTxn['txId'] != null)
                Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.blue.shade300),
                    borderRadius: BorderRadius.circular(12),
                    color: Colors.blue.shade50,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.open_in_browser, color: Colors.blue),
                          SizedBox(width: 8),
                          Text(
                            'View on AlgoExplorer',
                            style: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: Colors.blue.shade700,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 12),
                      GestureDetector(
                        onTap: () =>
                            _openExplorerUrl(
                                'https://testnet.algoexplorer.io/tx/${_algoTxn['txId']}'),
                        child: Text(
                          'https://testnet.algoexplorer.io/tx/${_algoTxn['txId']}',
                          style: TextStyle(
                            color: Colors.blue,
                            fontSize: 12,
                            decoration: TextDecoration.underline,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ),

              SizedBox(height: 24),

              // Splits Information
              if (widget.result['splits'] != null)
                _buildSplitsCard(widget.result['splits']),

              SizedBox(height: 24),

              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.check),
                      label: Text('Done'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                        foregroundColor: Colors.white,
                      ),
                    ),
                  ),
                  if (_algoTxn['txId'] != null) ...[
                    SizedBox(width: 12),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => _copyToClipboard(_algoTxn['txId']),
                        icon: Icon(Icons.copy),
                        label: Text('Copy Txn ID'),
                      ),
                    ),
                  ],
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoCard({
    required String label,
    required String value,
    String? fullValue,
    bool copyable = false,
  }) {
    return Container(
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border.all(color: Colors.grey.shade200),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Colors.grey.shade600,
            ),
          ),
          SizedBox(height: 6),
          Row(
            children: [
              Expanded(
                child: Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: 'monospace',
                    color: Colors.grey.shade800,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (copyable)
                SizedBox(width: 8),
              if (copyable)
                GestureDetector(
                  onTap: () => _copyToClipboard(fullValue ?? value),
                  child: Icon(Icons.copy, size: 16, color: Colors.blue),
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSplitsCard(Map<String, dynamic> splits) {
    final merchant = splits['merchant'] ?? 0;
    final tax = splits['tax'] ?? 0;
    final loyalty = splits['loyalty'] ?? 0;
    final total = merchant + tax + loyalty;

    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey.shade300),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Payment Breakdown',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
          ),
          SizedBox(height: 12),
          _buildSplitRow('Merchant', merchant, Colors.green),
          SizedBox(height: 8),
          _buildSplitRow('Tax (GST)', tax, Colors.red),
          SizedBox(height: 8),
          _buildSplitRow('Loyalty', loyalty, Colors.purple),
          Divider(height: 16),
          _buildSplitRow('Total', total, Colors.blue, bold: true),
        ],
      ),
    );
  }

  Widget _buildSplitRow(String label, int amount, Color color, {bool bold = false}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 13,
            fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: color.withOpacity(0.1),
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            '₹${amount.toString()}',
            style: TextStyle(
              fontSize: 13,
              fontWeight: bold ? FontWeight.w600 : FontWeight.normal,
              color: color,
            ),
          ),
        ),
      ],
    );
  }
}
