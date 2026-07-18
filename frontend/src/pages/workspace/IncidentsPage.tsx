import { DomainCommandForm } from '../../components/common/DomainCommandForm';
import { ProjectionList } from '../../components/common/ProjectionList';
import { PageHeader } from '../../components/layout/PageHeader';
import { useAuth } from '../../features/auth/useAuth';

export function IncidentsPage() {
  const { hasPermission } = useAuth();
  return (
    <div className="space-y-8">
      <PageHeader
        description="An Incident is one human-verified operational event. Cases remain separate, links are reasoned, and recurrence or reopening adds history rather than overwriting it."
        title="Incidents"
      />
      <ProjectionList
        empty="No verified Incidents are visible."
        fields={[
          { key: 'incident_number', label: 'Incident' },
          { key: 'current_summary', label: 'Best current summary' },
          { key: 'current_state', label: 'State' },
          { key: 'associated_case_count', label: 'Associated Cases' },
          { key: 'operation_count', label: 'Operations' },
          { key: 'row_version', label: 'Version' },
        ]}
        title="Incident workspace"
        view="incident_workspace"
      />
      <ProjectionList
        empty="No Case–Incident associations are visible."
        fields={[
          { key: 'case_id', label: 'Case' },
          { key: 'incident_id', label: 'Incident' },
          { key: 'relationship_type', label: 'Relationship' },
          { key: 'relevance', label: 'Reason' },
          { key: 'decision_id', label: 'Decision' },
        ]}
        title="Reasoned Case associations"
        view="case_incident_links"
      />
      {hasPermission('incident.manage') ? (
        <>
          <DomainCommandForm
            command="associate_case_to_incident"
            description="Links a Case to an Incident through an issued assessment, human Decision, and Mandate. It never merges the Case."
            fields={[
              { name: 'p_case_id', label: 'Case ID', required: true },
              { name: 'p_incident_id', label: 'Incident ID', required: true },
              { name: 'p_assessment_id', label: 'Understanding Assessment ID', required: true },
              {
                name: 'p_relationship_type',
                label: 'Relationship type',
                required: true,
                defaultValue: 'same_verified_event',
              },
              {
                name: 'p_relevance',
                label: 'Association relevance',
                type: 'textarea',
                required: true,
              },
              {
                name: 'p_decision_rationale',
                label: 'Human Decision rationale',
                type: 'textarea',
                required: true,
              },
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
            ]}
            title="Associate Case with Incident"
          />
          <DomainCommandForm
            command="close_incident"
            description="Closes only when linked work is terminal and an authorized human Decision is recorded."
            fields={[
              { name: 'p_incident_id', label: 'Incident ID', required: true },
              {
                name: 'p_expected_incident_version',
                label: 'Expected Incident version',
                type: 'number',
                required: true,
              },
              {
                name: 'p_decision_rationale',
                label: 'Closure rationale',
                type: 'textarea',
                required: true,
              },
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
              { name: 'p_occurred_at', label: 'Occurred at', type: 'datetime-local' },
            ]}
            title="Close Incident"
          />
          <DomainCommandForm
            command="reopen_incident"
            description="Classifies a return as reopen, recurrence, or follow-up and retains the previous closure transition and Decision."
            fields={[
              { name: 'p_incident_id', label: 'Incident ID', required: true },
              {
                name: 'p_expected_incident_version',
                label: 'Expected Incident version',
                type: 'number',
                required: true,
              },
              {
                name: 'p_reason_type',
                label: 'Reason type',
                type: 'select',
                required: true,
                options: [
                  { value: 'reopen', label: 'Reopen — closure was not sustained' },
                  { value: 'recurrence', label: 'Recurrence — related event returned' },
                  { value: 'follow_up', label: 'Follow-up — additional governed work' },
                ],
              },
              {
                name: 'p_relationship_to_prior_repair',
                label: 'Relationship to prior repair',
                type: 'textarea',
                required: true,
              },
              { name: 'p_related_case_id', label: 'New related Case ID' },
              {
                name: 'p_decision_rationale',
                label: 'Human Decision rationale',
                type: 'textarea',
                required: true,
              },
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
              { name: 'p_occurred_at', label: 'Occurred at', type: 'datetime-local' },
            ]}
            title="Reopen, record recurrence, or follow up"
          />
        </>
      ) : null}
    </div>
  );
}
