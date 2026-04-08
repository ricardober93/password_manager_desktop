## ADDED Requirements

### Requirement: User can create a local encrypted vault
The system SHALL allow a user on first launch to create a new local vault protected by a master password. The system SHALL derive an encryption key from the master password using a per-vault salt and SHALL persist the vault as an encrypted local file without storing the plaintext master password.

#### Scenario: First-time vault creation succeeds
- **WHEN** the user provides a valid master password and confirms it during initial setup
- **THEN** the system creates an encrypted local vault file and transitions the application into an unlocked vault session

#### Scenario: Master password confirmation does not match
- **WHEN** the user enters a master password and a different confirmation value during setup
- **THEN** the system MUST reject vault creation and inform the user that the passwords do not match

### Requirement: User can unlock and lock the vault
The system SHALL require the master password to unlock an existing vault. The system SHALL keep vault contents encrypted on disk at all times and SHALL support explicit locking of the active session.

#### Scenario: Unlock with correct master password
- **WHEN** the user enters the correct master password for an existing vault
- **THEN** the system decrypts the vault, loads its contents into memory, and shows the unlocked vault interface

#### Scenario: Unlock with incorrect master password
- **WHEN** the user enters an incorrect master password for an existing vault
- **THEN** the system MUST deny access and keep the vault locked

#### Scenario: User locks an active session
- **WHEN** the user chooses to lock the vault while it is unlocked
- **THEN** the system clears the in-memory vault session and returns to the locked state

### Requirement: Vault persistence must be authenticated and versioned
The system SHALL store the vault using authenticated encryption and SHALL include enough metadata to support future format evolution. The encrypted vault file SHALL include a format version, key-derivation metadata, and a unique encryption nonce, while keeping all credential content encrypted.

#### Scenario: Vault file is persisted successfully
- **WHEN** the system saves vault contents after a change
- **THEN** the stored file contains version and key-derivation metadata outside the encrypted payload and all credential content inside the encrypted payload

#### Scenario: Vault integrity check fails
- **WHEN** the vault file has been tampered with or cannot be authenticated during decrypt
- **THEN** the system MUST reject loading the vault and inform the user that the vault cannot be opened safely

### Requirement: The unlocked session must expire safely
The system SHALL keep decrypted vault contents only while an unlocked session is active. The system SHALL support automatic locking after a configured period of inactivity.

#### Scenario: Session auto-locks after inactivity
- **WHEN** the configured inactivity timeout elapses while the vault is unlocked
- **THEN** the system locks the vault and clears the in-memory session

#### Scenario: Application starts while a vault file already exists
- **WHEN** the application launches and detects an existing vault file
- **THEN** the system presents the locked-state unlock flow instead of vault setup

### Requirement: Vault security use cases must be covered by automated tests
The system SHALL include automated tests for each vault-security use case in the MVP, including vault creation, unlock, lock, and inactivity-based session expiration.

#### Scenario: A vault security use case is implemented
- **WHEN** a vault-security use case is added to the application layer
- **THEN** the codebase MUST include automated tests that verify its expected success and failure behavior
