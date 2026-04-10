import React, { useEffect, useState } from 'react';
import './App.css';
import Dashboard from './pages/Dashboard';
import SetupWallet from './components/SetupWallet';
import { hasWallet } from './services/wallet';

const App: React.FC = () => {
  const [walletReady, setWalletReady] = useState(hasWallet());

  useEffect(() => {
    setWalletReady(hasWallet());
  }, []);

  const handleSetupComplete = () => {
    setWalletReady(true);
  };

  return walletReady ? (
    <Dashboard />
  ) : (
    <SetupWallet onComplete={handleSetupComplete} />
  );
};

export default App;
