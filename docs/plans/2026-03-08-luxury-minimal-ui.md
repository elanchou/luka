# Luxury Minimal UI Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** Apply a luxury-minimal visual system across shared components and the highest-traffic screens without changing core product behavior.

**Architecture:** Centralize the new visual language in shared widgets and theme primitives first, then update the onboarding/auth/dashboard/detail/settings screens to consume those primitives. Keep logic intact and focus changes on composition, spacing, color, surfaces, and typography.

**Tech Stack:** Flutter, Material 3, Google Fonts, existing widget library

---

### Task 1: Establish Shared Luxury-Minimal Primitives

**Files:**
- Modify: `lib/main.dart`
- Modify: `lib/widgets/gradient_background.dart`
- Modify: `lib/widgets/sault_brand.dart`
- Modify: `lib/widgets/sault_header.dart`

**Step 1: Write the failing test**

- Skip snapshot testing for this UI pass; verify through static analysis and manual screen builds.

**Step 2: Implement minimal theme system**

- Introduce a calmer dark theme with premium neutral palette.
- Update the background, brand, and header to use the new system.

**Step 3: Verify**

Run: `flutter analyze`
Expected: no new errors from edited files

### Task 2: Refresh Shared Form and Navigation Components

**Files:**
- Modify: `lib/widgets/sault_button.dart`
- Modify: `lib/widgets/sault_outline_button.dart`
- Modify: `lib/widgets/sault_text_field.dart`
- Modify: `lib/widgets/custom_bottom_nav_bar.dart`

**Step 1: Write the failing test**

- Skip automated visual test; use targeted screen verification.

**Step 2: Implement minimal component refresh**

- Convert controls to premium panel styling, reduce glow, tighten spacing, unify border radii.

**Step 3: Verify**

Run: `flutter analyze`
Expected: no new errors from edited files

### Task 3: Rebuild Auth and Entry Screens

**Files:**
- Modify: `lib/screens/sault_onboarding_screen.dart`
- Modify: `lib/screens/master_password_input_screen.dart`
- Modify: `lib/screens/setup_master_password_screen.dart`

**Step 1: Write the failing test**

- Skip widget tests for this pass; visual verification is primary.

**Step 2: Implement minimal layout refresh**

- Replace loud hero sections with premium card-driven layouts and cleaner copy hierarchy.

**Step 3: Verify**

Run: `flutter analyze`
Expected: no new errors from edited files

### Task 4: Rebuild Dashboard and Detail Experience

**Files:**
- Modify: `lib/screens/main_sault_dashboard.dart`
- Modify: `lib/screens/seed_phrase_detail_view.dart`

**Step 1: Write the failing test**

- Skip visual snapshots; verify navigation and rendering manually.

**Step 2: Implement minimal premium layouts**

- Upgrade the dashboard shell, summary/search area, list cards, and floating action.
- Upgrade the detail page metadata hierarchy and reveal surface.

**Step 3: Verify**

Run: `flutter analyze`
Expected: no new errors from edited files

### Task 5: Refresh Settings Surface

**Files:**
- Modify: `lib/screens/system_settings_screen.dart`

**Step 1: Write the failing test**

- Skip snapshot test; verify rendering and existing interactions manually.

**Step 2: Implement minimal styling refresh**

- Apply new surfaces, spacing, section rhythm, and quieter chrome.

**Step 3: Verify**

Run: `flutter analyze`
Expected: no new errors from edited files

### Task 6: Final Verification

**Files:**
- Modify: as needed based on verification

**Step 1: Run focused checks**

Run: `flutter test test/security_flow_test.dart`
Expected: PASS

**Step 2: Run static analysis**

Run: `flutter analyze`
Expected: existing legacy warnings may remain, but no new blocking errors
