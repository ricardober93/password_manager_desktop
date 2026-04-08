## Why

The current MVP interface is functional but visually generic, heavily modal, and optimized more for form completion than for calm day-to-day desktop use. Now that the core vault flows exist, the product needs a deliberate desktop experience that feels minimal, trustworthy, and easier to navigate without changing the underlying security model.

## What Changes

- Introduce a minimal desktop visual direction with a restrained color system, stronger typography hierarchy, quieter feedback states, and more intentional spacing.
- Redesign the unlocked vault flow around a persistent multi-panel desktop layout instead of a single list with modal-heavy interactions.
- Redesign setup and unlock screens so they feel productized and security-focused rather than default form cards.
- Move credential detail and edit interactions toward in-context surfaces that reduce unnecessary dialogs and make browsing, reading, and editing feel continuous.
- Standardize interaction patterns for search, empty states, selection, copy actions, destructive actions, and success/error feedback.
- Define the UI architecture needed to separate theme tokens, reusable desktop components, and screen composition from application logic.

## Capabilities

### New Capabilities
- `desktop-ui-experience`: Minimal desktop-first presentation requirements for setup, unlock, vault browsing, detail viewing, editing, and feedback behavior.

### Modified Capabilities

None.

## Impact

- Affects presentation code in `lib/app.dart` and likely requires extracting reusable widgets, layout primitives, and theme definitions under `lib/presentation/`.
- May introduce typography or icon dependencies if the chosen visual system requires them.
- Changes widget structure for unlocked-state navigation, detail presentation, and edit flows while preserving existing use cases and security behavior.
- Adds UI-level validation expectations for desktop layout states, navigation states, and interaction continuity.
