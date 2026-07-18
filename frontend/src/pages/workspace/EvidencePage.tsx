import { useState, type FormEvent } from 'react';

import { ProjectionList } from '../../components/common/ProjectionList';
import { PageHeader } from '../../components/layout/PageHeader';
import { useAuth } from '../../features/auth/useAuth';
import { useEvidenceUpload } from '../../features/domain/hooks';
import type { EvidenceUploadInput } from '../../features/domain/types';

export function EvidencePage() {
  const { access, hasPermission } = useAuth();
  const upload = useEvidenceUpload();
  const [targetType, setTargetType] = useState<EvidenceUploadInput['targetType']>('case');
  const [targetId, setTargetId] = useState('');
  const [file, setFile] = useState<File | null>(null);
  const [evidenceType, setEvidenceType] = useState('attachment');
  const [relevance, setRelevance] = useState('');
  const [captureMethod, setCaptureMethod] = useState('direct_upload');
  const [capturedAt, setCapturedAt] = useState('');
  const [custodian, setCustodian] = useState('');
  const [validationError, setValidationError] = useState<string | null>(null);

  const submit = async (event: FormEvent) => {
    event.preventDefault();
    if (!access || !file) return;
    setValidationError(null);
    if (!file.type) {
      setValidationError('The file must have a recognized media type.');
      return;
    }
    if (file.size > 52_428_800) {
      setValidationError('Evidence files are limited to 50 MiB.');
      return;
    }
    await upload
      .mutateAsync({
        juristicPersonId: access.juristicPersonId,
        targetType,
        targetId,
        file,
        evidenceType,
        relevance,
        captureMethod,
        capturedAt: capturedAt ? new Date(capturedAt).toISOString() : new Date().toISOString(),
        ...(custodian ? { custodianRelationshipId: custodian } : {}),
      })
      .catch(() => undefined);
  };

  return (
    <div className="space-y-8">
      <PageHeader
        description="Files enter a private intent-bound quarantine path. A trusted processor computes SHA-256 over the actual bytes, validates size and media type, promotes only verified originals, and records custody, audit, timeline, and traceability."
        title="Evidence"
      />
      <ProjectionList
        empty="No authorized Evidence metadata is visible."
        fields={[
          { key: 'evidence_number', label: 'Evidence' },
          { key: 'evidence_type', label: 'Type' },
          { key: 'target_type', label: 'Target type' },
          { key: 'target_id', label: 'Target ID' },
          { key: 'content_digest', label: 'SHA-256 digest' },
          { key: 'captured_at', label: 'Captured at' },
          { key: 'access_state', label: 'Access state' },
        ]}
        title="Evidence register"
        view="evidence_register"
      />
      {hasPermission('evidence.create') ? (
        <form className="card space-y-4" onSubmit={(event) => void submit(event)}>
          <div>
            <h2 className="section-title">Capture Evidence</h2>
            <p className="mt-1 text-sm text-muted">
              The browser never writes to Evidence originals. It can write only to the exact pending
              private intake path issued for this upload.
            </p>
          </div>
          <div className="grid gap-4 md:grid-cols-2">
            <div>
              <label className="field-label" htmlFor="evidence-target-type">
                Target type
              </label>
              <select
                className="field"
                id="evidence-target-type"
                onChange={(event) =>
                  setTargetType(event.target.value as EvidenceUploadInput['targetType'])
                }
                value={targetType}
              >
                <option value="case">Case</option>
                <option value="investigation">Investigation</option>
                <option value="incident">Incident</option>
                <option value="operation">Operation</option>
                <option value="workstep">Operational Task</option>
              </select>
            </div>
            <div>
              <label className="field-label" htmlFor="evidence-target-id">
                Target ID
              </label>
              <input
                className="field"
                id="evidence-target-id"
                onChange={(event) => setTargetId(event.target.value)}
                required
                value={targetId}
              />
            </div>
            <div>
              <label className="field-label" htmlFor="evidence-file">
                Private file
              </label>
              <input
                accept="image/jpeg,image/png,image/webp,application/pdf,video/mp4,audio/mpeg,audio/mp4,text/plain"
                className="field"
                id="evidence-file"
                onChange={(event) => setFile(event.target.files?.[0] ?? null)}
                required
                type="file"
              />
            </div>
            <div>
              <label className="field-label" htmlFor="evidence-type">
                Evidence type
              </label>
              <input
                className="field"
                id="evidence-type"
                onChange={(event) => setEvidenceType(event.target.value)}
                required
                value={evidenceType}
              />
            </div>
            <div className="md:col-span-2">
              <label className="field-label" htmlFor="evidence-relevance">
                Relevance to the target
              </label>
              <textarea
                className="field min-h-24"
                id="evidence-relevance"
                onChange={(event) => setRelevance(event.target.value)}
                required
                value={relevance}
              />
            </div>
            <div>
              <label className="field-label" htmlFor="evidence-capture-method">
                Capture method
              </label>
              <input
                className="field"
                id="evidence-capture-method"
                onChange={(event) => setCaptureMethod(event.target.value)}
                required
                value={captureMethod}
              />
            </div>
            <div>
              <label className="field-label" htmlFor="evidence-captured-at">
                Captured at
              </label>
              <input
                className="field"
                id="evidence-captured-at"
                onChange={(event) => setCapturedAt(event.target.value)}
                type="datetime-local"
                value={capturedAt}
              />
            </div>
            <div className="md:col-span-2">
              <label className="field-label" htmlFor="evidence-custodian">
                Custodian relationship ID
              </label>
              <input
                className="field"
                id="evidence-custodian"
                onChange={(event) => setCustodian(event.target.value)}
                value={custodian}
              />
            </div>
          </div>
          {validationError ? (
            <p className="error-message" role="alert">
              {validationError}
            </p>
          ) : upload.error ? (
            <p className="error-message" role="alert">
              {upload.error.message}
            </p>
          ) : null}
          {upload.data ? (
            <p className="notice" role="status">
              Evidence {upload.data.evidenceItemId} was digest-verified and captured.
            </p>
          ) : null}
          <button className="button-primary" disabled={upload.isPending} type="submit">
            {upload.isPending ? 'Hashing and processing…' : 'Capture private Evidence'}
          </button>
        </form>
      ) : null}
    </div>
  );
}
