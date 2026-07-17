import { Link } from 'react-router-dom';

export function NotFoundPage() {
  return (
    <section className="max-w-xl" aria-labelledby="not-found-title">
      <p className="text-sm font-semibold text-brand-strong">404</p>
      <h1 id="not-found-title" className="mt-2 text-3xl font-semibold">
        Page not found
      </h1>
      <p className="mt-3 text-muted">The requested workspace route does not exist.</p>
      <Link className="link mt-6 inline-block" to="/">
        Return to workspace
      </Link>
    </section>
  );
}
