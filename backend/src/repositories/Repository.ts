export interface RepositoryQuery {
  readonly signal?: AbortSignal;
  readonly correlationId?: string;
}

export interface Repository<TEntity, TIdentifier> {
  findById(identifier: TIdentifier, query?: RepositoryQuery): Promise<TEntity | null>;
}
