# Repository Boundary

Repositories translate persistence records into domain-facing data and isolate query details. Create one repository contract per aggregate read/write boundary when a feature begins. Do not build a generic table repository that bypasses domain invariants or RLS.
