# Agent Workflow

This repository uses a locked, stage-gated workflow. The codebase is shared, so every change must be coordinated through a work order and passed through the full sequence below:

`PM -> Design -> Flutter -> QA -> Integrator`

No stage may be skipped. No stage may revise another stage's locked scope without reopening the work order.

## Baseline

- Current baseline commit: `e526524`
- Baseline tag: `demo/mandara-v2`
- Design reference folder: `/Users/mj/Documents/mandara-2026/앱디자인`

All work must start from the locked baseline and the matching design reference set. If the baseline changes, the PM must issue a new work order before implementation resumes.

## Ownership Model

- PM owns the work order and scope lock.
- Design owns visual intent, layout direction, and UI reference interpretation.
- Flutter owns implementation inside the allowed files and declared scope.
- QA owns verification against the work order and boundary rules.
- Integrator owns final merge/rebase/reset/push actions for `main`.

Each stage is responsible for its own output and must not silently absorb another stage's responsibilities.

## Work-Order Lock

The PM must create and lock each work order before design or code work begins. A locked work order must include:

- Goal
- Scope
- Baseline commit
- Baseline tag
- Design reference path
- Allowed files
- Forbidden changes
- Stage owner for each phase
- QA acceptance criteria
- Whether the task is design-only or behavior-changing

The work order is the source of truth. If a request is not in the locked work order, it is out of scope until the PM updates the order.

## Required Stage Flow

### 1. PM

The PM writes the work order and freezes scope.

Required PM outputs:

- A concise goal statement
- A bounded scope statement
- The exact baseline commit and tag
- The design reference folder
- The exact allowed files list
- The forbidden changes list
- A note on whether behavior work is allowed

PM rules:

- Do not expand scope informally during implementation.
- Do not authorize changes outside the allowed files.
- Do not permit design cleanup and behavior changes in the same locked ticket.
- If behavior changes are needed, open a separate behavior ticket.

### 2. Design

Design interprets the locked work order and produces UI direction that fits the baseline.

Design rules:

- Work only from the locked PM scope and the design reference folder.
- Do not introduce behavioral changes.
- Do not expand the file scope.
- Flag any mismatch between the reference designs and the allowed files back to PM.
- When a Figma URL or node exists, use the Figma MCP flow before handoff.

### 3. Flutter

Flutter implements the approved work only.

Flutter rules:

- Stay within the allowed files.
- Implement only what is explicitly locked by PM.
- If a change would alter behavior, stop and request a separate behavior ticket.
- Do not clean up unrelated code while implementing the ticket.

### 4. QA

QA validates the implementation against the locked work order.

QA checks:

- The baseline commit and tag were respected.
- The implementation matches the allowed files list.
- No forbidden changes were introduced.
- Design-only work did not spill into behavior changes.
- If behavior work exists, it is covered by its own ticket.

QA must fail the ticket if scope drift, unrelated cleanup, or mixed design/behavior edits are detected.

### 5. Integrator

Integrator performs the final repository action.

Integrator-only powers:

- Reset to the agreed baseline
- Restore files as needed for integration
- Push to `main`
- Complete the final branch update
- Force-push recovery updates when explicitly required by the locked work order

Only the Integrator may run repository-altering operations against `main`. No other stage may reset, restore, or push to `main`.

## Completion Rule

A work order is complete only when:

- PM scope is locked and unchanged
- Design input matches the reference folder
- Flutter changes stay inside the allowed files
- QA signs off on the locked boundaries
- Integrator performs the final `main` update

If any stage cannot comply, it must stop and hand the issue back to PM rather than improvising.
