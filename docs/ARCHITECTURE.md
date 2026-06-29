# FlowFi Architecture

## Status

FlowFi uses feature-first Clean Architecture, scaled to the behavior that exists
today. The repository currently contains an application shell, a real
authentication slice, and read-first API slices for wallets, tags, transactions,
budgets, goals, and notifications.

Do not create every possible layer in advance. A feature should contain only the
files required by its current behavior.

## Current structure

```text
lib/
  app/                         Application widget and theme
  core/
    auth/                      Shared session/token storage infrastructure
    config/                    Temporary application configuration
    network/                   Shared HTTP client and auth interceptor
  di/                          Application dependency composition
  routes/                      GoRouter configuration
  features/auth/
    domain/                    User entity, repository contract, use cases
    data/                      Auth models, data source, repository implementation
    presentation/              Riverpod auth state and auth screens
  features/home/               Current dashboard shell content
  features/<tab>/              Read-first API slices and tab screens
  main.dart                    Application bootstrap
```

Future features should live under `lib/features/<feature>/` and may use this
shape when all three layers are justified:

```text
features/<feature>/
  domain/
    entities/
    repositories/
    usecases/
  data/
    models/
    datasources/
    repositories/
  presentation/
    providers/
    screens/
    widgets/
```

## Dependency direction

Dependencies point toward the domain:

```text
presentation -> domain <- data
                     ^
             composition in di
```

The auth request flow is:

```text
AuthGate / SignInScreen
  -> authControllerProvider
  -> SignInUseCase / BootstrapAuthSessionUseCase
  -> AuthRepository
  -> AuthRepositoryImpl
  -> DioAuthRemoteDataSource
```

Values return through the same boundaries in reverse. The application shell
knows the root screen through routing, while GetIt supplies concrete
implementations at startup.

## Layer responsibilities

### Domain

Domain code represents business concepts and actions. It must not import
Flutter, Riverpod, Dio, GetIt, GoRouter, data models, or presentation code.

- Entities contain business data without JSON or database knowledge.
- Repository files define abstract contracts.
- Use cases name meaningful application actions and depend on repository
  contracts.
- Do not add a use case only to rename a one-line operation unless it protects a
  feature boundary or business rule.

### Data

Data code implements domain contracts and owns external I/O details.

- Models own serialization and explicit domain mapping.
- Data sources communicate with HTTP, local storage, or device APIs.
- Repository implementations coordinate sources and return domain entities.
- Infrastructure exceptions are translated only when callers need stable,
  distinct recovery behavior.
- UI state, widgets, navigation, and user-facing messages do not belong here.

Auth uses Dio against the confirmed API map and stores only the refresh token in
secure storage. Access tokens stay in memory.

### Presentation

Presentation code renders state and forwards user intent.

- Riverpod providers and notifiers call use cases.
- Widgets use `ref.watch` for render state and `ref.read` in event handlers.
- Async workflows expose loading, data, empty, error, and retry behavior as
  needed.
- Widgets never call Dio, data sources, repository implementations, or GetIt.
- Network requests and state mutations do not start inside `build` methods.
- Business calculations do not belong in screens or notifiers.

## Foundation dependencies

### Riverpod

Riverpod owns presentation state. A narrow provider may bridge a GetIt-resolved
use case into the widget tree. Tests should override that provider rather than
mutating the global service locator.

### GetIt

GetIt is the composition root for Dio, data sources, repository implementations,
and use cases. Registrations belong in `lib/di/injection.dart` or a feature
registration function called from it. Widgets do not access the locator.

### Dio

`AppConfig.apiBaseUrl` reads `API_BASE_URL` from `.env` through
`flutter_dotenv`, with a local `/api/v1/` fallback when dotenv is not loaded.
Developers should keep local backend addresses in their ignored `.env` file and
use `.env.example` as the shared template. Authentication is handled by a Dio
interceptor that attaches the in-memory access token and refreshes it with the
stored refresh token after a 401. Never log sensitive financial payloads or
secrets.

### Token storage

Refresh tokens are persisted through `flutter_secure_storage`. Access tokens are
not persisted; they are kept in `AuthSessionManager` memory and recreated from
the refresh token during bootstrap.

### GoRouter

Route configuration belongs in `lib/routes`. Validate parameters and
`state.extra` instead of relying on unchecked casts. Routes that must support
deep links or restoration should load data by a stable identifier.

## FlowFi domain safeguards

These rules apply when real financial features are introduced:

- Store and calculate money with integer minor units or another precise format
  required by a confirmed contract, never binary floating point.
- Carry an explicit currency code with monetary values.
- Never combine different currencies without a defined exchange rate and
  conversion policy.
- Model an internal wallet transfer as one business operation with source and
  destination sides. It changes wallet balances but is not income or expense.
- Update both sides of a transfer atomically at the responsible persistence
  boundary.
- Treat voice, OCR, categorization, tags, and AI insights as untrusted
  suggestions until the user reviews and confirms them.
- Preserve identifiers needed for safe retries and synchronization so one user
  action cannot create duplicate financial records.
- Use explicit timestamps and time zones for financial events.

Offline support requires more than caching. Before implementing it, define
operation identity, durable queuing, ordering, retry behavior, conflict
resolution, and user-visible sync state.

## Errors and security

- Never use an empty `catch` or discard stack traces.
- Do not show raw exceptions, HTTP responses, or infrastructure messages in UI.
- Add typed failures only when the caller needs different recovery actions.
- Keep tokens, credentials, and environment-specific configuration out of
  source control.
- Treat local encryption, transport security, backend authorization, session
  expiration, and biometric access as separate controls.
- Minimize persistence, analytics, and logging of personal financial data.

## Adding a real feature

1. Define the smallest user-visible vertical slice.
2. Add a domain entity and repository contract only when business behavior needs
   them.
3. Add a use case for a meaningful action or invariant.
4. Implement models and data sources against a confirmed external contract.
5. Compose implementations in GetIt.
6. Bridge the use case into Riverpod state.
7. Add the screen and route only when the slice needs navigation.
8. Test each boundary and the visible async states.

Use the auth slice as the current dependency-flow reference, but keep future
features scoped to their own confirmed behavior.

## API implementation order

Auth is the first real feature and now serves as the architecture reference.
Future API integrations should follow `docs/API_MAP.md`, implement one visible
vertical slice at a time, and avoid adding offline/sync behavior until the
conflict policy is approved.

## Testing strategy

- Domain tests use fake repository implementations and no Flutter binding.
- Data-source tests replace HTTP, storage, or device boundaries.
- Repository tests verify delegation, mapping, and error translation.
- Provider tests override dependencies and cover state transitions.
- Widget tests wrap the app in `ProviderScope` and use a fresh router.
- Tests never rely on live APIs or shared user data.
