# Design Direction

## Visual Mood

- Soft paper-like surfaces with warm off-white backgrounds
- Powder blue as the primary brand color
- Butter yellow as the accent color
- Rounded cards and playful geometric illustrations
- Friendly, lightweight iconography with tactile shapes
- Minimal interface chrome and generous spacing

## Interaction Feel

- Calm and direct, not dashboard-heavy
- Important actions should sit on the main card surface
- Editing and status changes should feel immediate
- Hover, focus, and active states must be visible on web

## UI Rules

- Do not default to generic SaaS tables and grey panels.
- Prefer card-based workflows with strong visual grouping.
- Use expressive but readable typography.
- Keep visual noise low and let artifacts/tasks feel like collectible objects, not log rows.

## Figma Workflow

- Design-related agents must use the `figma` and `figma-implement-design` skills when a Figma node, link, or selected desktop node is available.
- The required order is:
  1. `get_design_context`
  2. `get_screenshot`
  3. asset download if needed
  4. implementation handoff
- Flutter implementation must not begin from guesswork when a Figma source exists.
- Every design handoff must include:
  - screenshot reference
  - layout and interaction notes
  - token mapping
  - asset usage notes
  - responsive behavior notes

## Reference Moodboard

The current reference mood is based on playful object cards: creamy paper backgrounds, rounded blue/yellow forms, soft outlines, and friendly visual metaphors instead of technical UI ornament.
