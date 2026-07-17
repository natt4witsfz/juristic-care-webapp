import { useState, type FormEvent } from 'react';

import { PageHeader } from '../components/layout/PageHeader';
import { useAuth } from '../features/auth/useAuth';

export function ForgotPasswordPage() {
  const auth = useAuth();
  const [email, setEmail] = useState('');
  const [message, setMessage] = useState<string | null>(null);
  const [error, setError] = useState<string | null>(null);

  const submit = async (event: FormEvent) => {
    event.preventDefault();
    setError(null);
    try {
      await auth.requestPasswordReset(email.trim(), `${window.location.origin}/reset-password`);
      setMessage('If the account exists, password-reset instructions have been sent.');
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Unable to request a password reset.');
    }
  };

  return (
    <div className="mx-auto max-w-md space-y-6">
      <PageHeader
        description="For privacy, the response is the same whether or not an account exists."
        title="Reset your password"
      />
      <form className="card space-y-4" onSubmit={(event) => void submit(event)}>
        <label className="field-label" htmlFor="reset-email">
          Email
        </label>
        <input
          className="field"
          id="reset-email"
          onChange={(e) => setEmail(e.target.value)}
          required
          type="email"
          value={email}
        />
        {message ? (
          <p className="notice" role="status">
            {message}
          </p>
        ) : null}
        {error ? (
          <p className="error-message" role="alert">
            {error}
          </p>
        ) : null}
        <button className="button-primary w-full" type="submit">
          Send reset instructions
        </button>
      </form>
    </div>
  );
}
