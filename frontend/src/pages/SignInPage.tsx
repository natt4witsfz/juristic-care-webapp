import { useState, type FormEvent } from 'react';
import { Link, Navigate, useLocation, useNavigate } from 'react-router-dom';

import { PageHeader } from '../components/layout/PageHeader';
import { useAuth } from '../features/auth/useAuth';

export function SignInPage() {
  const auth = useAuth();
  const navigate = useNavigate();
  const location = useLocation();
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState<string | null>(null);
  const [submitting, setSubmitting] = useState(false);

  if (!auth.loading && auth.user) return <Navigate replace to="/workspace" />;

  const submit = async (event: FormEvent) => {
    event.preventDefault();
    setSubmitting(true);
    setError(null);
    try {
      await auth.signIn(email.trim(), password);
      const from = (location.state as { from?: string } | null)?.from;
      navigate(from?.startsWith('/') ? from : '/workspace', { replace: true });
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Sign in failed.');
    } finally {
      setSubmitting(false);
    }
  };

  return (
    <div className="mx-auto max-w-md space-y-6">
      <PageHeader description="Use the account invited by your Juristic Person." title="Sign in" />
      <form className="card space-y-4" onSubmit={(event) => void submit(event)}>
        <label className="field-label" htmlFor="email">
          Email
        </label>
        <input
          className="field"
          id="email"
          onChange={(e) => setEmail(e.target.value)}
          required
          type="email"
          value={email}
        />
        <label className="field-label" htmlFor="password">
          Password
        </label>
        <input
          className="field"
          id="password"
          minLength={10}
          onChange={(e) => setPassword(e.target.value)}
          required
          type="password"
          value={password}
        />
        {error ? (
          <p className="error-message" role="alert">
            {error}
          </p>
        ) : null}
        <button className="button-primary w-full" disabled={submitting} type="submit">
          {submitting ? 'Signing in…' : 'Sign in'}
        </button>
        <Link className="link block text-center text-sm" to="/forgot-password">
          Forgot password?
        </Link>
      </form>
    </div>
  );
}
