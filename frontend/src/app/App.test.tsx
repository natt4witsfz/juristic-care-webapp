import { render, screen } from '@testing-library/react';

import { createTestRouter } from '../routes/router';
import { createAuthGateway } from '../test/fakes';
import { App } from './App';

describe('App', () => {
  it('renders the application shell and resolves the home route', async () => {
    render(<App authGateway={createAuthGateway()} router={createTestRouter(['/'])} />);

    expect(await screen.findByRole('heading', { name: /clear operational care/i })).toBeVisible();
  });
});
