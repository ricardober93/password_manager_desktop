## Context

The current Flutter desktop app delivers the MVP behavior for vault setup, unlock, credential CRUD, search, copy, and password generation, but the presentation layer remains concentrated in a single screen file with mostly default Material 3 composition. Setup and unlock use centered cards, the unlocked state uses a top bar plus list, and most credential interactions depend on modal dialogs.

That structure is sufficient for validating product behavior, but it does not yet express a strong desktop identity. The desired direction is a minimal, calm, security-oriented interface that feels intentional rather than template-driven. The redesign must preserve the current application and domain boundaries, keep the existing use cases intact, and avoid introducing visual complexity that undermines clarity or trust.

## Goals / Non-Goals

**Goals:**
- Establish a clear visual system for a minimal desktop password manager, including color, typography, spacing, elevation, and state treatment.
- Recompose the unlocked experience into a desktop-first layout with persistent navigation, credential browsing, and detail context.
- Reduce modal dependence by using in-context reading and editing surfaces where possible.
- Make security-sensitive actions feel explicit and calm through better hierarchy, labels, and feedback patterns.
- Keep presentation concerns modular so future UI changes do not force business-logic changes.

**Non-Goals:**
- Changing vault security behavior, use-case semantics, or persistence format.
- Adding new product capabilities such as tags, favorites, categories, sync, import/export, or biometric unlock.
- Introducing a broad design system abstraction for every future screen before the new core flows are proven.
- Requiring a mobile-adaptive UI direction; this change is desktop-first.

## Decisions

### Adopt a desktop-first three-zone unlocked layout
The unlocked state will use a persistent desktop composition with three zones: lightweight navigation/filter rail, credential list, and detail/edit panel. This is preferred over the current single-column list plus dialogs because it better matches desktop scanning behavior, reduces context switching, and supports a more premium minimal aesthetic.

Alternative considered: keeping the current list and only reskinning cards and dialogs. This was rejected because it would improve cosmetics without improving interaction flow.

### Define a calm visual language instead of default Material styling
The refresh will introduce explicit design tokens for background surfaces, separators, accent color, corner radii, spacing, and typography. Visual contrast will come from hierarchy and spacing more than from strong fills, shadows, or saturated colors.

This is preferred over continuing to rely on `ColorScheme.fromSeed` and default component appearances because the app needs a recognizable and controlled desktop identity.

Alternative considered: a dark-first cyber/security aesthetic. This was rejected as the default because it risks feeling louder, denser, and less timeless than the desired minimal direction.

### Treat setup and unlock as editorial entry points
Setup and unlock screens will remain compact, but they should shift from generic centered cards to more deliberate entry views with stronger headline hierarchy, tighter copy, and a single dominant action. This is preferred over adding more decorative elements or dashboard chrome to the locked state because the task is singular: establish or regain trust and access.

Alternative considered: keep current centered panels with only color and typography changes. This was rejected because the screens need a clearer emotional tone, not just cosmetic variation.

### Move credential reading and editing into persistent or contextual panels
Credential details should appear in a dedicated side panel or replaceable detail surface, and editing should happen inline within that surface or in a sheet-like panel rather than always in modal dialogs. This is preferred over dialog-driven CRUD because frequent vault usage benefits from continuity and visible context.

Alternative considered: full-page route transitions for detail and edit. This was rejected because the app’s data density is modest and a persistent desktop layout is more efficient.

### Standardize quiet feedback and explicit destructive actions
Notices, copy confirmations, lock notices, and validation errors will use restrained feedback components that do not dominate the screen. Destructive actions such as delete remain explicit and visually differentiated, but should not compete with primary browse/edit actions.

This is preferred over large banners and equally weighted buttons because minimal UI depends on controlled emphasis.

### Extract theme and layout primitives before screen rewrites
Implementation should begin by extracting design tokens and reusable presentation primitives such as shell layout, section headers, field groups, state banners/toasts, and action rows. This is preferred over rewriting screens directly in `lib/app.dart` because the current presentation file is too monolithic to sustain a visual refresh cleanly.

Alternative considered: incremental edits in place. This was rejected because it would increase UI coupling and make the new visual system inconsistent.

## Risks / Trade-offs

- [A more minimal UI can accidentally hide important actions] -> Keep one clear primary action per surface, preserve obvious labels for sensitive actions, and validate discoverability with widget/integration tests.
- [Reducing dialogs may increase layout complexity in the main screen] -> Define a clear panel hierarchy and fallback behavior for narrow desktop widths before implementation.
- [Introducing custom theme tokens can create inconsistency if only partially adopted] -> Extract shared primitives first and migrate screens through those primitives rather than ad hoc styling.
- [A desktop-first shell may make future responsive work harder] -> Keep layout composition modular so narrower breakpoints can stack or collapse panels later if needed.
- [Visual polish work can sprawl into product-scope changes] -> Treat this change as presentation-only unless a separate proposal introduces new behavior.

## Migration Plan

- Implement the new presentation structure behind the existing app controller and use cases so behavior remains stable while screens change.
- Migrate setup and unlock first, then the unlocked shell, then detail/edit surfaces, then polish feedback and empty states.
- Keep tests focused on existing user flows while updating widget expectations to the new layout and interaction surfaces.
- If the refresh proves too disruptive, the old modal-based flows can be restored temporarily because the application logic remains unchanged.

## Open Questions

- Should the first release of the refresh include a dark theme variant, or should the visual system be shipped in one polished light theme first?
- Should generator controls live permanently in the edit surface, or be collapsible to keep the form quieter by default?
- Does the navigation rail need product concepts such as favorites or recent items now, or should it stay intentionally sparse in the first refresh?
