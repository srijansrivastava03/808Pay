import React, { useCallback, useEffect, useState } from 'react';
import { getQueue, getPendingPayments, updatePaymentStatus, clearConfirmedPayments, QueuedPayment } from '../services/offlineQueue';
import { submitBatch } from '../services/api';
import { microAlgoToAlgo } from '../services/algorand';

interface PaymentQueueProps {
  onQueueChange?: () => void;
}

const PaymentQueue: React.FC<PaymentQueueProps> = ({ onQueueChange }) => {
  const [queue, setQueue] = useState<QueuedPayment[]>([]);
  const [syncing, setSyncing] = useState(false);
  const [syncResult, setSyncResult] = useState('');

  const refreshQueue = useCallback(() => {
    setQueue(getQueue());
  }, []);

  useEffect(() => {
    refreshQueue();
  }, [refreshQueue]);

  const syncNow = async () => {
    const pending = getPendingPayments();
    if (pending.length === 0) {
      setSyncResult('No pending payments to sync.');
      return;
    }
    setSyncing(true);
    setSyncResult('');
    try {
      const results = await submitBatch(pending.map((p) => p.signedTxn));
      results.forEach((r) => {
        const payment = pending[r.index];
        if (r.txId) {
          updatePaymentStatus(payment.id, 'confirmed', { txId: r.txId, submittedAt: Date.now() });
        } else {
          updatePaymentStatus(payment.id, 'failed', { errorMessage: r.error });
        }
      });
      const succeeded = results.filter((r) => r.txId).length;
      const failed = results.filter((r) => r.error).length;
      setSyncResult(`Sync complete: ${succeeded} confirmed, ${failed} failed.`);
      refreshQueue();
      onQueueChange?.();
    } catch (err: unknown) {
      setSyncResult(`Sync failed: ${err instanceof Error ? err.message : String(err)}`);
    } finally {
      setSyncing(false);
    }
  };

  const handleClearConfirmed = () => {
    clearConfirmedPayments();
    refreshQueue();
  };

  const statusBadge = (status: QueuedPayment['status']) => {
    const map: Record<QueuedPayment['status'], string> = {
      pending: 'badge-pending',
      submitted: 'badge-info',
      confirmed: 'badge-success',
      failed: 'badge-error',
    };
    return <span className={`badge ${map[status]}`}>{status}</span>;
  };

  if (queue.length === 0) {
    return (
      <div className="queue-empty">
        <p>No payment history yet.</p>
      </div>
    );
  }

  return (
    <div className="payment-queue">
      <div className="queue-actions">
        <button className="btn-primary" onClick={syncNow} disabled={syncing}>
          {syncing ? 'Syncing…' : '⬆ Sync Now'}
        </button>
        <button className="btn-secondary" onClick={handleClearConfirmed}>
          Clear Confirmed
        </button>
      </div>
      {syncResult && <div className="sync-result">{syncResult}</div>}
      <ul className="queue-list">
        {queue
          .slice()
          .reverse()
          .map((p) => (
            <li key={p.id} className="queue-item">
              <div className="queue-item-header">
                <span className="queue-receiver">{p.receiverName}</span>
                {statusBadge(p.status)}
              </div>
              <div className="queue-item-detail">
                <span className="queue-amount">{microAlgoToAlgo(p.amountMicroAlgos).toFixed(6)} ALGO</span>
                <span className="queue-date">{new Date(p.createdAt).toLocaleString()}</span>
              </div>
              {p.note && <div className="queue-note">"{p.note}"</div>}
              {p.txId && (
                <a
                  className="queue-txid"
                  href={`https://testnet.algoexplorer.io/tx/${p.txId}`}
                  target="_blank"
                  rel="noopener noreferrer"
                >
                  TxID: {p.txId.slice(0, 12)}…
                </a>
              )}
              {p.errorMessage && <div className="queue-error">{p.errorMessage}</div>}
            </li>
          ))}
      </ul>
    </div>
  );
};

export default PaymentQueue;
