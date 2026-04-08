## ADDED Requirements

### Requirement: User can manage stored credentials
The system SHALL allow the user to create, view, update, and delete credential entries while the vault is unlocked. Each credential SHALL support at least a title, username, password, URL, notes, created timestamp, and updated timestamp.

#### Scenario: User adds a credential
- **WHEN** the user submits a new credential with the required fields while the vault is unlocked
- **THEN** the system stores the credential in the vault and persists the updated encrypted vault

#### Scenario: User edits a credential
- **WHEN** the user updates an existing credential while the vault is unlocked
- **THEN** the system saves the updated credential, refreshes its updated timestamp, and persists the updated encrypted vault

#### Scenario: User deletes a credential
- **WHEN** the user confirms deletion of an existing credential while the vault is unlocked
- **THEN** the system removes the credential from the vault and persists the updated encrypted vault

### Requirement: User can browse and search credentials
The system SHALL provide a credential list while the vault is unlocked and SHALL allow searching across stored credentials. Search SHALL match at least credential title, username, and URL.

#### Scenario: User views stored credentials
- **WHEN** the vault is unlocked and contains saved credentials
- **THEN** the system displays the stored credentials in a list view

#### Scenario: User searches for a credential
- **WHEN** the user enters a search term while the vault is unlocked
- **THEN** the system filters the credential list to matching entries by title, username, or URL

#### Scenario: Vault contains no credentials
- **WHEN** the user unlocks a vault that has no saved credentials
- **THEN** the system displays an empty state with an action to add the first credential

### Requirement: User can copy credential fields safely
The system SHALL allow the user to copy a stored username or password while the vault is unlocked. Password copy behavior SHALL support automatic clipboard clearing after a configured interval.

#### Scenario: User copies a username
- **WHEN** the user selects the copy-username action for a credential
- **THEN** the system places the username on the clipboard

#### Scenario: User copies a password
- **WHEN** the user selects the copy-password action for a credential
- **THEN** the system places the password on the clipboard and schedules clipboard clearing

#### Scenario: Clipboard cleanup interval elapses
- **WHEN** the configured clipboard cleanup interval expires after copying a password
- **THEN** the system clears or replaces the clipboard contents according to the clipboard safety policy

### Requirement: Credential management use cases must be covered by automated tests
The system SHALL include automated tests for each credential-management use case in the MVP, including add, read, update, delete, list, search, and clipboard-copy actions.

#### Scenario: A credential-management use case is implemented
- **WHEN** a credential-management use case is added to the application layer
- **THEN** the codebase MUST include automated tests that verify its expected behavior and relevant failure paths
