## Context

The repository is a new Flutter desktop project with no existing domain model, persistence layer, or application architecture. The MVP must deliver a working desktop password manager for Windows, macOS, and Linux while staying offline-only and keeping the implementation small enough to build and validate quickly.

The main constraints are security and simplicity. The product must protect stored credentials with strong encryption, avoid persisting the master password, and support a clean architecture centered on user actions as use cases rather than widget-driven logic. At the same time, the MVP should avoid early complexity such as sync, multi-user support, cloud services, or OS-specific secret management flows.

## Goals / Non-Goals

**Goals:**
- Provide a single local vault that can be created and unlocked with a master password.
- Encrypt all stored credential data at rest with authenticated encryption.
- Structure the app around presentation, application, domain, and infrastructure boundaries.
- Support the minimum useful user actions for a password manager MVP: vault setup, unlock/lock, credential CRUD, search, copy, and password generation.
- Keep the design portable across Windows, macOS, and Linux without introducing platform-specific product behavior in the MVP.

**Non-Goals:**
- Cloud sync, account systems, or multi-device sharing.
- Browser autofill, extensions, import/export, or breach monitoring.
- Strict DDD patterns such as aggregates, repositories per aggregate root, or domain events where they do not improve the MVP.
- Biometric unlock or OS keychain-based recovery in the first version.
- Database-level storage or partial record encryption; the MVP will use one encrypted vault file.

## Decisions

### Use a single encrypted vault file instead of SQLite
The MVP will persist all vault contents into one application-owned file under the local app data directory. The file will contain a small plaintext header with versioning and key derivation metadata, plus an encrypted payload for all sensitive content.

This is preferred over SQLite because the initial product scope is small, the data model is simple, and whole-vault encryption keeps security reasoning straightforward. SQLite with SQLCipher remains a future option if the vault grows in size or requires partial updates, but it would add integration complexity earlier than necessary.

### Encrypt with AES-256-GCM and derive the key from the master password
The vault payload will be encrypted with AES-256-GCM to provide confidentiality and integrity. The encryption key will be derived from the master password using a password-based KDF with per-vault salt and stored parameters.

Argon2id is the preferred KDF because it is better aligned with password-hardening requirements than PBKDF2. If implementation constraints on Flutter desktop make Argon2id impractical, PBKDF2 may be used as an explicit fallback with strong iteration settings documented in code and tests.

This approach is preferred over storing the raw master password, reversible local secrets, or relying on platform keychains, because the user explicitly wants a master-password-based vault and a local-only offline MVP.

### Model the application around use cases and ports
User actions will be represented as explicit application-layer use cases such as `CreateVault`, `UnlockVault`, `AddCredential`, and `GeneratePassword`. These use cases will depend on ports like `VaultRepository`, `CryptoService`, `ClipboardService`, and `Clock`.

This is preferred over coupling business logic to widgets or adopting a framework-heavy state management architecture first. It preserves clean seams for tests and lets the UI remain a thin adapter over the application layer.

Each use case will have its own automated unit tests with mocked or fake ports so business behavior is verified independently of Flutter widgets and platform IO. This is preferred over relying mainly on widget tests because the core product behavior is defined at the use-case layer.

Implementation will follow a tests-first workflow for the application layer: for each use case, write the failing tests first, then implement the minimum logic required to make them pass, and finally refactor if needed without weakening the contract. This is preferred over adding tests after the logic because it keeps the use-case boundary explicit and reduces accidental coupling between UI and business behavior.

### Keep unlocked state only in memory through a vault session
Once the user unlocks the vault, the decrypted data will live only in memory inside a session object until the user locks the vault, closes the app, or an inactivity timeout expires. The vault file on disk remains encrypted at all times.

This is preferred over constantly re-reading and re-decrypting the file on every action because the MVP needs responsive CRUD and search behavior without unnecessary IO or repeated password prompts. The trade-off is that session lifetime must be managed carefully.

### Search in memory and write the vault atomically
Credential search will run in memory over the unlocked vault contents. Any change to the vault will update the in-memory model, then serialize and write a complete new encrypted file, replacing the previous file atomically.

This is preferred over incremental patch writes because it reduces failure modes and keeps the persistence format easy to reason about. The trade-off is that writes rewrite the whole vault, which is acceptable for MVP-scale data.

### Provide clipboard safety as a first-class infrastructure concern
Copying usernames and passwords will go through a clipboard service rather than directly from the UI. The password copy flow must support timed clipboard cleanup so the app does not leave secrets indefinitely in the system clipboard.

This is preferred over direct clipboard access in widgets because the behavior is security-sensitive and should be testable and configurable.

## Risks / Trade-offs

- [Whole-vault file rewrites can become inefficient as data grows] -> Accept for MVP and keep repository boundaries clean so the storage engine can be replaced later.
- [Argon2id support may be uneven across Flutter desktop packages] -> Validate package viability before implementation and use PBKDF2 fallback only if necessary.
- [Secrets in memory remain exposed while the vault is unlocked] -> Keep session lifetime explicit, add lock and inactivity timeout behavior, and avoid unnecessary copies of decrypted data.
- [Clipboard cleanup behavior may vary by platform] -> Isolate clipboard behavior behind a service and cover the contract with platform-aware tests where feasible.
- [Use-case coverage may drift as new actions are added] -> Treat tests as part of the definition of done for each use case and keep task granularity aligned with individual use cases.
- [Tests-first discipline can erode under delivery pressure] -> Order tasks so tests precede logic for each use case and treat skipping that order as a process violation, not an optimization.
- [One-vault-per-installation limits advanced user workflows] -> Accept as an MVP simplification and defer multi-vault support until product value is proven.
