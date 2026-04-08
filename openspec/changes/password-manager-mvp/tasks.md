## 1. Foundation

- [x] 1.1 Define the `lib/` folder structure for presentation, application, domain, and infrastructure layers
- [x] 1.2 Add Flutter dependencies required for cryptography, local app-data paths, and desktop-safe clipboard handling
- [x] 1.3 Create core domain models and value objects for vault metadata, credential items, password policy, and vault session state
- [x] 1.4 Define infrastructure ports for `VaultRepository`, `CryptoService`, `ClipboardService`, and `Clock`

## 2. Vault Security

- [x] 2.1 Implement master-password-based key derivation and AES-GCM encryption/decryption services
- [x] 2.2 Implement encrypted vault file serialization with version, salt, KDF parameters, nonce, and encrypted payload
- [x] 2.3 Implement atomic vault save/load behavior in the local file repository
- [x] 2.4 Write failing automated unit tests for `CreateVault`, `UnlockVault`, `LockVault`, and inactivity-based session behavior
- [x] 2.5 Implement use cases for `CreateVault`, `UnlockVault`, `LockVault`, and unlocked session lifecycle until those tests pass
- [x] 2.6 Implement inactivity-based auto-lock behavior for the unlocked vault session until its tests pass

## 3. Credential Management

- [x] 3.1 Write failing automated unit tests for add, read, update, delete, list, search, and clipboard-copy use cases
- [x] 3.2 Implement use cases for adding, reading, updating, deleting, listing, and searching credentials until those tests pass
- [x] 3.3 Implement clipboard use cases for copying username and password through the clipboard service until their tests pass
- [x] 3.4 Create unlocked-state screens for credential list, empty state, detail view, and credential form flows
- [x] 3.5 Implement timed clipboard cleanup policy for copied passwords and keep the use-case test suite green

## 4. Password Generation

- [x] 4.1 Write failing automated unit tests for password generation policy handling and credential-form insertion flows
- [x] 4.2 Implement password generation logic with configurable length and character class options until those tests pass
- [x] 4.3 Add generator UI controls with sensible default policy values for the MVP
- [x] 4.4 Implement the `GeneratePassword` use case and integrate it with create/edit credential flows while keeping the tests green

## 5. Desktop UX and Validation

- [x] 5.1 Create setup and unlock screens for first-run and returning-user flows
- [x] 5.2 Wire the presentation layer to use cases and session state without placing business logic in widgets
- [x] 5.3 Add lower-level tests for crypto, vault persistence, and repository/file integrity behavior
- [x] 5.4 Add widget or integration coverage for create-vault, unlock, CRUD, search, copy, and generator flows
- [x] 5.5 Validate that every MVP use case has automated test coverage before implementation is considered complete
- [ ] 5.6 Validate the MVP flow on Windows, macOS, and Linux desktop targets
