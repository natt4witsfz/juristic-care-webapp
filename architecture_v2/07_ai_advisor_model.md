# AI Advisor Model

Version: 2.0  
Status: Architecture Baseline

## Purpose

AI acts as an Organizational Mirror: it helps people see patterns, context, omissions, and alternatives in their own records without becoming an authority or accountable actor.

## Permitted capabilities

AI may summarize records, retrieve related history, compare contexts, identify possible duplicate patterns, surface contradictions, suggest questions, draft communications, warn about risk, recommend options, and explain its basis. Similarity suggestions never merge Cases or determine Incident identity.

## Prohibited capabilities

AI must not approve or reject a Case, Incident, Operation, Decision, person, or request; assign Organizational Priority; exercise Authority; verify evidence; close Cases or Incidents; punish or evaluate personnel autonomously; fabricate or silently alter evidence; conceal disagreement; determine legal compliance; or become the named Responsibility owner.

## Output contract

Every consequential AI output identifies purpose, source records, relevant context match/mismatch, assumptions, uncertainty, limitations, model/service version, generation time, and intended human reviewer. Facts, inferences, and recommendations are visibly separated. Unsupported claims are rejected or labeled.

Here, `rejected` describes technical suppression of an unsupported AI claim, not a business rejection. The human reviewer alone decides whether to adopt, decline, or act on a recommendation.

## Human control

AI output is advisory until a human explicitly adopts it in a Decision Record. Adoption records the human's role, authority, reasoning, edits, and evidence considered. Users can inspect citations, report errors, and proceed without AI. Critical workflows have a non-AI path.

## Data and security

Only purpose-necessary, access-authorized data enters an AI context. Sensitive data is minimized or redacted. Provider retention, training use, residency, model changes, and subprocessors are governed. Prompts and outputs needed for accountability are retained with appropriate restrictions; secrets are never included.

## Failure modes

Unavailable AI degrades to search and manual workflow. Prompt injection in records is treated as untrusted content. Conflicting sources are shown. Low context match suppresses confident recommendations. Repeated bias, citation failure, or unsafe advice can disable a use case independently.

## Evaluation and evolution

Each use case has a human business owner, risk owner, technical steward, authorized data scope, test scenarios, accuracy and citation measures, harmful-error thresholds, human override monitoring, and periodic approval. Model replacement requires regression evaluation and a recorded human decision. Detailed collaboration rules appear in [29_ai_collaboration_principles.md](29_ai_collaboration_principles.md); evidence constraints appear in [08_evidence_model.md](08_evidence_model.md).
