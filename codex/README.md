# Codex Agent Workflow

This folder defines the locked five-stage workflow used in this repository.

## Shared Context

- `project_principles.md`
  - local SQL first
  - web-first delivery
  - low-tap direct workflow UX
- `design_direction.md`
  - visual direction from reference moodboard
  - mandatory Figma-driven handoff rules for design work

## Active Workflow

The only active workflow is:

`PM -> Design -> Flutter -> QA -> Integrator`

## Agents

- `pm`: locks the work order and scope
- `design`: produces a surface-level design brief
- `flutter`: implements one approved surface at a time
- `qa`: blocks or passes the work using the review gate
- `integrator`: the only role allowed to merge, reset, restore, or push `main`

## Contract

Each agent definition contains:

- role boundaries
- expected inputs
- required outputs
- escalation rules

## Machine-readable manifest

Use `agents.json` to locate the canonical definition file for each active role.
