import { LoadingIndicator } from './LoadingIndicator';

interface FullPageLoaderProps {
  readonly label?: string;
}

export function FullPageLoader({ label }: FullPageLoaderProps) {
  return (
    <main className="grid min-h-screen place-items-center bg-surface text-ink">
      <LoadingIndicator label={label} />
    </main>
  );
}
