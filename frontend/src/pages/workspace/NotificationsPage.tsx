import { ErrorState } from '../../components/feedback/ErrorState';
import { LoadingIndicator } from '../../components/feedback/LoadingIndicator';
import { PageHeader } from '../../components/layout/PageHeader';
import { useAuth } from '../../features/auth/useAuth';
import { useDomainCommand, useProjection } from '../../features/domain/hooks';

export function NotificationsPage() {
  const { access } = useAuth();
  const query = useProjection('notification_center');
  const acknowledge = useDomainCommand('acknowledge_notification');
  return (
    <div className="space-y-8">
      <PageHeader
        description="Notifications are routed from immutable domain events to the explicit responsible relationship. Delivery does not create Authority, Responsibility, or proof of attention."
        title="Notifications"
      />
      {query.isLoading ? (
        <LoadingIndicator label="Loading notifications" />
      ) : query.isError ? (
        <ErrorState
          error={{
            kind: 'network',
            title: 'Notifications unavailable',
            message: query.error.message,
          }}
        />
      ) : (
        <section className="card space-y-3" aria-live="polite">
          {(query.data ?? []).map((row) => (
            <article className="list-item" key={String(row.notification_intent_id)}>
              <h2>{String(row.subject ?? row.event_type)}</h2>
              <p className="break-words">{JSON.stringify(row.payload ?? {})}</p>
              <small>
                {String(row.urgency)} · occurred{' '}
                {new Date(String(row.occurred_at)).toLocaleString()}
              </small>
              {Boolean(row.required_acknowledgement) && !row.acknowledgement_id && access ? (
                <button
                  className="button-secondary mt-3"
                  disabled={acknowledge.isPending}
                  onClick={() =>
                    acknowledge.mutate({
                      p_juristic_person_id: access.juristicPersonId,
                      p_audience_id: row.audience_id,
                      p_method: 'in_app',
                      p_occurred_at: new Date().toISOString(),
                    })
                  }
                  type="button"
                >
                  Acknowledge
                </button>
              ) : null}
              {row.acknowledgement_id ? (
                <p className="notice mt-3">
                  Acknowledged {new Date(String(row.acknowledged_at)).toLocaleString()}
                </p>
              ) : null}
            </article>
          ))}
          {(query.data?.length ?? 0) === 0 ? (
            <p className="text-muted">No Responsibility-routed notifications are pending.</p>
          ) : null}
          {acknowledge.error ? (
            <p className="error-message" role="alert">
              {acknowledge.error.message}
            </p>
          ) : null}
        </section>
      )}
    </div>
  );
}
