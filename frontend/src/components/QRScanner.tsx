import React, { useEffect, useRef, useState } from 'react';
import { Html5QrcodeScanner, Html5QrcodeScanType } from 'html5-qrcode';

export interface ScannedPaymentInfo {
  address: string;
  name: string;
}

interface QRScannerProps {
  onScanSuccess: (info: ScannedPaymentInfo) => void;
  onClose: () => void;
}

const QRScanner: React.FC<QRScannerProps> = ({ onScanSuccess, onClose }) => {
  const scannerRef = useRef<Html5QrcodeScanner | null>(null);
  const containerRef = useRef<HTMLDivElement>(null);
  const [error, setError] = useState<string>('');

  useEffect(() => {
    if (!containerRef.current) return;

    const scanner = new Html5QrcodeScanner(
      'qr-scanner-container',
      {
        fps: 10,
        qrbox: { width: 250, height: 250 },
        supportedScanTypes: [Html5QrcodeScanType.SCAN_TYPE_CAMERA],
      },
      false
    );

    scannerRef.current = scanner;

    scanner.render(
      (decodedText: string) => {
        try {
          const parsed = JSON.parse(decodedText) as {
            address?: string;
            name?: string;
            app?: string;
          };
          if (!parsed.address) {
            setError('Invalid QR code: missing address');
            return;
          }
          scanner.clear().catch(() => {});
          onScanSuccess({ address: parsed.address, name: parsed.name || 'Unknown' });
        } catch {
          setError('Invalid QR code format');
        }
      },
      (errorMsg: string) => {
        // Suppress noisy scan-failure logs
        if (!errorMsg.includes('QR code parse error')) {
          console.debug('QR scan:', errorMsg);
        }
      }
    );

    return () => {
      scanner.clear().catch(() => {});
    };
  }, [onScanSuccess]);

  return (
    <div className="qr-scanner-overlay">
      <div className="qr-scanner-modal">
        <div className="modal-header">
          <h2>Scan QR Code</h2>
          <button className="btn-close" onClick={onClose}>✕</button>
        </div>
        <p className="hint">Point your camera at the receiver's QR code</p>
        {error && <div className="error-banner">{error}</div>}
        <div id="qr-scanner-container" ref={containerRef} />
      </div>
    </div>
  );
};

export default QRScanner;
