# clutch

> Gen Z budgeting app. Bold, minimal, fast.

Android-first Flutter app paired with a Node.js/Express backend ([clutch-backend](../clutch-backend)).

---

## Stack

| Concern | Package |
|---|---|
| State | flutter_riverpod + riverpod_annotation |
| Navigation | go_router |
| HTTP | dio |
| Token storage | flutter_secure_storage |
| Fonts | google_fonts (Space Grotesk) |
| Formatting | intl |
| Code gen | build_runner + riverpod_generator |
| Lint | custom_lint + riverpod_lint |

---

## Getting started

### Prerequisites
- Flutter SDK `^3.11.3`
- Dart `^3.x`
- Android SDK (for device/emulator)
- Node.js backend running locally (see clutch-backend)

### Install & run

```bash
# Install dependencies
flutter pub get

# Generate Riverpod providers & router
dart run build_runner build --delete-conflicting-outputs

# Run on connected device
flutter run
```

### Run on physical device (USB debugging)

Change `apiBaseUrl` in `lib/core/constants/app_constants.dart` to your machine's LAN IP before each session:

```dart
static const String apiBaseUrl = 'http://192.168.x.x:3001/api';
```

For emulator use `http://10.0.2.2:3001/api` (already the default).

---

## Project structure

```
lib/
  core/
    theme/          ← AppTheme — single source of truth for colors & fonts
    constants/      ← route strings, API base URL, storage keys
    network/        ← Dio client + Bearer token interceptor
    router/         ← GoRouter config
  features/
    auth/           ← login, signup screens + auth provider
    budget/         ← budget setup screen + provider
    expenses/       ← home screen, expense list, add-expense sheet + provider
    analytics/      ← analytics screen + provider
    goals/          ← goals screen + provider
    ai/             ← purchase advisor screen + provider
    home/           ← main shell (bottom nav + FAB)
  shared/
    widgets/        ← ClutchButton, ClutchCard, LoadingIndicator
    extensions/     ← num.toRupees() currency formatter
  main.dart
```

---

## Design system

- **Material 3** strict — `useMaterial3: true` always
- **Dark only** — no light theme, ever
- **Flat** — `elevation: 0` everywhere
- **Palette** — M3 dark scheme seeded from `#00F5C4` (teal)
- **Font** — Space Grotesk via Google Fonts
- **Spacing** — 8dp grid (multiples of 4, prefer 8)

Color tokens and component rules live in `lib/core/theme/app_theme.dart`. Never hardcode hex values in screen files — use `AppTheme.*` constants or `colorScheme.*` roles.

---

## Code generation

Run after any change to files with a `part '*.g.dart'` directive:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Or in watch mode during development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

---

## Key conventions

- `ConsumerWidget` by default — never bare `StatefulWidget`
- Form screens with controllers → `ConsumerStatefulWidget` (always `dispose()` controllers)
- Navigation → `context.go()` / `context.push()` only — never `Navigator.push`
- API calls → through `DioClient` only — never add `Authorization` headers manually
- Currency → `someDouble.toRupees()` extension — never format rupees manually

---

## Build status

- [x] M3 theme — Space Grotesk, teal palette, shape tokens
- [x] Auth screens — login, signup
- [x] Main shell — bottom nav, FAB
- [x] Home screen — daily header, budget card, expense list
- [x] Add expense sheet — custom numpad, tag input
- [x] Budget setup screen — amount, period, currency, distribution mode
- [ ] Wire auth — POST login/signup → backend, store token
- [ ] Wire expense logging — POST to backend
- [ ] Analytics screen
- [ ] Goals screen
- [ ] Purchase advisor (AI) screen
