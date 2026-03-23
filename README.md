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
| Charts | fl_chart |
| File sharing | share_plus + path_provider |
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

For emulator use `http://10.0.2.2:3001/api`.

---

## Project structure

```
lib/
  core/
    theme/          ← AppTheme — single source of truth for colors & fonts
    constants/      ← route strings, API base URL, storage keys
    network/        ← Dio client + Bearer token interceptor + auto-refresh
    router/         ← GoRouter config (all routes)
  features/
    auth/           ← login, signup screens + auth provider (wired)
    budget/         ← budget setup screen + provider (wired)
    expenses/       ← home screen, expense list, add-expense sheet + provider (wired)
    analytics/      ← analytics screen + provider (mock data)
    goals/          ← goals screen + provider (mock data)
    challenges/     ← challenges section widget — lives inside goals tab (mock data)
    health/         ← health score detail screen (mock data)
    ai/             ← purchase advisor + chat coach screens + provider (mock data)
    settings/       ← settings screen + provider (partially wired)
    home/           ← main shell (bottom nav + FAB)
  shared/
    widgets/        ← ClutchButton, ClutchCard, LoadingIndicator
    extensions/     ← num.toRupees() currency formatter
  main.dart
```

**Note:** Challenges live inside the goals tab as a scrollable section — not a separate tab. Health score is accessible from the home screen card → pushes to `/health-score`.

---

## Screens & routes

| Route | Screen | Notes |
|---|---|---|
| `/login` | Login | Initial route |
| `/signup` | Signup | |
| `/shell` | Main shell | Bottom nav wrapper |
| `/budget-setup` | Budget setup | First-time + editable from settings |
| `/settings` | Settings | Accessible via gear icon in home AppBar |
| `/health-score` | Health score detail | Accessible via home screen card |
| `/chat` | Chat coach | Push from purchase advisor screen |

---

## Design system

- **Material 3** strict — `useMaterial3: true` always
- **Dark only** — no light theme, ever
- **Flat** — `elevation: 0` everywhere (FAB and dialogs excepted per M3 spec)
- **Palette** — M3 dark scheme seeded from `#00F5C4` (teal)
- **Font** — Space Grotesk via Google Fonts (wordmark only); M3 default type scale elsewhere
- **Spacing** — 8dp grid (multiples of 4, prefer 8)

Color tokens and component rules live in `lib/core/theme/app_theme.dart`. Never hardcode hex values in screen files — use `AppTheme.*` constants or `colorScheme.*` roles.

---

## Code generation

Run after any change to files with a `part '*.g.dart'` directive:

```bash
dart run build_runner build --delete-conflicting-outputs
```

Watch mode during active development:

```bash
dart run build_runner watch --delete-conflicting-outputs
```

> **Required after modifying any provider** — especially when changing from `Notifier` → `AsyncNotifier` or changing `keepAlive`. Always hot restart (not hot reload) after provider annotation changes.

---

## Key conventions

- `ConsumerWidget` by default — never bare `StatefulWidget`
- Form screens with controllers → `ConsumerStatefulWidget` (always `dispose()` controllers)
- Navigation → `context.go()` / `context.push()` only — never `Navigator.push`
- API calls → through `dioClientProvider` only — never add `Authorization` headers manually
- Currency → `someDouble.toRupees()` extension — never format rupees manually
- State updates → `ref.invalidate()` or `ref.read(provider.notifier).method()` — never `setState()`
- Dates from backend are UTC — convert with `DateTime.parse('${e.date}T${e.time}:00Z').toLocal()` before comparing to device local date

---

## Wiring status

### Done ✓
| Feature | Endpoints |
|---|---|
| Auth | POST /auth/login, POST /auth/signup, POST /auth/logout, POST /auth/refresh |
| Budget | GET /budget/current, POST /budget |
| Expenses | GET /expenses, POST /expenses, POST /expenses/categorize (Claude Haiku) |
| Settings (partial) | GET /user/profile, PUT /user/profile, PUT /user/preferences |

### Pending — next sessions
| Feature | Endpoints | Notes |
|---|---|---|
| Analytics | GET /analytics/summary | Full screen on mock data |
| Goals | GET /goals, POST /goals | Full screen on mock data |
| Challenges | GET /challenges/active, GET /challenges/available, POST /challenges/:id/join | Mock data inside goals tab |
| Health score | GET /health/score | Home card + detail screen on mock data |
| Purchase advisor | POST /advisor/analyze | Full screen on mock data |
| Chat coach | POST /chat/message | Full screen on mock data |
| Settings — password | PUT /user/password | ⚠️ Blocked: backend 500 (see backlog) |
| Expense delete | DELETE /expenses/:id | UI not implemented yet |

---

## Known backlog / blockers

| Issue | Root cause | Fix |
|---|---|---|
| Access token expires (1h) | Supabase JWT expiry default | Dashboard → Auth → Config: set JWT expiry to 86400. Turn off "Detect and revoke compromised refresh tokens" |
| Change password returns 500 | Backend likely missing `SUPABASE_SERVICE_ROLE_KEY`, or `supabase.auth.admin` failing | Add service role key to `.env`, or refactor to use `supabase.auth.updateUser()` with session token instead of admin API |

The token refresh interceptor is implemented in `lib/core/network/dio_client.dart` and will work correctly once the Supabase session settings are fixed.

---

## Backend integration

All API contracts, request/response shapes, error codes, and wiring order are documented in [`be-integration.md`](./be-integration.md).
