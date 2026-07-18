# UI and UX Principles

Version: 2.0  
Status: Architecture Baseline

## Purpose

Interfaces should help people understand reality, act safely, and see accountability without forcing them to learn internal architecture.

## Principles

Lead with the user's goal and current risk. Show what is known, inferred, disputed, awaiting evidence, and decided using plain language. Keep Case, Incident, and Operation identities distinct while explaining relationships. Display who decided, under which role, when, and why for consequential changes.

## Time and history

Timelines distinguish event/action time from recording and upload time. Corrections appear as linked revisions, not edited history. Current summaries link to their supporting chronology. Time zones and approximate times are explicit.

## Safety and emergencies

Emergency actions are prominent, fast, and usable with limited connectivity. The interface never requires media capture before danger is controlled. Post-event reconstruction is respectful and identifies unknowns rather than demanding fabricated precision.

## Human control and AI

AI content is labeled, cited, and separated into facts, inference, and recommendation. Users can inspect sources, edit or reject drafts, report errors, and complete critical tasks without AI. Destructive and high-impact actions require clear consequences and authority checks.

## Accessibility and inclusion

Meet WCAG 2.2 AA as a minimum. Support keyboard navigation, screen readers, scalable text, non-color cues, touch targets, plain language, multilingual content, and low-bandwidth operation. Do not assume residents or technicians share devices, literacy, language, or technical confidence.

## Errors and edge cases

Preserve user input across recoverable failures. Explain synchronization, stale data, permission limits, and next actions. Prevent duplicate submission through idempotency while still creating distinct Cases for distinct intentional reports.

Specific experiences are defined in [23_resident_experience.md](23_resident_experience.md) through [26_committee_workspace.md](26_committee_workspace.md).
