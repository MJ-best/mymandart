# Core Documentation - Mandalart Journey

This document outlines the core architecture, logic, and features of the Mandalart Journey application. It serves as the single source of truth for the established stable state of the project.

## 📂 Related Core Documents

- **[UIUX_Design_rule.md](UIUX_Design_rule.md)**: Comprehensive design guidelines, color palettes, and UX principles that MUST be followed.
- **[DEPLOYMENT_GUIDE.md](DEPLOYMENT_GUIDE.md)**: Guidelines for building, signing, and deploying the application.

---

## 🏗 System Architecture

### Technology Stack
- **Framework**: Flutter (Targeting iOS & Android)
- **Language**: Dart
- **State Management**: `flutter_riverpod` (v2.x)
- **Routing**: `go_router`
- **Persistence**: `shared_preferences`
- **Icons**: `flutter_launcher_icons` & `flutter_dynamic_icon`

### Core Concepts

#### 1. Context7 Migration & Compatibility
- The codebase is optimized for Flutter 3.27+.
- **Rule**: Usage of `.withOpacity()` is strictly deprecated. **MUST** use `.withValues(alpha: 0.x)` instead.
- **Rule**: `resolveFrom(context)` is used for `CupertinoDynamicColor` to support Dark Mode.

#### 2. Navigation Flow (3 Main Pages)
The app follows a strict linear flow with swipe support, optimized for visualization first:
1.  **Mandalart Viewer (Page 0)**:
    - **Primary Landing Screen**.
    - Visualizes the full 9x9 Mandalart chart.
    - **Context Sync**: Zooming into a theme and swiping left to Page 1 auto-expands that theme for editing.
2.  **Combined Step (Page 1)**:
    - Main editing interface.
    - Integrates "Themes" (8 Core Areas) and "Actions" (8 Actions per Theme).
    - Features an **Accordion UI** (Tap to expand) and **Swipe-to-Delete** gestures.
3.  **Calendar & History (Page 2)**:
    - **Activity Log**: Visualizes the history of **Started** and **Completed** tasks.
    - **Interaction**:
        - 1 Tap: Start (In Progress).
        - 2 Taps: Complete.
    - Powered by `startedAt` and `completedAt` timestamps.

#### 3. Data Model
- **MandalartStateModel**:
    - `id`: UUID v4 (Unique identifier).
    - `goal`: String (Main goal).
    - `themes`: List<String> (8 themes).
    - `actions`: List<ActionItem> (64 items).
- **ActionItem**:
    - `id`: UUID.
    - `title`: String.
    - `status`: Enum (notStarted, inProgress, completed).
    - `startedAt`: DateTime? (Timestamp of start).
    - `completedAt`: DateTime? (Timestamp of completion).
- **Persistence**:
    - JSON serialization.
    - Meta-data saved separately for list views (`SavedMandalartMeta`).

---

## 🧩 Core Features (Implemented)

### 1. Theming System
- **Color Themes**: 4 Supported Themes (Green, Purple, Black, White).
- **Dynamic App Icons**: App icon changes based on the selected theme (iOS `setAlternateIconName`).
- **Dark Mode**: Fully supported using `CupertinoTheme` and adaptive colors.

### 2. Interaction Experience
- **Haptic Feedback**:
    - `lightImpact`: Standard taps (buttons, navigation).
    - `mediumImpact`: Action completion (Task done).
    - `selectionClick`: Segment controls, discrete choices.
- **Animations**:
    - Page transitions.
    - Hero animations for key elements.
    - Smooth expansion/collapse in Combined Step.

### 3. Mandalart Logic
- **Connections**: Changing a Theme in Step 1 automatically updates the center cell of the corresponding sub-grid in the 9x9 chart.
- **Progress Tracking**:
    - **Context Awareness**: "Active Focus" state is shared between List and Viewer.
    - **History Tracking**: Tasks are not just "checked" but "recorded" with a timestamp.
    - **Streak**: Calculated based on daily activity (at least one completion).

### 4. Storage & Management
- **Multiple Saves**: UUID-based storage allows unlimited saved Mandalarts.
- **Metadata Separation**: Allows loading lists of goals without parsing the entire Mandalart data.
- **JSON Export/Import**: Backup capabilities.

---

## 📜 Historical Timeline (Major Milestones)

- **2025-12-06**: UI/UX Overhaul (Context-Aware Nav, Calendar Activity Log, Goal Popup).
- **2025-11-01**: Implemented Color Theme System & Dynamic App Icons. Context7 Migration completed.
- **2025-10-27**: UI/UX Overhaul (Removed top bars, optimized for phone).
- **2025-10-26**: Restructured into 3-page flow & Combined Step implemented.
- **2025-10-17**: UX Improvements (Flow restructuring, Save logic fixes).
- **2025-10-14**: Dark Mode fixes & Multi-save support.
- **2025-10-13**: Fixed Riverpod initialization issues (`ref.listen` in `build`).

For detailed logs, refer to `archive/PROJECT_HISTORY.md` and other files in the `archive/` directory.

