import express from 'express';
import cors from 'cors';
import dotenv from 'dotenv';
import transactionRoutes from './routes/transactions';

dotenv.config();

const app = express();
const PORT = parseInt(process.env.PORT || '3001', 10);

app.use(cors());
app.use(express.json({ limit: '10mb' }));

app.use('/api', transactionRoutes);

app.get('/', (_req, res) => {
  res.json({
    name: '808Pay API',
    description: 'Offline-first digital payment system powered by Algorand blockchain',
    version: '1.0.0',
    endpoints: [
      'GET  /api/health',
      'GET  /api/params',
      'POST /api/submit',
      'POST /api/submit-batch',
      'GET  /api/account/:address',
      'GET  /api/transaction/:txId',
    ],
  });
});

if (process.env.NODE_ENV !== 'test') {
  app.listen(PORT, () => {
    console.log(`808Pay API server running on port ${PORT}`);
    console.log(`Algorand node: ${process.env.ALGORAND_NODE_URL || 'https://testnet-api.algonode.cloud'}`);
  });
}

export default app;
