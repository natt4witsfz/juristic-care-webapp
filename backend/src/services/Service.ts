export interface ServiceContext {
  readonly correlationId: string;
  readonly signal?: AbortSignal;
}

export interface Service<TInput, TOutput> {
  execute(input: TInput, context: ServiceContext): Promise<TOutput>;
}
