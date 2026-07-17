# User Role Guide

Roles describe a person's current organizational participation; they do not by themselves prove Authority, Responsibility, Commitment, Capability, Availability, Priority, or approval.

| Role             | Typical scope                                   | Important limit                                                      |
| ---------------- | ----------------------------------------------- | -------------------------------------------------------------------- |
| admin            | Tenant access administration                    | Does not automatically hold operational Authority                    |
| committee        | Governance review and decisions                 | Does not perform field verification by role alone                    |
| juristic_manager | Juristic coordination and authorized decisions  | Must act within an effective Mandate                                 |
| juristic_staff   | Intake, communication, coordination             | Cannot fabricate verification or evidence                            |
| head_technician  | Technical coordination and assignment           | Assignment and technician acceptance are separate                    |
| technician       | Accepted field work and evidence                | Cannot approve their own work when separation is required            |
| resident         | Own relationship-scoped Cases and communication | Cannot access another resident's Case without a valid relationship   |
| vendor           | Contract/commitment-scoped work                 | Access ends with the effective commitment/relationship               |
| security         | Security reports and scoped duties              | No general operational-data access                                   |
| housekeeping     | Future explicitly scoped reporting duties       | No implicit Case source in the current implementation                |
| auditor          | Approved read/review scope                      | No mutation by default                                               |
| ai_service       | Governed AI metadata and recommendations        | No human review, approval, verification, closure, or domain mutation |

`service_role` is a Supabase platform role, not a human O83 role. It bypasses RLS and must remain server-side.
