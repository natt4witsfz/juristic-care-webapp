# UX Rules

## Overall UX direction

Juristic Care should feel minimal, friendly, clear, and easy to understand for condominium users. It should not feel like a dense enterprise admin system unless the workflow truly requires dense data.

The interface should support both:

- residents who need simple status visibility;
- staff/admin users who need operational control.

## Visual tone

- Keep the current soft green brand foundation.
- Use pastel/light blue and red accents only where they support status, warning, or contrast.
- Avoid harsh saturated blocks unless already present in the design system.
- Preserve soft cards, rounded corners, and clean spacing.

## Readability

- Text must not be too small for important labels, actions, status, or numbers.
- Helper text can be smaller, but must remain readable.
- Avoid long paragraphs inside operational screens.
- Prefer concise labels and clear action names.

## Workflow clarity

Every task or work item should make these easy to see:

- what the issue is;
- who owns it;
- current status;
- due date or next follow-up date;
- latest timeline/proof;
- next action.

## Status and review rule

When an assignee submits proof, do not immediately show the job as completed. Show a review state first:

- `Submitted for Review`
- Thai wording should match the existing i18n pattern.

Only Admin / Assignor / Reviewer confirmation should mark the task completed.

## Resident UX

Resident-facing pages should avoid internal operational terms where possible. Residents should see clear sections such as overview, common-area work, my room, finance, calendar, announcements, and chat based on permissions.

Residents should not see the central raw work pool.

## Admin / Co-Admin UX

Admin and Co-Admin screens can show more data, but should still be easy to scan:

- use filters and search;
- use grouped permissions;
- avoid overwhelming tables when cards/lists are clearer;
- show save/confirm actions clearly;
- log important changes.

## Mobile UX

Many users may use phones on-site. Mobile screens should:

- keep actions thumb-friendly;
- avoid cramped tables;
- use card/list layout where possible;
- keep modals usable as bottom sheets;
- prioritize photo upload, status update, and task review flows.

## Error prevention

- Require confirmation for destructive actions.
- Preserve logs for Admin/Co-Admin changes.
- Keep original Google Form data in timeline/log when authorized users edit imported work details.
- Do not hide critical audit history behind removable UI.

