import { Link } from 'react-router-dom';

import { PageHeader } from '../components/layout/PageHeader';

export function UnauthorizedPage() {
  return (
    <div className="space-y-6">
      <PageHeader
        description="The current session is not permitted to display the requested resource. No resource details have been revealed."
        eyebrow="Access boundary"
        title="You do not have access to this page."
      />
      <Link className="link inline-block" to="/">
        Return home
      </Link>
    </div>
  );
}
