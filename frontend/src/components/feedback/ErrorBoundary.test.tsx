import { render, screen } from '@testing-library/react';
import { vi } from 'vitest';

import { ErrorBoundary } from './ErrorBoundary';

function ThrowingComponent(): never {
  throw new Error('sensitive implementation detail');
}

describe('ErrorBoundary', () => {
  it('shows a safe fallback without exposing the underlying error', () => {
    const consoleError = vi.spyOn(console, 'error').mockImplementation(() => undefined);

    render(
      <ErrorBoundary>
        <ThrowingComponent />
      </ErrorBoundary>,
    );

    expect(screen.getByRole('alert')).toHaveTextContent(/workspace could not be displayed/i);
    expect(screen.queryByText(/sensitive implementation detail/i)).not.toBeInTheDocument();
    consoleError.mockRestore();
  });
});
