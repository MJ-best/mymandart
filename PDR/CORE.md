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
The app follows a strict linear flow with swipe support:
1.  **Goal Step (Page 0)**:
    - User enters the main "Final Goal".
    - Input is validated to ensure meaningful content.
2.  **Combined Step (Page 1)**:
    - Integrates "Themes" (8 Core Areas) and "Actions" (8 Actions per Theme).
    - Features an **Accordion UI** for managing themes.
    - Includes a **Streak Widget** at the top for engagement.
3.  **Mandalart Viewer (Page 2)**:
    - Visualizes the full 9x9 Mandalart chart.
    - Supports zooming (InteractiveViewer) and saving functionality.

#### 3. Data Model
- **MandalartStateModel**:
    - `id`: UUID v4 (Unique identifier).
    - `goal`: String (Main goal).
    - `themes`: List<String> (8 themes).
    - `actions`: List<ActionItem> (64 items).
- **ActionItem**:
    - `id`: UUID.
    - `title`: String.
    - `isCompleted`: Boolean.
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
    - Completion of an action updates the visual progress.
    - "Streak" logic tracks checking into the app.

### 4. Storage & Management
- **Multiple Saves**: UUID-based storage allows unlimited saved Mandalarts.
- **Metadata Separation**: Allows loading lists of goals without parsing the entire Mandalart data.
- **JSON Export/Import**: Backup capabilities.

---

## 📜 Historical Timeline (Major Milestones)

- **2025-11-01**: Implemented Color Theme System & Dynamic App Icons. Context7 Migration completed.
- **2025-10-27**: UI/UX Overhaul (Removed top bars, optimized for phone).
- **2025-10-26**: Restructured into 3-page flow & Combined Step implemented.
- **2025-10-17**: UX Improvements (Flow restructuring, Save logic fixes).
- **2025-10-14**: Dark Mode fixes & Multi-save support.
- **2025-10-13**: Fixed Riverpod initialization issues (`ref.listen` in `build`).

For detailed logs, refer to `archive/PROJECT_HISTORY.md` and other files in the `archive/` directory.

