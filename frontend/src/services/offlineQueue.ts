export interface OfflineEnvelope {
  readonly id: string;
  readonly messageType: string;
  readonly aggregateType: string;
  readonly aggregateId: string;
  readonly expectedVersion: number;
  readonly payload: Readonly<Record<string, unknown>>;
  readonly occurredAt: string;
  readonly queuedAt: string;
}

const databaseName = 'o83-care-offline';
const storeName = 'command-envelopes';

function openDatabase(): Promise<IDBDatabase> {
  return new Promise<IDBDatabase>((resolve, reject) => {
    if (!('indexedDB' in globalThis)) {
      reject(new Error('Offline device storage is unavailable in this browser context.'));
      return;
    }
    const request = indexedDB.open(databaseName, 1);
    request.onupgradeneeded = () => {
      if (!request.result.objectStoreNames.contains(storeName))
        request.result.createObjectStore(storeName, { keyPath: 'id' });
    };
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error ?? new Error('Offline queue is unavailable.'));
  });
}

async function transaction<T>(
  mode: IDBTransactionMode,
  run: (store: IDBObjectStore) => IDBRequest<T>,
): Promise<T> {
  const database = await openDatabase();
  return new Promise<T>((resolve, reject) => {
    const request = run(database.transaction(storeName, mode).objectStore(storeName));
    request.onsuccess = () => resolve(request.result);
    request.onerror = () => reject(request.error ?? new Error('Offline queue operation failed.'));
  }).finally(() => database.close());
}

export async function enqueueOfflineEnvelope(envelope: OfflineEnvelope): Promise<void> {
  await transaction('readwrite', (store) => store.add(envelope));
}

export async function listOfflineEnvelopes(): Promise<readonly OfflineEnvelope[]> {
  return transaction('readonly', (store) => store.getAll()) as Promise<readonly OfflineEnvelope[]>;
}

export async function removeOfflineEnvelope(id: string): Promise<void> {
  await transaction('readwrite', (store) => store.delete(id));
}
