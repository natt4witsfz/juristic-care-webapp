import type { ApplicationError } from '../../types/errors';

interface ErrorStateProps {
  readonly error: ApplicationError;
  readonly action?: (() => void) | undefined;
  readonly actionLabel?: string | undefined;
}

export function ErrorState({ error, action, actionLabel = 'Try again' }: ErrorStateProps) {
  return (
    <section
      aria-labelledby={`${error.kind}-error-title`}
      className="w-full max-w-lg rounded-2xl border border-danger/20 bg-panel p-8 shadow-sm"
      role="alert"
    >
      <p className="text-sm font-semibold uppercase tracking-wide text-danger">
        {error.kind.replace('-', ' ')} error
      </p>
      <h1 className="mt-2 text-2xl font-semibold" id={`${error.kind}-error-title`}>
        {error.title}
      </h1>
      <p className="mt-3 text-sm leading-6 text-muted">{error.message}</p>
      {error.reference ? (
        <p className="mt-3 text-xs text-muted">Reference: {error.reference}</p>
      ) : null}
      {action ? (
        <button className="button-primary mt-6" onClick={action} type="button">
          {actionLabel}
        </button>
      ) : null}
    </section>
  );
}
