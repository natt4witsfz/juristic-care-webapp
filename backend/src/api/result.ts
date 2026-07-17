export interface ApiSuccess<TData> {
  readonly ok: true;
  readonly data: TData;
  readonly correlationId: string;
}

export interface ApiFailure {
  readonly ok: false;
  readonly code: string;
  readonly message: string;
  readonly correlationId: string;
}

export type ApiResult<TData> = ApiSuccess<TData> | ApiFailure;
