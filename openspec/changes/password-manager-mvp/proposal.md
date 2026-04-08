## Why

The repository is currently a clean Flutter desktop template and has no product behavior, security model, or application architecture. We need a first functional MVP that proves a password manager can store credentials locally with strong encryption and a use-case-driven architecture before adding more advanced features like sync, accounts, or OS-native secret handling.

## What Changes

- Add a desktop-only MVP flow to create a vault, unlock it with a master password, and lock it again.
- Add local encrypted vault storage using AES-256-GCM with a key derived from the master password.
- Add core credential actions: create, list, search, view, edit, delete, and copy username/password.
- Add a built-in secure password generator for credential creation and update flows.
- Establish a clean architecture based on use cases, domain entities, and infrastructure ports without adopting strict DDD.
- Define initial security behavior for clipboard cleanup, in-memory unlocked session state, and local file persistence.
- Require automated test coverage for every MVP use case so application behavior is validated at the use-case boundary.
- Follow a tests-first workflow for use cases, writing failing automated tests before implementing the corresponding logic.

## Capabilities

### New Capabilities
- `local-vault-security`: Secure local vault creation, unlocking, encryption, persistence, and session locking behavior.
- `credential-management`: Core credential CRUD, listing, searching, and clipboard copy behavior for stored entries.
- `password-generation`: Built-in generation of strong passwords for credential workflows.

### Modified Capabilities

None.

## Impact

- Affects the Flutter app structure under `lib/` by introducing presentation, application, domain, and infrastructure layers.
- Introduces cryptography and local file storage dependencies for desktop targets.
- Defines the initial command/use-case surface for user actions such as `CreateVault`, `UnlockVault`, `AddCredential`, and `GeneratePassword`.
- Adds a testing expectation that every implemented use case must have automated coverage.
- Establishes a tests-first implementation workflow for application-layer behavior.
- Establishes the baseline product contract for a local-only offline password manager MVP across Windows, macOS, and Linux.
