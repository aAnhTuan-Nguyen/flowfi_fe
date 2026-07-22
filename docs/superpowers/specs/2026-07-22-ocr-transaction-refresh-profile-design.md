# OCR Transaction Refresh and Profile Header Design

## Scope

Fix the Flutter frontend behavior after a user confirms an OCR-created draft
transaction, and remove the duplicated personal-information heading from the
profile form. No backend changes or API contract changes are required.

## Confirmed backend behavior

The backend creates receipt-derived transactions with `Draft` status. Calling
`POST /transactions/:id/confirm` changes the same transaction to `Confirmed`,
applies its wallet balance effect exactly once, and returns the confirmed
transaction. `GET /transactions` reads the saved transaction from the database
and orders results by transaction date.

## Root cause

The frontend transaction notifier currently discards the transaction returned
by the confirm endpoint. It invalidates and reloads the transaction list, so the
visible state depends entirely on that follow-up request. The repository also
does not cache the returned confirmed transaction. If the list request fails
and falls back to local data, or returns an older snapshot, the wallet balance
can be current while the transaction UI remains stale.

## Transaction design

After confirmation, the repository will cache the confirmed transaction
returned by the backend. The presentation notifier will then merge that same
transaction into the latest list state by ID after the reload attempt. An
existing draft entry is replaced; a missing entry is inserted at the front.
This preserves the server refresh while guaranteeing that the successful
confirm response is represented immediately in the UI.

The OCR sheet remains responsible for refreshing other affected features:
wallets, budgets, goals, and notifications. It will continue removing the
confirmed draft from its local review result and showing the success message.

## Profile design

Keep the page-level `Hồ sơ cá nhân` heading because it is consistent with the
other feature screens. Remove the inner `Thông tin cá nhân` section heading and
its icon from the profile edit card. The card begins with the full-name field,
followed by email and the save button. The `Thiết lập` section heading remains
unchanged because it identifies a separate section.

## Error handling

A failed confirm request keeps the existing generic mutation error and does not
change local state. A successful confirm response is considered authoritative
for that transaction even if the subsequent list refresh returns stale cached
data.

## Tests

- Provider regression test: a repository returns a confirmed transaction while
  its next list call still returns a stale draft; provider state must contain
  one confirmed transaction with the same ID.
- Repository regression test: confirming a transaction writes the returned
  confirmed version to the local transaction cache.
- Profile widget test: `Hồ sơ cá nhân` appears once and `Thông tin cá nhân` is
  absent while profile editing and saving still work.
- Run the repository-required format, analyze, and full Flutter test commands.

## Out of scope

- Backend transaction behavior and endpoints.
- Redesigning other profile cards or navigation.
- Changing OCR extraction, transaction filters, pagination, or offline conflict
  rules.
