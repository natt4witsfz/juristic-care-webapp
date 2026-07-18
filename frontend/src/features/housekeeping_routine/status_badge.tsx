import { TASK_STATUS_META } from './housekeeping_status';
import type { TaskStatus } from './housekeeping_types';

interface StatusBadgeProps {
  readonly status: TaskStatus;
  readonly compact?: boolean;
}

export function StatusBadge({ status, compact = false }: StatusBadgeProps) {
  const meta = TASK_STATUS_META[status];
  return (
    <span
      className={`hk-status hk-status--${status}${compact ? ' hk-status--compact' : ''}`}
      title={meta.description}
    >
      <span aria-hidden="true" className="hk-status__icon">
        {meta.icon}
      </span>
      <span>{meta.label}</span>
      {!compact ? <small>{meta.label_en}</small> : null}
    </span>
  );
}
