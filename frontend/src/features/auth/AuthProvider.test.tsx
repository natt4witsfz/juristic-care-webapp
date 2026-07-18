import { render, screen, waitFor } from '@testing-library/react';

import { createAuthGateway } from '../../test/fakes';
import { AuthProvider } from './AuthProvider';
import { useAuth } from './useAuth';

function Probe() {
  const auth = useAuth();
  return <div>{auth.loading ? 'loading' : auth.access?.roles.join(',') || 'anonymous'}</div>;
}

describe('AuthProvider', () => {
  it('resolves database-owned roles independently from Auth identity', async () => {
    const gateway = createAuthGateway({
      user: { id: 'auth-user', email: 'manager@example.test' },
      access: {
        juristicPersonId: 'tenant',
        personId: 'person',
        displayName: 'Manager',
        roles: ['juristic_manager'],
        permissions: ['case.create'],
      },
    });
    render(
      <AuthProvider gateway={gateway}>
        <Probe />
      </AuthProvider>,
    );
    await waitFor(() => expect(screen.getByText('juristic_manager')).toBeVisible());
  });
});
