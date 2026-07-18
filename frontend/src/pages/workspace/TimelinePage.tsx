import { ProjectionList } from '../../components/common/ProjectionList';
import { PageHeader } from '../../components/layout/PageHeader';

export function TimelinePage() {
  return (
    <div className="space-y-8">
      <PageHeader
        description="Every important change preserves previous state, current state, reason, occurred time, recorded time, Decision, Mandate, Evidence Package, and correlation identity."
        title="Immutable Timeline and Traceability"
      />
      <ProjectionList
        empty="No authorized state transitions are visible."
        fields={[
          { key: 'aggregate_type', label: 'Aggregate type' },
          { key: 'aggregate_id', label: 'Aggregate ID' },
          { key: 'previous_state', label: 'Previous state' },
          { key: 'current_state', label: 'Current state' },
          { key: 'reason', label: 'Reason' },
          { key: 'decision_id', label: 'Decision' },
          { key: 'mandate_id', label: 'Mandate' },
          { key: 'occurred_at', label: 'Occurred' },
          { key: 'recorded_at', label: 'Recorded' },
          { key: 'correlation_id', label: 'Correlation' },
        ]}
        title="State evolution"
        view="aggregate_timeline"
      />
      <ProjectionList
        empty="No Responsibility history is visible."
        fields={[
          { key: 'assignment_code', label: 'Responsibility' },
          { key: 'scope_type', label: 'Scope type' },
          { key: 'scope_id', label: 'Scope' },
          { key: 'responsible_relationship_id', label: 'Responsible relationship' },
          { key: 'entry_type', label: 'Ledger event' },
          { key: 'handover_id', label: 'Handover' },
          { key: 'occurred_at', label: 'Occurred' },
        ]}
        title="Responsibility Chain"
        view="responsibility_chain"
      />
    </div>
  );
}
