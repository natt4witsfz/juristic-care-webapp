import { DomainCommandForm } from '../../components/common/DomainCommandForm';
import { ProjectionList } from '../../components/common/ProjectionList';
import { PageHeader } from '../../components/layout/PageHeader';
import { useAuth } from '../../features/auth/useAuth';

export function OperationsPage() {
  const { hasPermission } = useAuth();
  return (
    <div className="space-y-8">
      <PageHeader
        description="Operations resolve Incidents. Responsibility, Authority, Commitment, Capability, Availability, Priority, SLA, and execution sequence remain independent records."
        title="Operations and Tasks"
      />
      <ProjectionList
        empty="No Operations are visible."
        fields={[
          { key: 'operation_number', label: 'Operation' },
          { key: 'title', label: 'Title' },
          { key: 'current_state', label: 'State' },
          { key: 'incident_id', label: 'Incident' },
          { key: 'task_count', label: 'Tasks' },
          { key: 'terminal_task_count', label: 'Terminal Tasks' },
          { key: 'active_commitment_count', label: 'Active Commitments' },
          { key: 'row_version', label: 'Version' },
        ]}
        title="Operation workspace"
        view="operation_workspace"
      />
      <ProjectionList
        empty="No Tasks are visible."
        fields={[
          { key: 'step_code', label: 'Task' },
          { key: 'title', label: 'Title' },
          { key: 'current_state', label: 'Task state' },
          { key: 'commitment_state', label: 'Commitment state' },
          { key: 'due_at', label: 'Due' },
          { key: 'row_version', label: 'Version' },
        ]}
        title="Operational Tasks and Commitments"
        view="operation_tasks"
      />
      {hasPermission('operation.manage') ? (
        <>
          <ProjectionList
            empty="No current Responsibility or taxonomy choices are visible."
            fields={[
              { key: 'option_type', label: 'Type' },
              { key: 'option_id', label: 'Identifier' },
              { key: 'option_code', label: 'Code' },
              { key: 'option_label', label: 'Label' },
            ]}
            title="Reference choices"
            view="reference_options"
          />
          <DomainCommandForm
            command="create_operation"
            description="Creates one bounded, authorized Operation for an Incident with explicit Responsibility and optional initial Tasks. Use relationship type follow_up for governed follow-up work."
            fields={[
              { name: 'p_incident_id', label: 'Incident ID', required: true },
              {
                name: 'p_operation_type_term_id',
                label: 'Operation type taxonomy term ID',
                required: true,
              },
              {
                name: 'p_responsibility_assignment_id',
                label: 'Responsibility Assignment ID',
                required: true,
              },
              { name: 'p_title', label: 'Operation title', required: true },
              { name: 'p_scope', label: 'Bounded scope', type: 'textarea', required: true },
              {
                name: 'p_desired_outcome',
                label: 'Desired outcome',
                type: 'textarea',
                required: true,
              },
              { name: 'p_hazards', label: 'Hazards JSON', type: 'json', defaultValue: '{}' },
              {
                name: 'p_relationship_type',
                label: 'Incident relationship',
                required: true,
                defaultValue: 'resolution',
              },
              {
                name: 'p_initial_tasks',
                label: 'Initial Task titles (comma-separated)',
                type: 'array',
              },
              {
                name: 'p_acting_role_assignment_id',
                label: 'Acting role assignment ID',
                required: true,
              },
              { name: 'p_mandate_id', label: 'Mandate ID', required: true },
              { name: 'p_occurred_at', label: 'Authorized at', type: 'datetime-local' },
            ]}
            title="Authorize Operation"
          />
          <DomainCommandForm
            command="add_operation_task"
            description="Adds an Operation-owned executable Task under optimistic concurrency."
            fields={[
              { name: 'p_operation_id', label: 'Operation ID', required: true },
              {
                name: 'p_expected_operation_version',
                label: 'Expected Operation version',
                type: 'number',
                required: true,
              },
              { name: 'p_title', label: 'Task title', required: true },
              { name: 'p_instructions', label: 'Instructions', type: 'textarea' },
              { name: 'p_sequence_hint', label: 'Execution sequence hint', type: 'number' },
            ]}
            title="Add Operational Task"
          />
          <DomainCommandForm
            command="offer_commitment"
            description="Offers work to an effective relationship; it does not claim acceptance and does not transfer Responsibility or Authority."
            fields={[
              { name: 'p_operation_id', label: 'Operation ID', required: true },
              { name: 'p_work_step_id', label: 'Task ID' },
              {
                name: 'p_accepted_by_relationship_id',
                label: 'Proposed accepting relationship ID',
                required: true,
              },
              { name: 'p_scope', label: 'Commitment scope', type: 'textarea', required: true },
              { name: 'p_due_at', label: 'Due at', type: 'datetime-local' },
              {
                name: 'p_acting_role_assignment_id',
                label: 'Acting role assignment ID',
                required: true,
              },
              { name: 'p_mandate_id', label: 'Mandate ID', required: true },
            ]}
            title="Offer Commitment"
          />
        </>
      ) : null}
      {hasPermission('operation.accept') ? (
        <>
          <DomainCommandForm
            command="accept_commitment"
            description="Only the named effective relationship can accept the offered Commitment."
            fields={[
              { name: 'p_commitment_id', label: 'Commitment ID', required: true },
              {
                name: 'p_expected_commitment_version',
                label: 'Expected Commitment version',
                type: 'number',
                required: true,
              },
            ]}
            title="Accept Commitment"
          />
          <DomainCommandForm
            command="transition_work_step"
            description="Records Task execution. Completion requires linked Evidence or an explicit safety/connectivity exception reason beginning evidence_exception:."
            fields={[
              { name: 'p_work_step_id', label: 'Task ID', required: true },
              {
                name: 'p_expected_step_version',
                label: 'Expected Task version',
                type: 'number',
                required: true,
              },
              {
                name: 'p_to_state',
                label: 'Next state',
                type: 'select',
                required: true,
                options: [
                  { value: 'in_progress', label: 'In progress' },
                  { value: 'paused', label: 'Paused' },
                  { value: 'completed', label: 'Completed' },
                  { value: 'skipped', label: 'Skipped' },
                ],
              },
              {
                name: 'p_reason',
                label: 'Reason / evidence exception',
                type: 'textarea',
                required: true,
              },
              { name: 'p_occurred_at', label: 'Occurred at', type: 'datetime-local' },
            ]}
            title="Record Task state"
          />
        </>
      ) : null}
      {hasPermission('operation.manage') ? (
        <DomainCommandForm
          command="transition_operation"
          description="Applies only a valid Operation transition. Completion is never available here; it is verification-only."
          fields={[
            { name: 'p_operation_id', label: 'Operation ID', required: true },
            {
              name: 'p_expected_operation_version',
              label: 'Expected Operation version',
              type: 'number',
              required: true,
            },
            {
              name: 'p_to_state',
              label: 'Next state',
              type: 'select',
              required: true,
              options: [
                { value: 'scheduled', label: 'Scheduled' },
                { value: 'in_progress', label: 'In progress' },
                { value: 'paused', label: 'Paused' },
                { value: 'awaiting_verification', label: 'Awaiting verification' },
                { value: 'cancelled', label: 'Cancelled' },
              ],
            },
            { name: 'p_reason', label: 'Transition reason', type: 'textarea', required: true },
            { name: 'p_acting_role_assignment_id', label: 'Acting role assignment ID' },
            { name: 'p_mandate_id', label: 'Mandate ID' },
            { name: 'p_occurred_at', label: 'Occurred at', type: 'datetime-local' },
          ]}
          title="Transition Operation"
        />
      ) : null}
      {hasPermission('verification.perform') ? (
        <DomainCommandForm
          command="record_operation_verification"
          description="Records an immutable human verification attempt and Decision. Significant or critical work cannot be self-verified and requires an issued Evidence Package to pass."
          fields={[
            { name: 'p_operation_id', label: 'Operation ID', required: true },
            {
              name: 'p_expected_operation_version',
              label: 'Expected Operation version',
              type: 'number',
              required: true,
            },
            { name: 'p_method', label: 'Verification method', required: true },
            {
              name: 'p_result',
              label: 'Result',
              type: 'select',
              required: true,
              options: [
                { value: 'passed', label: 'Passed' },
                { value: 'failed', label: 'Failed — return to work' },
              ],
            },
            { name: 'p_limitations', label: 'Limitations', type: 'textarea' },
            { name: 'p_remote', label: 'Remote verification', type: 'checkbox' },
            { name: 'p_evidence_package_version_id', label: 'Issued Evidence Package version ID' },
            {
              name: 'p_decision_rationale',
              label: 'Verification Decision rationale',
              type: 'textarea',
              required: true,
            },
            {
              name: 'p_acting_role_assignment_id',
              label: 'Acting role assignment ID',
              required: true,
            },
            { name: 'p_mandate_id', label: 'Mandate ID', required: true },
            { name: 'p_occurred_at', label: 'Occurred at', type: 'datetime-local' },
          ]}
          title="Verify completion"
        />
      ) : null}
      {hasPermission('operation.manage') ? (
        <DomainCommandForm
          command="transfer_responsibility"
          description="Atomically ends and replaces Responsibility at one effective instant, with a handover and immutable ledger entries."
          fields={[
            {
              name: 'p_responsibility_assignment_id',
              label: 'Current Responsibility Assignment ID',
              required: true,
            },
            { name: 'p_to_relationship_id', label: 'Successor relationship ID', required: true },
            { name: 'p_summary', label: 'Handover summary', type: 'textarea', required: true },
            { name: 'p_risk_summary', label: 'Handover risks', type: 'textarea' },
            {
              name: 'p_acting_role_assignment_id',
              label: 'Acting role assignment ID',
              required: true,
            },
            { name: 'p_mandate_id', label: 'Mandate ID', required: true },
            { name: 'p_occurred_at', label: 'Effective at', type: 'datetime-local' },
          ]}
          title="Transfer Responsibility"
        />
      ) : null}
    </div>
  );
}
