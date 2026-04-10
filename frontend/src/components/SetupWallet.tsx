import React, { useState } from 'react';
import { generateAccount, restoreAccount } from '../services/algorand';
import { saveWallet } from '../services/wallet';

interface SetupWalletProps {
  onComplete: () => void;
}

type Mode = 'choose' | 'create' | 'restore';

const SetupWallet: React.FC<SetupWalletProps> = ({ onComplete }) => {
  const [mode, setMode] = useState<Mode>('choose');
  const [name, setName] = useState('');
  const [pin, setPin] = useState('');
  const [confirmPin, setConfirmPin] = useState('');
  const [mnemonic, setMnemonic] = useState('');
  const [generatedMnemonic, setGeneratedMnemonic] = useState('');
  const [generatedAddress, setGeneratedAddress] = useState('');
  const [step, setStep] = useState<'form' | 'backup' | 'confirm'>('form');
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState('');

  const handleCreate = async () => {
    setError('');
    if (!name.trim()) { setError('Please enter a name'); return; }
    if (pin.length < 4) { setError('PIN must be at least 4 digits'); return; }
    if (pin !== confirmPin) { setError('PINs do not match'); return; }

    const account = generateAccount();
    setGeneratedMnemonic(account.mnemonic);
    setGeneratedAddress(account.address);
    setStep('backup');
  };

  const handleConfirmBackup = async () => {
    setLoading(true);
    try {
      await saveWallet(generatedAddress, name, generatedMnemonic, pin);
      onComplete();
    } catch (err) {
      setError('Failed to save wallet');
    } finally {
      setLoading(false);
    }
  };

  const handleRestore = async () => {
    setError('');
    if (!name.trim()) { setError('Please enter a name'); return; }
    if (pin.length < 4) { setError('PIN must be at least 4 digits'); return; }
    if (pin !== confirmPin) { setError('PINs do not match'); return; }
    if (!mnemonic.trim()) { setError('Please enter your mnemonic'); return; }

    setLoading(true);
    try {
      const account = restoreAccount(mnemonic.trim());
      await saveWallet(account.address, name, account.mnemonic, pin);
      onComplete();
    } catch {
      setError('Invalid mnemonic phrase. Please check and try again.');
    } finally {
      setLoading(false);
    }
  };

  if (mode === 'choose') {
    return (
      <div className="setup-container">
        <div className="setup-card">
          <div className="logo">808Pay</div>
          <h1>Offline Crypto Payments</h1>
          <p className="subtitle">Powered by Algorand blockchain</p>
          <div className="setup-actions">
            <button className="btn-primary btn-large" onClick={() => setMode('create')}>
              Create New Wallet
            </button>
            <button className="btn-secondary btn-large" onClick={() => setMode('restore')}>
              Restore Existing Wallet
            </button>
          </div>
        </div>
      </div>
    );
  }

  if (mode === 'create' && step === 'backup') {
    return (
      <div className="setup-container">
        <div className="setup-card">
          <h2>⚠️ Back Up Your Mnemonic</h2>
          <p className="hint">Write down these 25 words in order. This is the only way to recover your wallet.</p>
          <div className="mnemonic-display">
            {generatedMnemonic.split(' ').map((word, i) => (
              <span key={i} className="mnemonic-word">
                <span className="word-num">{i + 1}.</span> {word}
              </span>
            ))}
          </div>
          <div className="address-box">
            <span className="address-label">Your Address</span>
            <span className="address-value">{generatedAddress}</span>
          </div>
          <div className="setup-actions">
            <button className="btn-primary" onClick={handleConfirmBackup} disabled={loading}>
              {loading ? 'Saving…' : "I've Saved My Mnemonic"}
            </button>
            <button className="btn-secondary" onClick={() => setMode('choose')}>
              Cancel
            </button>
          </div>
          {error && <div className="error-banner">{error}</div>}
        </div>
      </div>
    );
  }

  return (
    <div className="setup-container">
      <div className="setup-card">
        <button className="btn-back" onClick={() => setMode('choose')}>← Back</button>
        <h2>{mode === 'create' ? 'Create Wallet' : 'Restore Wallet'}</h2>

        <div className="form-group">
          <label className="form-label">Display Name</label>
          <input
            className="form-input"
            value={name}
            onChange={(e) => setName(e.target.value)}
            placeholder="e.g. Alice"
          />
        </div>

        {mode === 'restore' && (
          <div className="form-group">
            <label className="form-label">25-Word Mnemonic</label>
            <textarea
              className="form-input mnemonic-input"
              value={mnemonic}
              onChange={(e) => setMnemonic(e.target.value)}
              placeholder="word1 word2 word3 …"
              rows={4}
            />
          </div>
        )}

        <div className="form-group">
          <label className="form-label">PIN (min 4 digits)</label>
          <input
            type="password"
            className="form-input"
            value={pin}
            onChange={(e) => setPin(e.target.value)}
            placeholder="••••"
            inputMode="numeric"
            maxLength={12}
          />
        </div>

        <div className="form-group">
          <label className="form-label">Confirm PIN</label>
          <input
            type="password"
            className="form-input"
            value={confirmPin}
            onChange={(e) => setConfirmPin(e.target.value)}
            placeholder="••••"
            inputMode="numeric"
            maxLength={12}
          />
        </div>

        {error && <div className="error-banner">{error}</div>}

        <button
          className="btn-primary"
          onClick={mode === 'create' ? handleCreate : handleRestore}
          disabled={loading}
        >
          {loading ? 'Saving…' : mode === 'create' ? 'Create Wallet' : 'Restore Wallet'}
        </button>
      </div>
    </div>
  );
};

export default SetupWallet;
