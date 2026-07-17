import { useState, type FormEvent } from 'react';

import { ErrorState } from '../../components/feedback/ErrorState';
import { LoadingIndicator } from '../../components/feedback/LoadingIndicator';
import { PageHeader } from '../../components/layout/PageHeader';
import { useAuth } from '../../features/auth/useAuth';
import { useCreateCase, useCreateInvestigation, useDashboard } from '../../features/domain/hooks';

export function CasesPage() {
  const { access, hasPermission } = useAuth();
  const dashboard = useDashboard();
  const createCase = useCreateCase();
  const createInvestigation = useCreateInvestigation();
  const [description, setDescription] = useState('');
  const [location, setLocation] = useState('');
  const [questionByCase, setQuestionByCase] = useState<Record<string, string>>({});

  const submit = async (event: FormEvent) => {
    event.preventDefault();
    if (!access) return;
    await createCase.mutateAsync({
      juristicPersonId: access.juristicPersonId,
      channel: access.roles.includes('resident')
        ? 'resident_form'
        : access.roles.some((role) => role === 'head_technician' || role === 'technician')
          ? 'technician_finding'
          : access.roles.includes('security')
            ? 'security_report'
            : 'juristic_staff_intake',
      submittedText: description,
      ...(location ? { submittedLocationText: location } : {}),
    });
    setDescription('');
    setLocation('');
  };

  if (dashboard.isLoading) return <LoadingIndicator label="Loading Cases" />;
  if (dashboard.isError)
    return (
      <ErrorState
        error={{ kind: 'network', title: 'Cases unavailable', message: dashboard.error.message }}
      />
    );
  const mayCreate = hasPermission('case.create') || access?.roles.includes('resident');
  return (
    <div className="space-y-8">
      <PageHeader
        description="Every submitted report creates a separate Case. Similar reports are associated only through Investigation."
        title="Cases"
      />
      {mayCreate ? (
        <form className="card space-y-4" onSubmit={(event) => void submit(event)}>
          <h2 className="section-title">Create a separate Case</h2>
          <label className="field-label" htmlFor="case-description">
            What was observed?
          </label>
          <textarea
            className="field min-h-28"
            id="case-description"
            onChange={(e) => setDescription(e.target.value)}
            required
            value={description}
          />
          <label className="field-label" htmlFor="case-location">
            Reported location
          </label>
          <input
            className="field"
            id="case-location"
            onChange={(e) => setLocation(e.target.value)}
            value={location}
          />
          {createCase.error ? (
            <p className="error-message" role="alert">
              {createCase.error.message}
            </p>
          ) : null}
          {createCase.data ? (
            <p className="notice" role="status">
              Created {createCase.data.caseNumber}. The original report remains independently
              traceable.
            </p>
          ) : null}
          <button className="button-primary" disabled={createCase.isPending} type="submit">
            {createCase.isPending ? 'Creating…' : 'Create Case'}
          </button>
        </form>
      ) : null}
      <section className="card">
        <h2 className="section-title">Visible Cases</h2>
        <div className="mt-4 space-y-4">
          {(dashboard.data?.cases ?? []).map((item) => (
            <article className="list-item" key={item.id}>
              <h3>{item.caseNumber}</h3>
              <p>{item.currentSummary || 'No current summary recorded.'}</p>
              <small>
                {item.currentState} · opened {new Date(item.openedAt).toLocaleString()}
              </small>
              {hasPermission('investigation.manage') ? (
                <form
                  className="mt-3 flex gap-2"
                  onSubmit={(event) => {
                    event.preventDefault();
                    const question = questionByCase[item.id];
                    if (access && question)
                      void createInvestigation.mutateAsync({
                        juristicPersonId: access.juristicPersonId,
                        caseId: item.id,
                        question,
                      });
                  }}
                >
                  <input
                    aria-label={`Investigation question for ${item.caseNumber}`}
                    className="field"
                    onChange={(e) =>
                      setQuestionByCase((current) => ({ ...current, [item.id]: e.target.value }))
                    }
                    placeholder="Investigation question"
                    value={questionByCase[item.id] ?? ''}
                  />
                  <button className="button-secondary" type="submit">
                    Start Investigation
                  </button>
                </form>
              ) : null}
            </article>
          ))}
          {(dashboard.data?.cases.length ?? 0) === 0 ? (
            <p className="text-muted">No Cases are visible to your effective role.</p>
          ) : null}
        </div>
      </section>
    </div>
  );
}
