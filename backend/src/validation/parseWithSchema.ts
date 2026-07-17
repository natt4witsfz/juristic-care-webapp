import type { ZodType } from 'zod';

export function parseWithSchema<TOutput>(schema: ZodType<TOutput>, input: unknown): TOutput {
  return schema.parse(input);
}
