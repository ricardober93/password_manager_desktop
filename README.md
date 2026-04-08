# Password Manager Desktop

Password Manager Desktop is a local-first Flutter desktop application for storing credentials in a single encrypted vault file. The app keeps vault contents encrypted at rest, unlocks them only in memory for the active session, and provides a calm desktop workflow for browsing, editing, searching, and copying credentials.

## Highlights

- Local encrypted vault protected by a master password
- Desktop-first interface with persistent navigation, list, and detail/editor panels
- Credential create, read, update, delete, search, and clipboard copy flows
- Built-in password generator with adjustable policy controls
- Automatic lock support through the session inactivity monitor
- Test coverage for core application and widget flows

## Tech Stack

- Flutter desktop
- Dart
- `cryptography` for vault encryption and key derivation
- Layered architecture across presentation, application, domain, and infrastructure

## Project Structure

```text
lib/
  app.dart
  bootstrap.dart
  main.dart
  application/
  domain/
  infrastructure/
  presentation/
    app_controller.dart
    theme/
    widgets/

test/
  application/
  infrastructure/
  widget_test.dart

openspec/
  changes/
```

## Run Locally

1. Install Flutter with desktop support enabled.
2. Restore dependencies:

```bash
flutter pub get
```

3. Run the Windows desktop app:

```bash
flutter run -d windows
```

You can replace `windows` with `linux` or `macos` if that desktop target is enabled in your environment.

## Validation

Run static analysis:

```bash
flutter analyze
```

Run the test suite:

```bash
flutter test
```

## Build a Downloadable Windows App

Generate the Windows release build:

```bash
flutter build windows --release
```

The compiled app is produced under:

```text
build/windows/x64/runner/Release/
```

To create a distributable zip:

```bash
powershell Compress-Archive -Path build/windows/x64/runner/Release/* -DestinationPath build/password-manager-desktop-windows.zip -Force
```

## Recent UI Refresh

The current interface was refreshed around these goals:

- Minimal, security-focused visual language
- Desktop-first three-zone layout
- In-context detail and edit flows instead of dialog-heavy interaction
- Quieter feedback for copy, save, error, and lock states

The corresponding OpenSpec change lives in:

```text
openspec/changes/desktop-ui-refresh/
```

## Notes

- The vault remains encrypted on disk at all times.
- Unlocking creates an in-memory session only for the current app lifecycle.
- Clipboard handling and session timeout behavior are implemented through the application and infrastructure layers rather than widget-only logic.
