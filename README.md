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
    network/        ← Dio client + Bearer token interceptor
    router/         ← GoRouter config (all routes)
  features/
    auth/           ← login, signup screens + auth provider
    budget/         ← budget setup screen + provider
    expenses/       ← home screen, expense list, add-expense sheet + provider
    analytics/      ← analytics screen + provider (includes CSV export)
    goals/          ← goals screen + provider
    challenges/     ← challenges section widget (lives inside goals tab)
    health/         ← health score detail screen
    ai/             ← purchase advisor + chat coach screens + provider
    settings/       ← settings screen + settings provider
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

---

## Key conventions

- `ConsumerWidget` by default — never bare `StatefulWidget`
- Form screens with controllers → `ConsumerStatefulWidget` (always `dispose()` controllers)
- Navigation → `context.go()` / `context.push()` only — never `Navigator.push`
- API calls → through `dioClientProvider` only — never add `Authorization` headers manually
- Currency → `someDouble.toRupees()` extension — never format rupees manually
- State updates → `ref.invalidate()` or `ref.read(provider.notifier).method()` — never `setState()`

---

## Build status

All screens are complete with mock data. Backend wiring is the next phase.

**Frontend complete:**
- [x] M3 theme — teal palette, shape tokens, component rules
- [x] Auth screens — login, signup
- [x] Main shell — bottom nav (Home, AI, Analytics, Expenses, Goals), FAB
- [x] Home screen — daily budget header, budget card, stats, today's expenses, health score card, settings icon
- [x] Add expense sheet — custom numpad, tag input, auto-categorize UI (category chip + confidence badge + picker grid)
- [x] Budget setup — amount, period, currency, distribution mode (distribute / carryover)
- [x] Expense history — grouped by date, search, category filter
- [x] Analytics — budget card, days-left ring, min/max spend, category pie chart, calendar heatmap, CSV export
- [x] Goals — featured card, small cards, summary strip
- [x] Challenges — active challenges (progress bars) + available catalog (join button), inside goals tab
- [x] Purchase advisor — item + price input, verdict card, budget impact, velocity, goal impact
- [x] Chat coach — message history, input bar, mock responses
- [x] Health score — home card (ring progress, status, factor dots) + detail screen (breakdown, 7-day trend, AI tips linked to challenges)
- [x] Settings — inline profile editing, notification toggles, security, about, logout

**Backend wiring (pending):**
- [ ] Auth — POST login/signup → store token → navigate
- [ ] Budget — GET current, POST setup
- [ ] Expenses — POST log, GET list, POST auto-categorize
- [ ] Analytics — GET summary
- [ ] Goals — GET list, POST create
- [ ] Challenges — GET active/available, POST join
- [ ] Purchase advisor — POST analyze
- [ ] Health score — GET score
- [ ] Chat — POST message
- [ ] Settings — GET/PUT profile

See [`be-integration.md`](./be-integration.md) for the full backend API spec.

---

## Backend integration

All API contracts, request/response shapes, error codes, and wiring order are documented in [`be-integration.md`](./be-integration.md). Hand this file to the backend to ensure the API is built to exactly what the frontend expects.
