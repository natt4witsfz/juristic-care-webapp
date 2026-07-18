import { z } from 'zod';

const publicEnvironmentSchema = z.object({
  appEnvironment: z.enum(['development', 'test', 'staging', 'production']),
  appVersion: z.string().min(1).default('unversioned'),
  supabaseUrl: z.url(),
  supabasePublishableKey: z.string().min(1),
});

export interface PublicEnvironmentInput {
  readonly appEnvironment: string | undefined;
  readonly appVersion?: string | undefined;
  readonly supabaseUrl: string | undefined;
  readonly supabasePublishableKey: string | undefined;
}

export type PublicEnvironment = Readonly<z.infer<typeof publicEnvironmentSchema>>;

export class PublicEnvironmentError extends Error {
  public constructor(readonly fields: readonly string[]) {
    super(`Invalid public environment configuration: ${fields.join(', ')}`);
    this.name = 'PublicEnvironmentError';
  }
}

export function createPublicEnvironment(input: PublicEnvironmentInput): PublicEnvironment {
  const result = publicEnvironmentSchema.safeParse(input);

  if (!result.success) {
    const fields = [
      ...new Set(result.error.issues.map((issue) => issue.path.join('.') || 'input')),
    ];
    throw new PublicEnvironmentError(fields);
  }

  return Object.freeze(result.data);
}
