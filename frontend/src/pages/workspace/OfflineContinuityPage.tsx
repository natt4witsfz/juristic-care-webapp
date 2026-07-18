import { useEffect, useState, type FormEvent } from 'react';

import { ProjectionList } from '../../components/common/ProjectionList';
import { PageHeader } from '../../components/layout/PageHeader';
import { useAuth } from '../../features/auth/useAuth';
import { useDomainCommand } from '../../features/domain/hooks';
import {
  enqueueOfflineEnvelope,
  listOfflineEnvelopes,
  removeOfflineEnvelope,
  type OfflineEnvelope,
} from '../../services/offlineQueue';

export function OfflineContinuityPage() {
  const { access } = useAuth();
  const submitEnvelope = useDomainCommand('submit_offline_envelope');
  const [online, setOnline] = useState(navigator.onLine);
  const [queue, setQueue] = useState<readonly OfflineEnvelope[]>([]);
  const [messageType, setMessageType] = useState('operation_note');
  const [aggregateType, setAggregateType] = useState('operation');
  const [aggregateId, setAggregateId] = useState('');
  const [expectedVersion, setExpectedVersion] = useState('1');
  const [payload, setPayload] = useState('{"observation":""}');
  const [validationError, setValidationError] = useState<string | null>(null);

  const refresh = async () => {
    try {
      setQueue(await listOfflineEnvelopes());
    } catch (error) {
      setValidationError(
        error instanceof Error ? error.message : 'Offline device storage is unavailable.',
      );
    }
  };
  useEffect(() => {
    const initialLoad = window.setTimeout(() => void refresh(), 0);
    const update = () => setOnline(navigator.onLine);
    window.addEventListener('online', update);
    window.addEventListener('offline', update);
    return () => {
      window.clearTimeout(initialLoad);
      window.removeEventListener('online', update);
      window.removeEventListener('offline', update);
    };
  }, []);

  const send = async (envelope: OfflineEnvelope) => {
    if (!access) return false;
    try {
      await submitEnvelope.mutateAsync({
        p_juristic_person_id: access.juristicPersonId,
        p_external_message_id: envelope.id,
        p_message_type: envelope.messageType,
        p_schema_version: '1',
        p_payload: envelope.payload,
        p_payload_digest: null,
        p_aggregate_type: envelope.aggregateType,
        p_aggregate_id: envelope.aggregateId,
        p_expected_version: envelope.expectedVersion,
        p_occurred_at: envelope.occurredAt,
      });
    } catch {
      return false;
    }
    await removeOfflineEnvelope(envelope.id);
    await refresh();
    return true;
  };

  const submit = async (event: FormEvent) => {
    event.preventDefault();
    setValidationError(null);
    let parsedPayload: Record<string, unknown>;
    try {
      const parsed = JSON.parse(payload) as unknown;
      if (!parsed || Array.isArray(parsed) || typeof parsed !== 'object') {
        throw new Error('Payload must be a JSON object.');
      }
      parsedPayload = parsed as Record<string, unknown>;
    } catch (error) {
      setValidationError(error instanceof Error ? error.message : 'Payload must be valid JSON.');
      return;
    }
    const envelope: OfflineEnvelope = {
      id: crypto.randomUUID(),
      messageType,
      aggregateType,
      aggregateId,
      expectedVersion: Number(expectedVersion),
      payload: parsedPayload,
      occurredAt: new Date().toISOString(),
      queuedAt: new Date().toISOString(),
    };
    if (online) await send(envelope);
    else {
      await enqueueOfflineEnvelope(envelope);
      await refresh();
    }
  };

  const syncAll = async () => {
    for (const envelope of queue) {
      if (!(await send(envelope))) break;
    }
  };

  return (
    <div className="space-y-8">
      <PageHeader
        description="Offline envelopes retain occurred time, recorded time, idempotency, payload digest, expected version, and explicit conflicts. They never silently overwrite newer operational history."
        title="Offline Continuity"
      />
      <p className={online ? 'notice' : 'error-message'} role="status">
        {online
          ? 'Online — envelopes can be submitted.'
          : 'Offline — new envelopes remain within this browser profile and queued on this device.'}
      </p>
      <form className="card space-y-4" onSubmit={(event) => void submit(event)}>
        <h2 className="section-title">Record continuity envelope</h2>
        <div className="grid gap-4 md:grid-cols-2">
          <div>
            <label className="field-label" htmlFor="offline-message-type">
              Message type
            </label>
            <input
              className="field"
              id="offline-message-type"
              onChange={(event) => setMessageType(event.target.value)}
              required
              value={messageType}
            />
          </div>
          <div>
            <label className="field-label" htmlFor="offline-aggregate-type">
              Aggregate type
            </label>
            <select
              className="field"
              id="offline-aggregate-type"
              onChange={(event) => setAggregateType(event.target.value)}
              value={aggregateType}
            >
              <option value="case">Case</option>
              <option value="investigation">Investigation</option>
              <option value="incident">Incident</option>
              <option value="operation">Operation</option>
              <option value="workstep">Task</option>
            </select>
          </div>
          <div>
            <label className="field-label" htmlFor="offline-aggregate-id">
              Aggregate ID
            </label>
            <input
              className="field"
              id="offline-aggregate-id"
              onChange={(event) => setAggregateId(event.target.value)}
              required
              value={aggregateId}
            />
          </div>
          <div>
            <label className="field-label" htmlFor="offline-version">
              Expected version
            </label>
            <input
              className="field"
              id="offline-version"
              min="1"
              onChange={(event) => setExpectedVersion(event.target.value)}
              required
              type="number"
              value={expectedVersion}
            />
          </div>
          <div className="md:col-span-2">
            <label className="field-label" htmlFor="offline-payload">
              Payload JSON
            </label>
            <textarea
              className="field min-h-28"
              id="offline-payload"
              onChange={(event) => setPayload(event.target.value)}
              required
              value={payload}
            />
          </div>
        </div>
        {validationError ? (
          <p className="error-message" role="alert">
            {validationError}
          </p>
        ) : submitEnvelope.error ? (
          <p className="error-message" role="alert">
            {submitEnvelope.error.message}
          </p>
        ) : null}
        <button className="button-primary" disabled={submitEnvelope.isPending} type="submit">
          {online ? 'Submit continuity envelope' : 'Queue on this device'}
        </button>
      </form>
      <section className="card">
        <div className="flex items-center justify-between gap-4">
          <h2 className="section-title">Device queue ({queue.length})</h2>
          <button
            className="button-secondary"
            disabled={!online || queue.length === 0 || submitEnvelope.isPending}
            onClick={() => void syncAll()}
            type="button"
          >
            Synchronize safely
          </button>
        </div>
        <ul className="mt-4 space-y-2">
          {queue.map((item) => (
            <li className="list-item" key={item.id}>
              {item.messageType} · {item.aggregateType} {item.aggregateId} · occurred{' '}
              {new Date(item.occurredAt).toLocaleString()}
            </li>
          ))}
        </ul>
      </section>
      <ProjectionList
        empty="No submitted offline envelopes are visible."
        fields={[
          { key: 'external_message_id', label: 'Envelope' },
          { key: 'processing_state', label: 'State' },
          { key: 'occurred_at', label: 'Occurred' },
          { key: 'recorded_at', label: 'Recorded' },
          { key: 'conflict_type', label: 'Conflict' },
          { key: 'actual_version', label: 'Actual version' },
        ]}
        title="Server continuity status"
        view="offline_submission_status"
      />
    </div>
  );
}
