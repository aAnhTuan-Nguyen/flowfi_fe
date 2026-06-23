# FlowFi

FlowFi is an early-stage Flutter application for AI-assisted personal finance
management. The product direction includes transaction capture, wallets,
budgets, reports, financial insights, and offline synchronization.

## Current status

The repository contains the application foundation plus temporary product UI
screens for the current frontend direction. Backend contracts, persistence,
authentication, AI/OCR providers, and offline synchronization are still being
defined.

## Foundation stack

- Flutter
- Riverpod for presentation state
- GetIt for dependency composition
- Dio for HTTP communication
- GoRouter for navigation

Detailed design and dependency rules are documented in
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) and
[`docs/DESIGN.md`](docs/DESIGN.md). Coding-agent rules are in
[`AGENTS.md`](AGENTS.md).

## Run locally

Check the Flutter environment and install dependencies:

```sh
flutter doctor
flutter pub get
```

Run on an available device:

```sh
flutter devices
flutter run -d <device-id>
```

## Development checks

Run these checks before submitting a change:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Backend contracts, persistence, authentication, AI/OCR providers, and offline
conflict handling have not been selected in this frontend repository yet.
