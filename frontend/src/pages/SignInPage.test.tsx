import { fireEvent, render, screen, waitFor } from '@testing-library/react';
import { MemoryRouter } from 'react-router-dom';
import { vi } from 'vitest';

import { AuthProvider } from '../features/auth/AuthProvider';
import { createAuthGateway } from '../test/fakes';
import { SignInPage } from './SignInPage';

describe('SignInPage', () => {
  it('submits credentials through the Auth gateway without exposing them in application state', async () => {
    const signIn = vi.fn().mockResolvedValue(undefined);
    const gateway = { ...createAuthGateway(), signIn };
    render(
      <MemoryRouter>
        <AuthProvider gateway={gateway}>
          <SignInPage />
        </AuthProvider>
      </MemoryRouter>,
    );

    fireEvent.change(await screen.findByLabelText(/email/i), {
      target: { value: 'resident@example.test' },
    });
    fireEvent.change(screen.getByLabelText(/^password$/i), {
      target: { value: 'not-a-real-password' },
    });
    fireEvent.click(screen.getByRole('button', { name: /^sign in$/i }));

    await waitFor(() =>
      expect(signIn).toHaveBeenCalledWith('resident@example.test', 'not-a-real-password'),
    );
  });
});
