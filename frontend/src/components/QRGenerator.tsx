import React, { useEffect, useState, useCallback } from 'react';
import QRCode from 'qrcode';

interface QRGeneratorProps {
  address: string;
  name: string;
}

const QRGenerator: React.FC<QRGeneratorProps> = ({ address, name }) => {
  const [dataUrl, setDataUrl] = useState<string>('');
  const [copied, setCopied] = useState(false);

  const qrPayload = JSON.stringify({ address, name, app: '808Pay' });

  const generateQR = useCallback(async () => {
    try {
      const url = await QRCode.toDataURL(qrPayload, {
        errorCorrectionLevel: 'H',
        margin: 2,
        width: 280,
        color: { dark: '#1a1a2e', light: '#ffffff' },
      });
      setDataUrl(url);
    } catch (err) {
      console.error('QR generation error:', err);
    }
  }, [qrPayload]);

  useEffect(() => {
    generateQR();
  }, [generateQR]);

  const copyAddress = async () => {
    await navigator.clipboard.writeText(address);
    setCopied(true);
    setTimeout(() => setCopied(false), 2000);
  };

  return (
    <div className="qr-generator">
      <h2>Receive Payment</h2>
      <p className="hint">Show this QR code to the sender</p>
      {dataUrl && (
        <div className="qr-wrapper">
          <img src={dataUrl} alt="Payment QR Code" className="qr-image" />
        </div>
      )}
      <div className="address-box">
        <span className="address-label">Your Address</span>
        <span className="address-value">{address}</span>
        <button onClick={copyAddress} className="btn-copy">
          {copied ? '✓ Copied' : 'Copy'}
        </button>
      </div>
      <div className="address-box" style={{ marginTop: 8 }}>
        <span className="address-label">Name</span>
        <span className="address-value">{name}</span>
      </div>
    </div>
  );
};

export default QRGenerator;
