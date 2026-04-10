import React, { useState } from 'react';
import { ScannedPaymentInfo } from './QRScanner';
import { signPayment, getStoredWallet } from '../services/wallet';
import { buildAndSignPayment, algoToMicroAlgo } from '../services/algorand';
import { enqueuePayment } from '../services/offlineQueue';
import { fetchParams, submitTransaction } from '../services/api';
import { updatePaymentStatus } from '../services/offlineQueue';

interface PaymentFormProps {
  receiverInfo: ScannedPaymentInfo;
  onClose: () => void;
  onSuccess: () => void;
}

const PaymentForm: React.FC<PaymentFormProps> = ({ receiverInfo, onClose, onSuccess }) => {
  const [amount, setAmount] = useState('');
  const [pin, setPin] = useState('');
  const [note, setNote] = useState('');
  const [loading, setLoading] = useState(false);
  const [status, setStatus] = useState<'idle' | 'signing' | 'queued' | 'submitted' | 'error'>('idle');
  const [message, setMessage] = useState('');

  const wallet = getStoredWallet();

  const handlePay = async () => {
    if (!amount || parseFloat(amount) <= 0) {
      setMessage('Please enter a valid amount');
      return;
    }
    if (!pin || pin.length < 4) {
      setMessage('PIN must be at least 4 digits');
      return;
    }

    setLoading(true);
    setStatus('signing');
    setMessage('');

    try {
      const senderAddress = wallet?.address || '';
      const amountMicroAlgos = algoToMicroAlgo(parseFloat(amount));

      // Try to get live params (online path)
      let signedTxnBase64: string;

      try {
        const params = await fetchParams();
        signedTxnBase64 = await signPayment(pin, (mnemonic) =>
          buildAndSignPayment(
            mnemonic,
            receiverInfo.address,
            amountMicroAlgos,
            params,
            note || undefined
          )
        );

        // Queue first, then try to submit immediately
        const queued = enqueuePayment({
          signedTxn: signedTxnBase64,
          receiverAddress: receiverInfo.address,
          receiverName: receiverInfo.name,
          amountMicroAlgos,
          senderAddress,
          note: note || undefined,
        });

        setStatus('queued');
        setMessage('Payment signed. Submitting to Algorand network...');

        const result = await submitTransaction(signedTxnBase64);
        updatePaymentStatus(queued.id, 'confirmed', { txId: result.txId });
        setStatus('submitted');
        setMessage(`Payment confirmed! TxID: ${result.txId.slice(0, 12)}...`);
        setTimeout(onSuccess, 2500);
      } catch (networkErr) {
        // Offline path: build with fallback params
        const fallbackParams = await buildOfflineParams();
        signedTxnBase64 = await signPayment(pin, (mnemonic) =>
          buildAndSignPayment(
            mnemonic,
            receiverInfo.address,
            amountMicroAlgos,
            fallbackParams,
            note || undefined
          )
        );

        enqueuePayment({
          signedTxn: signedTxnBase64,
          receiverAddress: receiverInfo.address,
          receiverName: receiverInfo.name,
          amountMicroAlgos,
          senderAddress,
          note: note || undefined,
        });

        setStatus('queued');
        setMessage(
          'You are offline. Payment has been signed and queued locally. It will be submitted automatically when connectivity is restored.'
        );
        setTimeout(onSuccess, 3000);
      }
    } catch (err: unknown) {
      setStatus('error');
      setMessage(
        err instanceof Error && err.message.includes('decrypt')
          ? 'Incorrect PIN. Please try again.'
          : `Error: ${err instanceof Error ? err.message : String(err)}`
      );
    } finally {
      setLoading(false);
    }
  };

  return (
    <div className="payment-form-overlay">
      <div className="payment-form-modal">
        <div className="modal-header">
          <h2>Send Payment</h2>
          <button className="btn-close" onClick={onClose}>✕</button>
        </div>

        <div className="receiver-info">
          <div className="info-row">
            <span className="info-label">To</span>
            <span className="info-value">{receiverInfo.name}</span>
          </div>
          <div className="info-row">
            <span className="info-label">Address</span>
            <span className="info-value address-truncated">
              {receiverInfo.address.slice(0, 8)}...{receiverInfo.address.slice(-6)}
            </span>
          </div>
        </div>

        <div className="form-group">
          <label className="form-label">Amount (ALGO)</label>
          <input
            type="number"
            className="form-input"
            value={amount}
            onChange={(e) => setAmount(e.target.value)}
            placeholder="0.00"
            min="0.001"
            step="0.001"
            disabled={loading}
          />
        </div>

        <div className="form-group">
          <label className="form-label">Note (optional)</label>
          <input
            type="text"
            className="form-input"
            value={note}
            onChange={(e) => setNote(e.target.value)}
            placeholder="What's this for?"
            maxLength={1000}
            disabled={loading}
          />
        </div>

        <div className="form-group">
          <label className="form-label">PIN</label>
          <input
            type="password"
            className="form-input"
            value={pin}
            onChange={(e) => setPin(e.target.value)}
            placeholder="Enter your PIN"
            maxLength={12}
            disabled={loading}
            inputMode="numeric"
          />
        </div>

        {message && (
          <div className={`status-message ${status === 'error' ? 'error' : status === 'queued' || status === 'submitted' ? 'success' : 'info'}`}>
            {message}
          </div>
        )}

        <button
          className="btn-primary"
          onClick={handlePay}
          disabled={loading || status === 'submitted' || status === 'queued'}
        >
          {loading ? 'Processing...' : 'Pay Now'}
        </button>
      </div>
    </div>
  );
};

// Fallback params for offline signing (Algorand TestNet defaults).
// ROUND_BASE is an estimated recent round that provides a wide validity window.
// The firstValid/lastValid are checked on submission; if the tx is too old,
// the node will reject it and the queue entry will be marked as failed.
// Update this value periodically (~1M rounds per ~2 weeks on TestNet).
// Algorand TestNet round: approximately 40M as of 2024-12.
const OFFLINE_ROUND_BASE = 40_000_000;
const OFFLINE_ROUND_WINDOW = 1_000; // number of rounds the tx stays valid

// TestNet genesis hash (base64) and ID — update these for MainNet deployments
const TESTNET_GENESIS_HASH = 'SGO1GKSzyE7IEPItTxCByw9x8FmnrCDexi9/cOUJOiI=';
const TESTNET_GENESIS_ID = 'testnet-v1.0';
const ALGO_MIN_FEE = 1000; // microALGO

async function buildOfflineParams() {
  return {
    fee: ALGO_MIN_FEE,
    flatFee: true,
    firstValid: OFFLINE_ROUND_BASE,
    lastValid: OFFLINE_ROUND_BASE + OFFLINE_ROUND_WINDOW,
    genesisID: TESTNET_GENESIS_ID,
    genesisHash: TESTNET_GENESIS_HASH,
    minFee: ALGO_MIN_FEE,
  };
}

export default PaymentForm;
