import { DomainCommandForm } from '../../components/common/DomainCommandForm';
import { ProjectionList } from '../../components/common/ProjectionList';
import { PageHeader } from '../../components/layout/PageHeader';
import { useAuth } from '../../features/auth/useAuth';

const authorityFields = [
  { key: 'role_assignment_id', label: 'Acting role assignment' },
  { key: 'mandate_id', label: 'Mandate' },
  { key: 'action_type', label: 'Authorized action' },
  { key: 'scope_type', label: 'Scope type' },
  { key: 'scope_id', label: 'Scope identifier' },
] as const;

export function InvestigationsPage() {
  const { hasPermission } = useAuth();
  return (
    <div className="space-y-8">
      <PageHeader
        description="Investigation associates separate Cases, records the best current understanding, and supports a human Decision to verify one Incident. Similarity never merges Cases automatically."
        title="Investigations"
      />
      <ProjectionList
        empty="No active Investigations are visible."
        fields={[
          { key: 'investigation_number', label: 'Investigation' },
          { key: 'question', label: 'Question' },
          { key: 'current_state', label: 'State' },
          { key: 'case_count', label: 'Cases in scope' },
          { key: 'row_version', label: 'Version' },
        ]}
        title="Investigation workspace"
        view="investigation_workspace"
      />
      {hasPermission('investigation.manage') ? (
        <DomainCommandForm
          command="add_case_to_investigation"
          description="Adds another independent Case to scope with an explicit reason and optimistic version check."
          fields={[
            { name: 'p_investigation_id', label: 'Investigation ID', required: true },
            { name: 'p_case_id', label: 'Case ID', required: true },
            {
              name: 'p_scope_role',
              label: 'Scope role',
              required: true,
              defaultValue: 'related_report',
            },
            {
              name: 'p_inclusion_reason',
              label: 'Inclusion reason',
              type: 'textarea',
              required: true,
            },
            {
              name: 'p_expected_investigation_version',
              label: 'Expected Investigation version',
              type: 'number',
              required: true,
            },
          ]}
          title="Associate Case with Investigation"
        />
      ) : null}
      {hasPermission('incident.manage') ? (
        <>
          <ProjectionList
            empty="No current Mandate is visible."
            fields={authorityFields}
            title="Current Authority context"
            view="current_authority_context"
          />
          <DomainCommandForm
            command="verify_incident_from_investigation"
            description="Records an Understanding Assessment, supporting Evidence links, a human Decision, one verified Incident, and Case associations atomically."
            fields={[
              { name: 'p_investigation_id', label: 'Investigation ID', required: true },
              {
                name: 'p_expected_investigation_version',
                label: 'Expected Investigation version',
                type: 'number',
                required: true,
              },
              {
                name: 'p_known_summary',
                label: 'Known from verifiable Evidence',
                type: 'textarea',
                required: true,
              },
              { name: 'p_inferred_summary', label: 'Inferred understanding', type: 'textarea' },
              { name: 'p_disputed_summary', label: 'Disputed understanding', type: 'textarea' },
              { name: 'p_unknown_summary', label: 'Unknowns', type: 'textarea' },
              { name: 'p_confidence', label: 'Confidence (0–1)', type: 'number', required: true },
              {
                name: 'p_decision_outcome',
                label: 'Human Decision outcome',
                type: 'textarea',
                required: true,
              },
              {
                name: 'p_decision_rationale',
                label: 'Decision rationale',
                type: 'textarea',
                required: true,
              },
              { name: 'p_expected_consequences', label: 'Expected consequences', type: 'textarea' },
              {
                name: 'p_acting_role_assignment_id',
                label: 'Acting role assignment ID',
                required: true,
              },
              { name: 'p_mandate_id', label: 'Mandate ID', required: true },
              {
                name: 'p_evidence_item_ids',
                label: 'Evidence Item IDs (comma-separated)',
                type: 'array',
              },
              { name: 'p_occurred_at', label: 'Decision occurred at', type: 'datetime-local' },
            ]}
            title="Verify Incident by human Decision"
          />
        </>
      ) : null}
    </div>
  );
}
