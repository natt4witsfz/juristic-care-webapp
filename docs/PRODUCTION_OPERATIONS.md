# Production Operations

## Operating principles

Human safety precedes system workflow. Emergency work may occur before entry, but the actor records event time, action time, reason, authority, evidence availability, and later record time as soon as reasonably possible.

Monitor Supabase database health, connection saturation, slow queries, Auth failure/rate trends, Storage failures, Edge Function errors when introduced, Vercel availability, notification delivery, overdue follow-ups, audit ingestion, and backup completion. Alerts must route to an accountable duty role, not only an individual.

## Incident response

1. Stabilize people and property.
2. Record the operational event without overwriting prior understanding.
3. Contain access or data exposure using the least destructive action.
4. Preserve logs, evidence digests, timelines, and decisions.
5. Communicate according to classification and legal obligations.
6. Recover, verify, and append the revised understanding.
7. Review lessons with validity context and an accountable owner.

Old users are disabled by ending access relationships; their historical actions remain. Service-role use is server-side, logged, narrowly scoped, and reviewed. AI degradation must not block authoritative human workflows.
