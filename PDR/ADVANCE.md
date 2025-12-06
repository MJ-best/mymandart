# Advance Documentation - Future Roadmap

This document serves as the guide for future development, improvements, and AI Agent tasks. It outlines what needs to be built, refactored, or experimented with next.

## 🚀 Active Implementation Plan

These are the immediate next steps for the project.

## Active Implementation Plan (Pending)

### 1. Step 1: "Others' Goals" Feature (Lower Priority)
**Objective**: Connect the user with the community by showing examples of goals others have set.
- **Requirement**:
    - Prepare a static list of 100 new year goals (`keywords.dart`).
    - Randomly display 3-5 goals on the Step 1 screen.
    - Implement a "Others are planning this" section.

### 5. UI Refinement: Purple Theme Unification
**Objective**: Align "Completion" visualization with the new Purple theme identity.
- **Current**: Completed items are Green.
- **Change**: Change completion active color to `CupertinoColors.systemPurple`.
- **Scope**:
    - `MandalartAppScreen`: Switch/Checkbox active color.
    - `MandalartViewer`: Completed cell background.

### 6. Component Update: Toggle → Checkbox
**Objective**: Improve clarity for "Done" state.
- **Requirement**: Replace `CupertinoSwitch` with `CupertinoCheckbox`.
- **Design**: Use a circular checkbox or iOS style checkmark.

---

## 🔮 Future Roadmap

### Short-term Improvements
- [ ] **Social Sharing**: Generate a beautiful image card for Instagram Stories/Twitter sharing.
- [ ] **Templates**: Pre-filled Mandalarts for common goals (e.g., "Health 2026", "Startup Launch").
- [ ] **Notifications**: Daily/Weekly reminders to check "Combined Step" and mark progress.
- [ ] **Progress Charts**: Visual graph of completion over time.

### Long-term Goals
- **Cloud Sync**: Optional iCloud/Firebase sync for multi-device support.
- **AI Suggestions**: Use Gemini API to suggest Actions based on the Main Goal.
- **Widget Support**: iOS Home Screen widget showing the current "Focus Theme".

---

## 🤖 AI Agent Guidelines

When working on **Advance** tasks:
1.  **Check CORE First**: Ensure changes do not violate `CORE.md` architecture or `UIUX_Design_rule.md`.
2.  **Context7 Compliance**: Always strictly follow the `.withValues()` rule for opacity.
3.  **iOS First**: Always verify designs against Cupertino standards.
4.  **Update Documentation**: 
    - When a feature from `ADVANCE.md` is completed, move it to `CORE.md`.
    - Log the change in functionality.
