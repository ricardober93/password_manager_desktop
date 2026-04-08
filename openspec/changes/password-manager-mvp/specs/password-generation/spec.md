## ADDED Requirements

### Requirement: User can generate a strong password
The system SHALL provide a password generator that can be used during credential creation and editing. The generator SHALL produce passwords using a configurable policy that includes length and character class options.

#### Scenario: User generates a password with default policy
- **WHEN** the user requests a generated password without changing generator settings
- **THEN** the system returns a password that satisfies the default strength policy

#### Scenario: User generates a password with custom policy
- **WHEN** the user configures generator options such as length or character classes and requests a password
- **THEN** the system returns a password that matches the selected policy

### Requirement: Generated passwords can be applied to credentials
The system SHALL allow a generated password to populate the password field of the credential form before the credential is saved.

#### Scenario: Generated password is inserted into a new credential
- **WHEN** the user generates a password while creating a credential
- **THEN** the system fills the credential password field with the generated value

#### Scenario: Generated password replaces an existing password
- **WHEN** the user generates a password while editing an existing credential
- **THEN** the system replaces the current password field value with the generated value before save

### Requirement: Password generation use cases must be covered by automated tests
The system SHALL include automated tests for each password-generation use case in the MVP, including generator policy handling and insertion into credential workflows.

#### Scenario: A password-generation use case is implemented
- **WHEN** a password-generation use case is added to the application layer
- **THEN** the codebase MUST include automated tests that verify the generated output policy and form integration behavior
