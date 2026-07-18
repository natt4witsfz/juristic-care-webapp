import { isRouteErrorResponse, Link, useRouteError } from 'react-router-dom';

import { genericUnexpectedError } from '../../types/errors';
import { ErrorState } from './ErrorState';

export function RouteErrorPage() {
  const error = useRouteError();
  const routeError = isRouteErrorResponse(error)
    ? {
        ...genericUnexpectedError,
        title: `The route could not be displayed (${error.status}).`,
      }
    : genericUnexpectedError;

  return (
    <main className="grid min-h-screen place-items-center bg-surface px-6 text-ink">
      <div>
        <ErrorState error={routeError} />
        <Link className="link mt-5 inline-block" to="/">
          Return home
        </Link>
      </div>
    </main>
  );
}
