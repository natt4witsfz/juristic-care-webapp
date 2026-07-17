# Folder Structure

```text
o83-care/
├── .github/                 CI and collaboration templates
├── architecture/           implementation index
├── architecture_v2/        approved normative architecture
├── backend/
│   └── src/
│       ├── api/             transport result contracts/adapters
│       ├── client/          browser-safe Supabase construction
│       ├── config/          validated environment configuration
│       ├── repositories/    aggregate persistence boundaries
│       ├── services/        authorized use-case orchestration
│       └── validation/      boundary schemas
├── bootstrap/               workspace policy and setup
├── database/                approved design plus work indexes
│   ├── migrations/
│   ├── seeds/
│   └── sql/
├── docs/                    developer and contribution guides
├── frontend/
│   └── src/
│       ├── app/             router and providers
│       ├── components/      shared infrastructure components
│       ├── config/          public environment adapter
│       ├── pages/           infrastructure routes
│       ├── styles/          theme and global CSS
│       └── test/            test setup
├── planning/                approved implementation roadmap
├── review/                  validation and assurance reports
├── scripts/                 setup and verification
├── sql/                     approved generated SQL baseline
└── supabase/                canonical CLI migrations and seeds
```

Future business code uses `frontend/src/features/<feature>/` and corresponding explicit backend use-case boundaries. It is not added to shared infrastructure folders merely for convenience. New top-level folders require a documented ownership and lifecycle reason.
