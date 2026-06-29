# FlowFi

FlowFi is an early-stage Flutter application for AI-assisted personal finance
management. The product direction includes transaction capture, wallets,
budgets, reports, financial insights, and offline synchronization.

## Current status

The repository contains the application foundation, a real authentication slice,
and placeholder dashboard tabs for the main FlowFi surfaces. Backend APIs are
mapped in [`docs/API_MAP.md`](docs/API_MAP.md); only authentication is wired in
the frontend so far.

## Foundation stack

- Flutter
- Riverpod for presentation state
- GetIt for dependency composition
- Dio for HTTP communication
- GoRouter for navigation
- flutter_secure_storage for persisted refresh-token storage

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

## Environment configuration

The app reads its API base URL from `.env` through `flutter_dotenv`.
Create a local `.env` from `.env.example` and adjust it for your backend:

```env
API_BASE_URL=http://localhost:3005/api/v1/
```

For the Android Emulator, use the host machine alias instead of `localhost`:

```env
API_BASE_URL=http://10.0.2.2:3005/api/v1/
```

The `.env` file is ignored by Git. Keep secrets out of it because Flutter
assets are bundled into the app.

## Development checks

Run these checks before submitting a change:

```sh
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Most product APIs, local persistence, AI/OCR providers, and offline conflict
handling have not been implemented in this frontend repository yet.
