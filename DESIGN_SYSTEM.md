# Design System — Current UI Reference

This document records the current UI style already present in the codebase. It is not a new design system. Future agents must reuse the existing components and style tokens instead of inventing new colors, spacing, font sizes, border radius, or layouts.

## Source of truth

Current visual tokens and components live primarily in:

- `styles.css`
- `index.html`
- existing render functions in `app.js`

When this document and the code differ, inspect the current code and preserve the existing UI unless the user explicitly requests a design change.

## Typography

The app currently loads:

- `Anuphan`
- `IBM Plex Sans Thai`
- fallback `sans-serif`

Base body style:

- Font size: `14px`
- Body text color: `var(--ink)`
- UI text is generally compact but should remain readable.

Common observed text sizes:

- Large auth hero title: responsive `clamp(42px, 5vw, 70px)`
- Auth panel title: around `34px`
- Topbar page title: around `19px`
- Panel title: around `15px`
- Small helper text: around `10px` to `11px`

Do not make important labels/actions too small.

## Current color tokens

Defined in `:root` in `styles.css`:

- `--ink: #17231f`
- `--muted: #6d7c76`
- `--line: #e5ebe8`
- `--surface: #fff`
- `--bg: #f4f7f5`
- `--green: #146c5a`
- `--green-dark: #0b4b3e`
- `--green-soft: #e6f2ee`
- `--amber: #d99a21`
- `--amber-soft: #fff4d8`
- `--blue: #3777d4`
- `--blue-soft: #eaf2ff`
- `--purple: #7957c8`
- `--purple-soft: #f1edff`
- `--red: #cf4c4c`
- `--shadow: 0 8px 30px rgba(23, 45, 37, .08)`

Use these before adding anything new.

## Visual direction

The current UI uses:

- White and soft off-white surfaces.
- Green as the main brand and action color.
- Pastel green panels and active states.
- Light blue, purple, amber, and red accents for categories/status.
- Thin borders using `var(--line)`.
- Soft shadows, not heavy admin-dashboard shadows.
- Rounded cards and buttons.

The visual feel should remain clean, soft, modern, condominium-friendly, and operational.

## Layout rules

Current desktop shell:

- `.app-view` uses a two-column grid: sidebar around `242px`, content `1fr`.
- `.sidebar` is sticky, full-height, white, bordered on the right.
- `.topbar` is sticky, white with subtle blur and bottom border.
- Main content uses panels, cards, lists, grids, and modals.

Responsive behavior:

- Media rules begin around `1100px` and `820px`.
- `body.device-mobile` applies mobile-specific layout.
- On mobile, desktop sidebar is hidden and bottom/mobile navigation patterns are used.
- Mobile modals become bottom-sheet style with rounded top corners.

Do not replace this shell unless explicitly requested.

## Cards and panels

Common style patterns:

- `.panel`: white background, `1px` border using `var(--line)`, border radius around `13px`, overflow hidden.
- `.panel-header`: flex layout, padding around `18px 20px`, bottom border.
- Dashboard/category cards use radius around `16px`, subtle gradient from white to off-white, and low-opacity shadow.
- Routine cards use radius around `18px` and soft shadow.
- Announcement cards use radius around `12px`, soft hover border, and slight translate-on-hover.

Reuse existing card classes where possible.

## Buttons and controls

Common buttons:

- `.primary-btn`: green background, white text, radius `10px`, soft green shadow.
- `.secondary-btn`: pale neutral background, dark muted text.
- `.icon-btn`: square `40px`, white background, line border, radius `10px`.
- `.link-btn`: text-style green button.
- `.language-toggle`: bordered white pill/square with green text.

Inputs:

- Border `#dce4e0` or `var(--line)`.
- Radius around `11px` to `12px`.
- Focus state uses green border and a soft green focus ring.

## Modals

Current modal pattern:

- `.modal-backdrop`: fixed overlay, dark translucent background, blur, centered layout.
- `.modal`: white, max-height around `92vh`, radius `16px`, soft heavy shadow.
- `.modal-header`: sticky header, white background, border-bottom.
- Mobile modal: bottom sheet, full width, rounded top corners.

New dialogs should reuse this pattern.

## Navigation

Sidebar:

- Dashboard is first and bold.
- Sidebar groups can collapse/expand.
- Active nav item uses `var(--green-soft)` background and green text.
- Chat and Google Forms have special placement rules already implemented in the app.

Do not reorder navigation unless the user explicitly requests it.

## Status and category display

Existing status/category UI uses:

- Pills/chips with soft backgrounds and strong text.
- Horizontal stacked bars for category summaries.
- Trello-like boards for job groupings by status.
- Review-oriented wording where work submitted by staff is not final completion.

Preserve existing status colors and labels unless the business rule changes.

## Component reuse rule

Before adding UI, search for a similar existing component:

- panel
- card
- toolbar
- chip/pill
- modal
- job row/card
- team card
- resident row/card
- routine card
- permission switch
- announcement card
- Trello/kanban board

Extend that component only when necessary.

