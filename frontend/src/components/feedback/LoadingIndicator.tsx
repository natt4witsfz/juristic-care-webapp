interface LoadingIndicatorProps {
  readonly label?: string | undefined;
}

export function LoadingIndicator({ label = 'Loading' }: LoadingIndicatorProps) {
  return (
    <span className="inline-flex items-center gap-2" role="status">
      <span className="size-4 animate-spin rounded-full border-2 border-current border-r-transparent" />
      <span>{label}</span>
    </span>
  );
}
