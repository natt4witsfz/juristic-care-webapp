import axe from 'axe-core';
import { render, screen } from '@testing-library/react';
import { vi } from 'vitest';

import { App } from '../app/App';
import { createAuthGateway } from '../test/fakes';
import { createTestRouter } from './router';

vi.mock('../config/environment', () => ({
  getEnvironment: () => ({
    appEnvironment: 'test',
    appVersion: 'test-version',
    supabaseUrl: 'http://127.0.0.1:54321',
    supabasePublishableKey: 'test-publishable-key',
  }),
}));

describe('application routes', () => {
  const operationalRoutes = [
    ['/investigations', 'Investigations'],
    ['/incidents', 'Incidents'],
    ['/operations', 'Operations and Tasks'],
    ['/evidence', 'Evidence'],
    ['/notifications', 'Notifications'],
    ['/reports', 'Governed Reporting and Organizational Memory'],
    ['/offline', 'Offline Continuity'],
    ['/timeline', 'Immutable Timeline and Traceability'],
    ['/administration/permissions', 'Administration'],
  ] as const;

  it('renders the not-found page for an unknown path', async () => {
    render(
      <App authGateway={createAuthGateway()} router={createTestRouter(['/does-not-exist'])} />,
    );

    expect(await screen.findByRole('heading', { name: /page not found/i })).toBeVisible();
  });

  it('loads the public system-status page without revealing configuration values', async () => {
    render(<App authGateway={createAuthGateway()} router={createTestRouter(['/system-status'])} />);

    expect(await screen.findByRole('heading', { name: /system status/i })).toBeVisible();
    expect(screen.getByText('test-version')).toBeVisible();
    expect(screen.queryByText('test-publishable-key')).not.toBeInTheDocument();
  });

  it('renders the Supabase sign-in form without exposing configuration', async () => {
    render(<App authGateway={createAuthGateway()} router={createTestRouter(['/sign-in'])} />);

    expect(await screen.findByRole('heading', { name: /^sign in$/i })).toBeVisible();
    expect(screen.getByLabelText(/email/i)).toBeVisible();
    expect(screen.getByLabelText(/^password$/i)).toBeVisible();
    expect(screen.queryByText('test-publishable-key')).not.toBeInTheDocument();
  });

  it('redirects an anonymous user away from a protected workspace', async () => {
    render(<App authGateway={createAuthGateway()} router={createTestRouter(['/workspace'])} />);
    expect(await screen.findByRole('heading', { name: /^sign in$/i })).toBeVisible();
  });

  for (const [path, heading] of operationalRoutes) {
    it(`loads the protected ${path} vertical slice for an authorized administrator`, async () => {
      const authGateway = createAuthGateway({
        user: { id: 'auth-user-1', email: 'admin@example.test' },
        access: {
          juristicPersonId: 'tenant-1',
          personId: 'person-1',
          displayName: 'Test Administrator',
          roles: ['admin'],
          permissions: [],
        },
      });

      render(<App authGateway={authGateway} router={createTestRouter([path])} />);

      expect(await screen.findByRole('heading', { name: heading })).toBeVisible();
      const results = await axe.run(document.body, {
        rules: { 'color-contrast': { enabled: false } },
      });
      expect(results.violations.map(({ id, nodes }) => ({ id, nodes: nodes.length }))).toEqual([]);
    });
  }
});
