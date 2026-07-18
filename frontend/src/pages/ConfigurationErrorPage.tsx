import { ErrorState } from '../components/feedback/ErrorState';

export function ConfigurationErrorPage() {
  return (
    <main className="grid min-h-screen place-items-center bg-surface px-6 text-ink">
      <ErrorState
        error={{
          kind: 'configuration',
          title: 'The application is not configured.',
          message:
            'A required public setting is missing or invalid. Ask the deployment owner to review the environment configuration.',
        }}
      />
    </main>
  );
}
