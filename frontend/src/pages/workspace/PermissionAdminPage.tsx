import { DomainCommandForm } from '../../components/common/DomainCommandForm';
import { ProjectionList } from '../../components/common/ProjectionList';
import { PageHeader } from '../../components/layout/PageHeader';
import { useAuth } from '../../features/auth/useAuth';

export function PermissionAdminPage() {
  const { access } = useAuth();
  return (
    <div className="space-y-8">
      <PageHeader
        description="Administration changes account and role state only through versioned, Mandate-bound commands. Authority, Responsibility, Commitment, and vendor relationships remain separate."
        title="Administration"
      />
      <section className="card">
        <h2 className="section-title">Your effective permissions</h2>
        <ul className="mt-4 grid list-disc gap-2 pl-5 sm:grid-cols-2">
          {access?.permissions.map((permission) => (
            <li key={permission}>{permission}</li>
          ))}
        </ul>
      </section>
      <ProjectionList
        empty="No administration directory records are visible."
        fields={[
          { key: 'display_name', label: 'Person' },
          { key: 'organization_relationship_id', label: 'Relationship' },
          { key: 'account_state', label: 'Account state' },
          { key: 'account_row_version', label: 'Account version' },
          { key: 'role_code', label: 'Role' },
          { key: 'role_assignment_id', label: 'Role assignment' },
        ]}
        title="People, accounts, and roles"
        view="administration_directory"
      />
      <ProjectionList
        empty="No current administrative Mandates are visible."
        fields={[
          { key: 'role_assignment_id', label: 'Acting role' },
          { key: 'mandate_id', label: 'Mandate' },
          { key: 'action_type', label: 'Action' },
          { key: 'scope_type', label: 'Scope type' },
          { key: 'scope_id', label: 'Scope' },
        ]}
        title="Current Authority context"
        view="current_authority_context"
      />
      <DomainCommandForm
        command="set_account_state"
        description="Changes only the O83 account state. Auth-provider session revocation or invitation is executed by a separate trusted administration workflow."
        fields={[
          { name: 'p_user_account_id', label: 'User Account ID', required: true },
          {
            name: 'p_expected_version',
            label: 'Expected account version',
            type: 'number',
            required: true,
          },
          {
            name: 'p_new_state',
            label: 'New account state',
            type: 'select',
            required: true,
            options: [
              { value: 'invited', label: 'Invited' },
              { value: 'active', label: 'Active' },
              { value: 'suspended', label: 'Suspended' },
              { value: 'disabled', label: 'Disabled' },
            ],
          },
          { name: 'p_reason', label: 'Reason', type: 'textarea', required: true },
          {
            name: 'p_acting_role_assignment_id',
            label: 'Acting role assignment ID',
            required: true,
          },
          { name: 'p_mandate_id', label: 'Mandate ID', required: true },
        ]}
        title="Change account state"
      />
      <DomainCommandForm
        command="assign_role"
        description="Assigns an approved role to an effective organization relationship. It does not transfer Responsibility or create a Commitment."
        fields={[
          {
            name: 'p_organization_relationship_id',
            label: 'Organization relationship ID',
            required: true,
          },
          { name: 'p_role_definition_id', label: 'Role definition ID', required: true },
          { name: 'p_reason', label: 'Assignment reason', type: 'textarea', required: true },
          {
            name: 'p_acting_role_assignment_id',
            label: 'Acting role assignment ID',
            required: true,
          },
          { name: 'p_mandate_id', label: 'Mandate ID', required: true },
          { name: 'p_effective_at', label: 'Effective at', type: 'datetime-local' },
        ]}
        title="Assign role"
      />
      <DomainCommandForm
        command="end_role_assignment"
        description="Ends the effective assignment without deleting it; prior access and audit history remain visible."
        fields={[
          { name: 'p_role_assignment_id', label: 'Role Assignment ID', required: true },
          {
            name: 'p_expected_version',
            label: 'Expected role version',
            type: 'number',
            required: true,
          },
          { name: 'p_reason', label: 'End reason', type: 'textarea', required: true },
          {
            name: 'p_acting_role_assignment_id',
            label: 'Acting role assignment ID',
            required: true,
          },
          { name: 'p_mandate_id', label: 'Mandate ID', required: true },
          { name: 'p_effective_at', label: 'Effective at', type: 'datetime-local' },
        ]}
        title="End role assignment"
      />
    </div>
  );
}
