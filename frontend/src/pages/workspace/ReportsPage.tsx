import { useState, type FormEvent } from 'react';

import { ProjectionList } from '../../components/common/ProjectionList';
import { PageHeader } from '../../components/layout/PageHeader';
import { useAuth } from '../../features/auth/useAuth';
import { useTrustedWorkflow } from '../../features/domain/hooks';

export function ReportsPage() {
  const { access, hasPermission } = useAuth();
  const workflow = useTrustedWorkflow('memory-transfer');
  const [custodian, setCustodian] = useState('');
  const [reportCode, setReportCode] = useState('operational-overview');
  const [periodStart, setPeriodStart] = useState('');
  const [periodEnd, setPeriodEnd] = useState('');
  const [importFile, setImportFile] = useState<File | null>(null);
  const [validationError, setValidationError] = useState<string | null>(null);
  const submit = async (event: FormEvent) => {
    event.preventDefault();
    if (!access) return;
    setValidationError(null);
    if (periodStart && periodEnd && new Date(periodEnd) < new Date(periodStart)) {
      setValidationError('Report period end must not be before period start.');
      return;
    }
    await workflow
      .mutateAsync({
        action: 'export',
        juristicPersonId: access.juristicPersonId,
        custodianRelationshipId: custodian,
        reportCode,
        periodStart: periodStart ? new Date(periodStart).toISOString() : null,
        periodEnd: periodEnd ? new Date(periodEnd).toISOString() : null,
        scopeDefinition: { reportCode, purpose: 'governed_operational_reporting' },
      })
      .catch(() => undefined);
  };
  const validateImport = async (event: FormEvent) => {
    event.preventDefault();
    if (!access || !importFile) return;
    setValidationError(null);
    if (importFile.size > 20_000_000) {
      setValidationError('Memory import validation is limited to 20 MB per artifact.');
      return;
    }
    let archiveBase64: string;
    try {
      archiveBase64 = await new Promise<string>((resolve, reject) => {
        const reader = new FileReader();
        reader.onload = () => resolve(String(reader.result).split(',')[1] ?? '');
        reader.onerror = () =>
          reject(reader.error ?? new Error('Memory artifact could not be read.'));
        reader.readAsDataURL(importFile);
      });
    } catch (error) {
      setValidationError(
        error instanceof Error ? error.message : 'Memory artifact could not be read.',
      );
      return;
    }
    await workflow
      .mutateAsync({
        action: 'import_validation',
        juristicPersonId: access.juristicPersonId,
        custodianRelationshipId: custodian,
        scopeDefinition: {
          purpose: 'organizational_memory_import_validation',
          filename: importFile.name,
        },
        archiveBase64,
      })
      .catch(() => undefined);
  };
  return (
    <div className="space-y-8">
      <PageHeader
        description="Issued reports are immutable snapshots with as-of time, source manifest, private content reference, SHA-256 digest, publisher, and restatement lineage. Organizational Memory belongs to the juristic person."
        title="Governed Reporting and Organizational Memory"
      />
      <ProjectionList
        empty="No issued report snapshots are visible."
        fields={[
          { key: 'report_code', label: 'Report' },
          { key: 'report_version', label: 'Version' },
          { key: 'as_of_at', label: 'As of' },
          { key: 'source_manifest_id', label: 'Source manifest' },
          { key: 'content_digest', label: 'Digest' },
          { key: 'restates_snapshot_id', label: 'Restates' },
        ]}
        title="Issued reports"
        view="governed_reports"
      />
      <ProjectionList
        empty="No Memory transfer manifests are visible."
        fields={[
          { key: 'manifest_code', label: 'Manifest' },
          { key: 'manifest_type', label: 'Type' },
          { key: 'manifest_state', label: 'State' },
          { key: 'as_of_at', label: 'As of' },
          { key: 'item_count', label: 'Items' },
          { key: 'content_digest', label: 'Digest' },
        ]}
        title="Memory transfer catalog"
        view="memory_transfer_catalog"
      />
      {hasPermission('report.read') ? (
        <>
          <form className="card space-y-4" onSubmit={(event) => void submit(event)}>
            <h2 className="section-title">Issue governed operational snapshot</h2>
            <p className="text-sm text-muted">
              The trusted workflow exports only RLS-authorized projections, computes the artifact
              digest, stores bytes privately, seals a manifest, and issues the snapshot.
            </p>
            <label className="field-label" htmlFor="report-custodian">
              Custodian relationship ID
            </label>
            <input
              className="field"
              id="report-custodian"
              onChange={(event) => setCustodian(event.target.value)}
              required
              value={custodian}
            />
            <label className="field-label" htmlFor="report-code">
              Report code
            </label>
            <input
              className="field"
              id="report-code"
              onChange={(event) => setReportCode(event.target.value)}
              required
              value={reportCode}
            />
            <div className="grid gap-4 md:grid-cols-2">
              <div>
                <label className="field-label" htmlFor="report-start">
                  Period start
                </label>
                <input
                  className="field"
                  id="report-start"
                  onChange={(event) => setPeriodStart(event.target.value)}
                  type="datetime-local"
                  value={periodStart}
                />
              </div>
              <div>
                <label className="field-label" htmlFor="report-end">
                  Period end
                </label>
                <input
                  className="field"
                  id="report-end"
                  onChange={(event) => setPeriodEnd(event.target.value)}
                  type="datetime-local"
                  value={periodEnd}
                />
              </div>
            </div>
            {validationError ? (
              <p className="error-message" role="alert">
                {validationError}
              </p>
            ) : workflow.error ? (
              <p className="error-message" role="alert">
                {workflow.error.message}
              </p>
            ) : null}
            {workflow.isSuccess ? (
              <p className="notice" role="status">
                The private Memory manifest and report snapshot were sealed.
              </p>
            ) : null}
            <button className="button-primary" disabled={workflow.isPending} type="submit">
              {workflow.isPending ? 'Building and sealing…' : 'Issue governed snapshot'}
            </button>
          </form>
          <form className="card space-y-4" onSubmit={(event) => void validateImport(event)}>
            <h2 className="section-title">Validate Organizational Memory import</h2>
            <p className="text-sm text-muted">
              Validation checks format, schema version, juristic-person ownership, and content
              digests. It never imports or overwrites authoritative records automatically.
            </p>
            <label className="field-label" htmlFor="memory-import">
              Memory artifact
            </label>
            <input
              accept="application/json"
              className="field"
              id="memory-import"
              onChange={(event) => setImportFile(event.target.files?.[0] ?? null)}
              required
              type="file"
            />
            <button
              className="button-secondary"
              disabled={workflow.isPending || !importFile || !custodian}
              type="submit"
            >
              Validate private Memory artifact
            </button>
          </form>
        </>
      ) : null}
    </div>
  );
}
