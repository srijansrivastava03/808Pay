import React, { useCallback, useEffect, useState } from 'react';
import QRGenerator from '../components/QRGenerator';
import QRScanner from '../components/QRScanner';
import PaymentForm from '../components/PaymentForm';
import PaymentQueue from '../components/PaymentQueue';
import { getStoredWallet, clearWallet } from '../services/wallet';
import { getAccountInfo } from '../services/api';
import { microAlgoToAlgo } from '../services/algorand';
import { getPendingPayments } from '../services/offlineQueue';
import { ScannedPaymentInfo } from '../components/QRScanner';
import { useAutoSync } from '../hooks/useAutoSync';

type Tab = 'receive' | 'send' | 'history';

const Dashboard: React.FC = () => {
  const wallet = getStoredWallet();
  const [tab, setTab] = useState<Tab>('receive');
  const [scanning, setScanning] = useState(false);
  const [scannedInfo, setScannedInfo] = useState<ScannedPaymentInfo | null>(null);
  const [balance, setBalance] = useState<number | null>(null);
  const [online, setOnline] = useState(navigator.onLine);
  const [pendingCount, setPendingCount] = useState(0);

  const refreshBalance = useCallback(async () => {
    if (!wallet) return;
    try {
      const info = await getAccountInfo(wallet.address);
      setBalance(microAlgoToAlgo(info.amount));
    } catch {
      setBalance(null);
    }
  }, [wallet]);

  const refreshPending = useCallback(() => {
    setPendingCount(getPendingPayments().length);
  }, []);

  // Auto-sync queued payments when connectivity is restored
  useAutoSync(refreshPending);

  useEffect(() => {
    refreshBalance();
    refreshPending();

    const handleOnline = () => {
      setOnline(true);
      refreshBalance();
    };
    const handleOffline = () => setOnline(false);

    window.addEventListener('online', handleOnline);
    window.addEventListener('offline', handleOffline);
    return () => {
      window.removeEventListener('online', handleOnline);
      window.removeEventListener('offline', handleOffline);
    };
  }, [refreshBalance, refreshPending]);

  if (!wallet) return null;

  return (
    <div className="dashboard">
      {/* Header */}
      <header className="app-header">
        <div className="header-left">
          <span className="app-logo">808Pay</span>
        </div>
        <div className="header-right">
          <span className={`online-indicator ${online ? 'online' : 'offline'}`}>
            {online ? '● Online' : '○ Offline'}
          </span>
          <button className="btn-link" onClick={() => { clearWallet(); window.location.reload(); }}>
            Logout
          </button>
        </div>
      </header>

      {/* Wallet card */}
      <div className="wallet-card">
        <div className="wallet-name">{wallet.name}</div>
        <div className="wallet-address">
          {wallet.address.slice(0, 8)}…{wallet.address.slice(-6)}
        </div>
        <div className="wallet-balance">
          {balance !== null ? `${balance.toFixed(4)} ALGO` : '—'}
        </div>
        {pendingCount > 0 && (
          <div className="pending-badge">
            {pendingCount} payment{pendingCount > 1 ? 's' : ''} queued offline
          </div>
        )}
      </div>

      {/* Tabs */}
      <nav className="tab-nav">
        {(['receive', 'send', 'history'] as Tab[]).map((t) => (
          <button
            key={t}
            className={`tab-btn ${tab === t ? 'active' : ''}`}
            onClick={() => setTab(t)}
          >
            {t === 'receive' ? '📥 Receive' : t === 'send' ? '📤 Send' : '📋 History'}
          </button>
        ))}
      </nav>

      {/* Tab content */}
      <div className="tab-content">
        {tab === 'receive' && (
          <QRGenerator address={wallet.address} name={wallet.name} />
        )}

        {tab === 'send' && !scanning && !scannedInfo && (
          <div className="send-start">
            <p className="hint">Scan the receiver's QR code to initiate a payment.</p>
            <button className="btn-primary btn-large" onClick={() => setScanning(true)}>
              📷 Scan QR Code
            </button>
            <p className="offline-note">
              Payments can be created offline. They will be submitted to the blockchain automatically when connectivity is restored.
            </p>
          </div>
        )}

        {tab === 'history' && (
          <PaymentQueue onQueueChange={refreshPending} />
        )}
      </div>

      {/* QR Scanner overlay */}
      {scanning && (
        <QRScanner
          onScanSuccess={(info) => {
            setScanning(false);
            setScannedInfo(info);
          }}
          onClose={() => setScanning(false)}
        />
      )}

      {/* Payment form overlay */}
      {scannedInfo && (
        <PaymentForm
          receiverInfo={scannedInfo}
          onClose={() => setScannedInfo(null)}
          onSuccess={() => {
            setScannedInfo(null);
            setTab('history');
            refreshPending();
            refreshBalance();
          }}
        />
      )}
    </div>
  );
};

export default Dashboard;
