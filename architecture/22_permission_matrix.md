# Permission Matrix

Version: 2.0  
Status: Architecture Baseline

## Purpose

This matrix expresses default decision and action boundaries. Actual access also depends on mandate, relationship, data classification, context, time, and tenant policy.

## Default matrix

| Capability                         |                       Resident |             Technician |      Dispatcher/Manager |  Verifier/Supervisor |             Committee |     Auditor |             AI |
| ---------------------------------- | -----------------------------: | ---------------------: | ----------------------: | -------------------: | --------------------: | ----------: | -------------: |
| Submit Report / create own Case    |                            Yes |                    Yes |                     Yes |                  Yes |                   Yes |          No |             No |
| View appropriate Case status       |                 Own/authorized |               Assigned |           Managed scope |         Review scope |   Oversight aggregate | Audit scope |   Context only |
| Suggest related Cases              |                             No |                    Yes |                     Yes |                  Yes |                    No |          No |       Advisory |
| Associate Case to Incident         |                             No |          No by default |              Authorized |           Authorized |           Policy only |          No |          Never |
| Set Organizational Priority        |                   Opinion only |                     No |              Authorized |        No by default | Reserved cases/policy |          No |          Never |
| Choose Execution Sequence          |                             No |          Assigned work |        Constraints only |             Own work |                    No |          No | Recommend only |
| Perform emergency work             |                             No |      Within capability |       Within capability |    Within capability |                    No |          No |          Never |
| Accept commitment                  |                             No |                    Own |   On behalf if mandated |                  Own |                    No |          No |          Never |
| Verify Operation                   |                             No | Not own high-risk work | If qualified/authorized |                  Yes |                    No |     Observe |          Never |
| Close Incident                     |                             No |              Recommend |              Authorized | Recommend/authorized |        Reserved cases |          No |          Never |
| Approve policy/retention exception |                             No |                     No |          Delegated only |                   No |            Authorized |          No |          Never |
| View audit                         | Own activity where appropriate |                Limited |          Security scope |              Limited |             Oversight |  Authorized | Never directly |

## Rules

Permission is not Authority unless backed by an effective mandate. Technical access does not legitimize a business decision. Separation of duties is risk-based: a performer cannot solely verify their own high-risk work; privileged administrators cannot erase audit history; AI credentials cannot impersonate human approval.

SLA policy is approved by the role or body holding service-policy Authority. Managers may apply the correct SLA class to work within mandate, but doing so does not set Organizational Priority, accept a technician's Commitment, or determine Execution Sequence.

## Emergency and delegated access

Emergency access is time-limited, purpose-scoped, logged, and reviewed. Delegation never exceeds the grantor's authority and ends automatically. Conflicts of interest require recusal or independent review.

## Evolution

Policy versions may refine roles and scopes. Historical decisions retain the permission and mandate evidence effective at the time. Organization concepts are normative in [03_organization_model.md](03_organization_model.md).
