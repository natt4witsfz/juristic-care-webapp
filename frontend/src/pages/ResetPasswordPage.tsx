import { useState, type FormEvent } from 'react';
import { useNavigate } from 'react-router-dom';

import { PageHeader } from '../components/layout/PageHeader';
import { useAuth } from '../features/auth/useAuth';

export function ResetPasswordPage() {
  const auth = useAuth();
  const navigate = useNavigate();
  const [password, setPassword] = useState('');
  const [confirmation, setConfirmation] = useState('');
  const [error, setError] = useState<string | null>(null);

  const submit = async (event: FormEvent) => {
    event.preventDefault();
    if (password !== confirmation) return setError('Passwords do not match.');
    if (password.length < 10) return setError('Password must contain at least 10 characters.');
    try {
      await auth.updatePassword(password);
      navigate('/profile', { replace: true });
    } catch (cause) {
      setError(cause instanceof Error ? cause.message : 'Unable to update the password.');
    }
  };

  return (
    <div className="mx-auto max-w-md space-y-6">
      <PageHeader
        description="Open this page from the secure recovery link sent to your email."
        title="Choose a new password"
      />
      <form className="card space-y-4" onSubmit={(event) => void submit(event)}>
        <label className="field-label" htmlFor="new-password">
          New password
        </label>
        <input
          className="field"
          id="new-password"
          minLength={10}
          onChange={(e) => setPassword(e.target.value)}
          required
          type="password"
          value={password}
        />
        <label className="field-label" htmlFor="confirm-password">
          Confirm password
        </label>
        <input
          className="field"
          id="confirm-password"
          minLength={10}
          onChange={(e) => setConfirmation(e.target.value)}
          required
          type="password"
          value={confirmation}
        />
        {error ? (
          <p className="error-message" role="alert">
            {error}
          </p>
        ) : null}
        <button className="button-primary w-full" type="submit">
          Update password
        </button>
      </form>
    </div>
  );
}
