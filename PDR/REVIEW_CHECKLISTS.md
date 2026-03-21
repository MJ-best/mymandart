# Review Checklists

This document is the merge gate for the shared workflow. QA must block the work unless every required check below passes, and only the Integrator may perform `git merge`, `git reset`, `git restore`, or `git push` against `main`.

## Hard Merge Gate

- QA signoff is required before any merge to `main`.
- If any required check fails, the ticket stays blocked.
- The Integrator is the only role allowed to execute repository actions that change `main` history or contents.
- No other role may merge, reset, restore, or push `main`, even for recovery.

## Recovery Checks After Reset

- Confirm the current branch, target baseline, and expected commit before any reset.
- After reset, verify `git status --short` is clean except for the approved work.
- Confirm the app still launches from the reset state.
- Re-open the key local persistence path and verify saved data is still readable.
- Re-run a save, load, and overwrite cycle to confirm the reset did not corrupt storage.
- Re-run any recovery path that was interrupted before the reset, including partial save or partial restore cases.
- Confirm no unrelated files were restored or rewritten during recovery.

## Process-Doc Check

- The `flutter_app` diff against `demo/mandara-v2` must be empty.
- If any file differs from that baseline, stop the review and send it back for correction.
- Do not waive this check for formatting-only changes, generated output, or incidental local cleanup.

## Surface QA Gates

### Save / Load

- Create a new record, save it, close it, and load it again.
- Confirm the restored record matches the saved state exactly.
- Confirm list metadata and detail data both survive reload.

### Example

- Open the example surface and confirm it renders the expected starter state.
- Confirm the example flow does not introduce extra taps, missing labels, or broken navigation.
- Confirm the example surface behaves consistently on web and mobile.

### Export / Import

- Export a record and verify the output is complete and readable.
- Import that output into a clean state and confirm the round trip preserves content.
- Confirm repeated export/import does not duplicate or lose records.

### Calendar

- Verify started and completed states appear in the calendar view.
- Confirm calendar changes persist after navigation and reload.
- Confirm the calendar remains readable at the smallest supported mobile size.

### Edit Typing Persistence

- Type into an editable field, move focus away, and return.
- Confirm the typed text is preserved after navigation and after a reload.
- Confirm typing does not require a special edit mode beyond the documented flow.

### Web Screenshot

- Capture a web screenshot for every changed surface.
- Confirm there is no overflow, clipping, hidden control, or broken spacing.
- Confirm the web layout is usable with mouse and keyboard only.

### Mobile Screenshot

- Capture a mobile screenshot for every changed surface.
- Confirm the mobile layout fits the viewport without overlap or truncation.
- Confirm touch targets remain reachable and visually clear.

## Pass Rule

- QA passes only when every required gate above is green.
- If any gate is uncertain, treat it as failed until evidence is provided.

