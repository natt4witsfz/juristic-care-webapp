import { Component, type ErrorInfo, type PropsWithChildren, type ReactNode } from 'react';

import { genericUnexpectedError } from '../../types/errors';
import { ErrorState } from './ErrorState';

interface ErrorBoundaryState {
  readonly error: Error | null;
}

export class ErrorBoundary extends Component<PropsWithChildren, ErrorBoundaryState> {
  public state: ErrorBoundaryState = { error: null };

  public static getDerivedStateFromError(error: Error): ErrorBoundaryState {
    return { error };
  }

  public componentDidCatch(error: Error, info: ErrorInfo): void {
    console.error('Unhandled interface error', { error, componentStack: info.componentStack });
  }

  public render(): ReactNode {
    if (this.state.error) {
      return (
        <main className="grid min-h-screen place-items-center bg-surface px-6 text-ink">
          <ErrorState
            action={() => window.location.reload()}
            actionLabel="Reload"
            error={genericUnexpectedError}
          />
        </main>
      );
    }

    return this.props.children;
  }
}
