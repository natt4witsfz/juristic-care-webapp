export type ApplicationErrorKind =
  'authentication' | 'configuration' | 'network' | 'unexpected' | 'validation';

export interface ApplicationError {
  readonly kind: ApplicationErrorKind;
  readonly title: string;
  readonly message: string;
  readonly reference?: string;
}

export const genericUnexpectedError: ApplicationError = {
  kind: 'unexpected',
  title: 'This workspace could not be displayed.',
  message: 'Refresh the page. If the problem continues, report the time and action to support.',
};
