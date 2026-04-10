// Offline payment queue using localStorage
// Stores signed Algorand transactions for submission when connectivity is restored

export interface QueuedPayment {
  id: string;
  signedTxn: string; // base64-encoded signed transaction bytes
  receiverAddress: string;
  receiverName: string;
  amountMicroAlgos: number;
  senderAddress: string;
  note?: string;
  createdAt: number; // unix timestamp ms
  status: 'pending' | 'submitted' | 'confirmed' | 'failed';
  txId?: string;
  errorMessage?: string;
  submittedAt?: number;
}

const QUEUE_KEY = '808pay_queue';

function loadQueue(): QueuedPayment[] {
  try {
    const raw = localStorage.getItem(QUEUE_KEY);
    return raw ? (JSON.parse(raw) as QueuedPayment[]) : [];
  } catch {
    return [];
  }
}

function saveQueue(queue: QueuedPayment[]): void {
  localStorage.setItem(QUEUE_KEY, JSON.stringify(queue));
}

export function getQueue(): QueuedPayment[] {
  return loadQueue();
}

export function getPendingPayments(): QueuedPayment[] {
  return loadQueue().filter((p) => p.status === 'pending');
}

export function enqueuePayment(payment: Omit<QueuedPayment, 'id' | 'createdAt' | 'status'>): QueuedPayment {
  const queue = loadQueue();
  const entry: QueuedPayment = {
    ...payment,
    id: `${Date.now()}-${Math.random().toString(36).slice(2)}`,
    createdAt: Date.now(),
    status: 'pending',
  };
  queue.push(entry);
  saveQueue(queue);
  return entry;
}

export function updatePaymentStatus(
  id: string,
  status: QueuedPayment['status'],
  extra?: Partial<QueuedPayment>
): void {
  const queue = loadQueue();
  const idx = queue.findIndex((p) => p.id === id);
  if (idx !== -1) {
    queue[idx] = { ...queue[idx], status, ...extra };
    saveQueue(queue);
  }
}

export function removePayment(id: string): void {
  const queue = loadQueue().filter((p) => p.id !== id);
  saveQueue(queue);
}

export function clearConfirmedPayments(): void {
  const queue = loadQueue().filter((p) => p.status !== 'confirmed');
  saveQueue(queue);
}
