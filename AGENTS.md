# FlowFi Agent Rules

These rules apply to the entire repository. Read
[`docs/ARCHITECTURE.md`](docs/ARCHITECTURE.md) and
[`docs/DESIGN.md`](docs/DESIGN.md) before adding or moving application code.

## Current project state

FlowFi is a Flutter frontend at the foundation stage. The disposable
`features/example` vertical slice demonstrates the intended architecture but is
not a production feature. It may be copied selectively and then deleted.

Do not treat planned product capabilities as implemented. Backend contracts,
storage, authentication, AI/OCR services, and offline conflict rules remain
undecided until code or an approved specification establishes them.

## Before changing code

1. Read `pubspec.yaml` and the files relevant to the task.
2. Check `docs/ARCHITECTURE.md` for dependency and placement rules.
3. Follow the nearest real feature when it is a valid precedent.
4. Check current official documentation before using an uncertain package API.
5. Preserve unrelated work and existing public APIs.

## Implementation rules

- Make the smallest coherent change that satisfies the active task.
- Keep dependencies pointing inward: `presentation -> domain <- data`.
- Widgets render state and forward intent; they do not call Dio, data sources,
  repository implementations, or GetIt directly.
- Riverpod owns presentation state. GetIt composes infrastructure,
  repositories, and use cases.
- Models own serialization and map explicitly to domain entities.
- Create folders and abstractions only when they contain real behavior.
- Do not add packages, generators, base classes, or patterns speculatively.
- Do not invent API endpoints, payloads, database schemas, or sync semantics.
- Do not edit generated platform files unless platform configuration is part of
  the task.

## FlowFi safeguards

- Do not use binary floating point for persisted or calculated money.
- Keep currency explicit and never combine currencies without a conversion
  rule.
- Internal transfers affect wallet balances but are not income or expense.
- Treat AI, voice, OCR, categories, and tags as suggestions until the user
  confirms them.
- Do not log credentials, tokens, receipts, personal data, balances, or full
  financial payloads.
- Never swallow exceptions or display raw infrastructure errors to users.

## Testing and completion

- Add focused tests for new behavior and regression tests for bug fixes.
- Replace external services with fakes in tests; never depend on a live API.
- Test loading, success, empty, error, and retry states when the UI exposes
  them.
- Update documentation when architecture or setup changes.

Before reporting completion, run fresh checks:

```powershell
dart format --output=none --set-exit-if-changed lib test
flutter analyze
flutter test
```

Report any command that cannot run or does not pass. Do not claim success
without fresh output.
