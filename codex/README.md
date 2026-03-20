# Codex Multi-Agent MVP

This folder defines the five-agent workflow used by the MVP.

## Shared Context

- `project_principles.md`
  - local SQL first
  - web-first delivery
  - low-tap direct workflow UX
- `design_direction.md`
  - visual direction from reference moodboard
  - mandatory Figma-driven handoff rules for design work

## Agents

- `orchestrator`: plans the workflow and assigns tasks
- `pm`: writes PRD, feature list, and user flow
- `system-designer`: designs local SQL schema, future sync upgrade path, and ownership model
- `flutter`: implements UI structure and code
- `qa`: validates outputs and finds missing cases

## Contract

Each agent definition contains:

- role boundaries
- expected inputs
- required outputs
- escalation rules

## Machine-readable manifest

Use `agents.json` to locate the canonical definition file for each agent.
