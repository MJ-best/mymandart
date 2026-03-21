# Change Boundaries

These boundaries are mandatory for all agents in this repository. They exist to prevent scope drift, accidental regressions, and mixed-purpose edits.

## Non-Negotiable Rules

- Do not mix design cleanup with behavior changes in the same work order.
- Do not expand scope without PM approval.
- Do not touch files outside the PM-approved allowed file list.
- Do not revert or overwrite work created by other people unless the Integrator is explicitly executing the agreed repository action for the current work order.
- Do not assume you are the only actor in the codebase.

## Design-Only Boundary

Design-only work is limited to the following paths unless the PM opens a separate behavior ticket:

- `flutter_app/lib/screens/**`
- `flutter_app/lib/widgets/**`
- `flutter_app/lib/utils/app_theme.dart`

Rules for design-only work:

- Keep changes visual and presentational.
- Do not alter flows, data contracts, persistence, navigation logic, or state behavior.
- Do not use design cleanup as a reason to refactor unrelated business logic.
- If a visual fix requires behavior changes, stop and ask PM to open a behavior ticket.

The following paths are outside the design-only boundary unless PM explicitly opens a behavior ticket:

- `flutter_app/lib/main.dart`
- `flutter_app/lib/providers/**`
- `flutter_app/lib/models/**`
- `flutter_app/lib/services/**`

## Behavior Boundary

Behavior changes must be isolated from design cleanup.

Behavior work includes, but is not limited to:

- Navigation changes
- State management changes
- Persistence changes
- Data model changes
- Side-effect changes
- Logic that changes user-facing behavior

If a task contains both visual cleanup and behavior changes, split it before implementation begins.

## Git and Main-Branch Boundary

Only the Integrator may:

- Reset repository state
- Restore files for final integration
- Push to `main`

All other agents must treat `main` as read-only.

## Scope Control

Every work order must explicitly state:

- Goal
- Scope
- Baseline commit
- Baseline tag
- Allowed files
- Forbidden changes

If any of those are missing, the work order is incomplete and must be returned to PM.

## Escalation Rule

Stop and escalate to PM when:

- The requested change crosses the design/behavior boundary
- The request requires files outside the approved file list
- The request conflicts with the locked baseline
- The request would require a non-Integrator git operation on `main`

Escalation must be explicit. Silent scope expansion is not allowed.
