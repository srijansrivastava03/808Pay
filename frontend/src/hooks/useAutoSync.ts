import { useEffect, useCallback, useRef } from 'react';
import { getPendingPayments, updatePaymentStatus } from '../services/offlineQueue';
import { submitBatch } from '../services/api';

/**
 * Automatically submits queued offline payments when the browser goes back online.
 */
export function useAutoSync(onSyncComplete?: () => void) {
  const syncing = useRef(false);

  const syncPending = useCallback(async () => {
    if (syncing.current) return;
    const pending = getPendingPayments();
    if (pending.length === 0) return;

    syncing.current = true;
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
      onSyncComplete?.();
    } catch {
      // Silently fail – will retry next time online event fires
    } finally {
      syncing.current = false;
    }
  }, [onSyncComplete]);

  useEffect(() => {
    const handleOnline = () => {
      // Small delay to ensure connection is stable
      setTimeout(syncPending, 2000);
    };

    window.addEventListener('online', handleOnline);

    // Also try to sync on mount if already online and pending items exist
    if (navigator.onLine) {
      syncPending();
    }

    return () => {
      window.removeEventListener('online', handleOnline);
    };
  }, [syncPending]);
}
