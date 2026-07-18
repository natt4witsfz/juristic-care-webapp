# API Boundary

Place transport contracts and adapters here. Domain use cases must remain outside transport code. Every operation carries an authenticated acting context, tenant, purpose, correlation identifier, and idempotency key where retries are possible. Do not expose Supabase service-role or secret keys to browser code.
