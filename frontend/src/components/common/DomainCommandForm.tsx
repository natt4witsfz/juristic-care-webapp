import { useState, type FormEvent } from 'react';

import { useAuth } from '../../features/auth/useAuth';
import { useDomainCommand } from '../../features/domain/hooks';

export interface CommandField {
  readonly name: string;
  readonly label: string;
  readonly type?:
    'text' | 'textarea' | 'number' | 'datetime-local' | 'select' | 'checkbox' | 'json' | 'array';
  readonly required?: boolean;
  readonly placeholder?: string;
  readonly options?: readonly { readonly value: string; readonly label: string }[];
  readonly defaultValue?: string | boolean;
  readonly help?: string;
}

export function DomainCommandForm({
  command,
  description,
  fields,
  title,
}: {
  readonly command: string;
  readonly description: string;
  readonly fields: readonly CommandField[];
  readonly title: string;
}) {
  const { access } = useAuth();
  const mutation = useDomainCommand(command);
  const [values, setValues] = useState<Record<string, string | boolean>>(() =>
    Object.fromEntries(fields.map((field) => [field.name, field.defaultValue ?? ''])),
  );
  const [validationError, setValidationError] = useState<string | null>(null);

  const submit = async (event: FormEvent<HTMLFormElement>) => {
    event.preventDefault();
    if (!access) return;
    setValidationError(null);
    const parameters: Record<string, unknown> = { p_juristic_person_id: access.juristicPersonId };
    try {
      for (const field of fields) {
        const value = values[field.name];
        if (field.type === 'checkbox') parameters[field.name] = Boolean(value);
        else if (value === '') parameters[field.name] = null;
        else if (field.type === 'number') {
          const number = Number(value);
          if (!Number.isFinite(number)) throw new Error(`${field.label} must be a valid number.`);
          parameters[field.name] = number;
        } else if (field.type === 'json') parameters[field.name] = JSON.parse(String(value));
        else if (field.type === 'array')
          parameters[field.name] = String(value)
            .split(',')
            .map((item) => item.trim())
            .filter(Boolean);
        else if (field.type === 'datetime-local') {
          const date = new Date(String(value));
          if (Number.isNaN(date.getTime())) throw new Error(`${field.label} is not a valid date.`);
          parameters[field.name] = date.toISOString();
        } else parameters[field.name] = value;
      }
    } catch (error) {
      setValidationError(
        error instanceof SyntaxError
          ? 'JSON fields must contain valid JSON.'
          : error instanceof Error
            ? error.message
            : 'The command input is invalid.',
      );
      return;
    }
    await mutation.mutateAsync(parameters).catch(() => undefined);
  };

  return (
    <form className="card space-y-4" onSubmit={(event) => void submit(event)}>
      <div>
        <h2 className="section-title">{title}</h2>
        <p className="mt-1 text-sm text-muted">{description}</p>
      </div>
      <div className="grid gap-4 md:grid-cols-2">
        {fields.map((field) => {
          const id = `${command}-${field.name}`;
          const value = values[field.name] ?? '';
          return (
            <div
              className={field.type === 'textarea' || field.type === 'json' ? 'md:col-span-2' : ''}
              key={field.name}
            >
              {field.type === 'checkbox' ? (
                <label className="flex items-center gap-2" htmlFor={id}>
                  <input
                    checked={Boolean(value)}
                    id={id}
                    onChange={(event) =>
                      setValues((current) => ({ ...current, [field.name]: event.target.checked }))
                    }
                    type="checkbox"
                  />
                  <span>{field.label}</span>
                </label>
              ) : (
                <>
                  <label className="field-label" htmlFor={id}>
                    {field.label}
                  </label>
                  {field.type === 'textarea' || field.type === 'json' ? (
                    <textarea
                      aria-describedby={field.help ? `${id}-help` : undefined}
                      className="field min-h-24"
                      id={id}
                      onChange={(event) =>
                        setValues((current) => ({ ...current, [field.name]: event.target.value }))
                      }
                      placeholder={field.placeholder}
                      required={field.required}
                      value={String(value)}
                    />
                  ) : field.type === 'select' ? (
                    <select
                      className="field"
                      id={id}
                      onChange={(event) =>
                        setValues((current) => ({ ...current, [field.name]: event.target.value }))
                      }
                      required={field.required}
                      value={String(value)}
                    >
                      <option value="">Select…</option>
                      {field.options?.map((option) => (
                        <option key={option.value} value={option.value}>
                          {option.label}
                        </option>
                      ))}
                    </select>
                  ) : (
                    <input
                      className="field"
                      id={id}
                      onChange={(event) =>
                        setValues((current) => ({ ...current, [field.name]: event.target.value }))
                      }
                      placeholder={field.placeholder}
                      required={field.required}
                      type={field.type ?? 'text'}
                      value={String(value)}
                    />
                  )}
                  {field.help ? (
                    <p className="mt-1 text-xs text-muted" id={`${id}-help`}>
                      {field.help}
                    </p>
                  ) : null}
                </>
              )}
            </div>
          );
        })}
      </div>
      {validationError ? (
        <p className="error-message" role="alert">
          {validationError}
        </p>
      ) : mutation.error ? (
        <p className="error-message" role="alert">
          {mutation.error.message}
        </p>
      ) : null}
      {mutation.isSuccess ? (
        <p className="notice" role="status">
          Command accepted. The projection, immutable timeline, audit, and notifications are
          refreshing.
        </p>
      ) : null}
      <button className="button-primary" disabled={mutation.isPending} type="submit">
        {mutation.isPending ? 'Recording…' : title}
      </button>
    </form>
  );
}
