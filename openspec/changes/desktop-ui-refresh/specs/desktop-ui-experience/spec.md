## ADDED Requirements

### Requirement: The application must present a minimal desktop-first visual system
The system SHALL provide a cohesive desktop visual language for the password manager experience, including explicit typography, spacing, surface, separator, and accent treatments. The visual language SHALL feel restrained and security-focused rather than relying on default framework styling.

#### Scenario: User opens the application
- **WHEN** the application renders any primary screen
- **THEN** the system presents consistent typography, spacing, and surface styling across setup, unlock, and unlocked flows

#### Scenario: User encounters primary and secondary actions
- **WHEN** the system displays multiple actions within the same surface
- **THEN** the primary action remains visually dominant and secondary or destructive actions remain clearly distinguishable without overwhelming the interface

### Requirement: The unlocked vault must use a persistent desktop browsing layout
The system SHALL provide a desktop-first unlocked layout with persistent regions for navigation or filtering, credential browsing, and credential detail context. The user SHALL be able to browse and inspect credentials without relying exclusively on modal dialogs.

#### Scenario: User unlocks a vault with stored credentials
- **WHEN** the unlocked interface is shown
- **THEN** the system displays a persistent browsing layout with a credential list and a visible detail context area

#### Scenario: User selects a credential
- **WHEN** the user changes the active credential selection
- **THEN** the system updates the detail context within the unlocked layout without requiring a separate full-screen transition

#### Scenario: Vault contains no credentials
- **WHEN** the unlocked interface has no stored credentials
- **THEN** the system displays an empty state that fits within the desktop shell and offers a clear action to add the first credential

### Requirement: Setup and unlock flows must feel intentional and security-focused
The system SHALL present first-run setup and returning-user unlock screens as focused entry flows with concise instructional copy, clear field hierarchy, and one dominant completion action per screen.

#### Scenario: First-time user creates a vault
- **WHEN** the setup flow is displayed
- **THEN** the system presents a focused entry surface with the master password fields and a clearly dominant create action

#### Scenario: Returning user unlocks a vault
- **WHEN** the unlock flow is displayed
- **THEN** the system presents a focused locked-state entry surface with the master password field and a clearly dominant unlock action

### Requirement: Credential viewing and editing must minimize context switching
The system SHALL support credential detail viewing and editing through persistent or contextual surfaces within the unlocked desktop experience. Frequent reading and editing flows SHOULD minimize unnecessary modal interruptions.

#### Scenario: User views a credential
- **WHEN** the user chooses a credential from the list
- **THEN** the system presents its fields in a dedicated detail surface within the unlocked experience

#### Scenario: User edits or creates a credential
- **WHEN** the user starts an add or edit flow
- **THEN** the system presents the form in an in-context surface that preserves awareness of the surrounding vault state

### Requirement: Feedback and sensitive actions must remain calm and explicit
The system SHALL communicate success, error, lock, copy, and destructive-action states using restrained feedback treatments that fit the minimal interface. Security-sensitive and destructive actions SHALL remain explicit and discoverable.

#### Scenario: User copies a password
- **WHEN** the copy-password action succeeds
- **THEN** the system provides visible but restrained confirmation that does not interrupt the browsing flow

#### Scenario: User triggers an error
- **WHEN** validation or unlock errors occur
- **THEN** the system presents the error with clear language and visual distinction appropriate to the minimal visual system

#### Scenario: User deletes a credential
- **WHEN** the user initiates a destructive action
- **THEN** the system presents the action with clear affordance and sufficient distinction from non-destructive actions
