# Project Principles

## Storage Strategy

- The core product must work with local SQL first.
- Cloud sync and Supabase-backed workspace management are deferred to a premium tier.
- No critical workflow should require login, network access, or remote storage.
- Every schema decision should map cleanly from local SQL to a future remote sync layer.

## Platform Strategy

- Build web first.
- Optimize for desktop browser use before mobile adaptation.
- Mobile support follows only after the web workflow is stable and low-friction.
- Agents must avoid mobile-only assumptions during MVP planning and implementation.

## UX Doctrine

- Reduce taps aggressively.
- Prefer inline editing over mode switching.
- The happy path must flow directly from edit -> execute -> progress -> complete.
- Avoid forcing users into separate edit screens when a local inline action is possible.
- Prioritize clarity, scanability, and direct manipulation over dense settings or wizard flows.

## Delivery Rules

- Keep scope at MVP level.
- Ship the shortest path that proves the workflow.
- Separate local-first MVP decisions from premium sync extensions.
- Make upgrade paths explicit, but do not let premium features complicate core flows.
