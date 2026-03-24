# clutch

> Gen Z budgeting app. Bold, minimal, fast.

Android-first Flutter app paired with a Node.js/Express backend ([clutch-backend](../clutch-backend)).

---

## Getting started

```bash
flutter pub get
dart run build_runner build --delete-conflicting-outputs
flutter run
```

**Physical device:** set `apiBaseUrl` in `lib/core/constants/app_constants.dart` to your machine's LAN IP (`http://192.168.x.x:3001/api`). Emulator uses `http://10.0.2.2:3001/api`.

> After modifying any Riverpod provider, always **hot restart** (not hot reload).

---

## What's built

All screens are complete and wired to the backend. Everything runs on real data.

| Screen | Status |
|---|---|
| Login / Signup | ✓ |
| Budget setup | ✓ |
| Home — daily header, expense logging, auto-categorize (Claude Haiku) | ✓ |
| Expense history | ✓ |
| Analytics — budget, spend, charts, heatmap, CSV export | ✓ |
| Goals — cards, add goal sheet | ✓ |
| Challenges — active progress + catalog, join | ✓ |
| Purchase advisor — verdict, budget impact, goal delays | ✓ |
| Chat coach — conversation with history | ✓ |
| Health score | ⚠️ backend 500 (backlog) |
| Settings — profile, preferences, logout | ✓ (change password blocked — see backlog) |

---

## Project structure

```
lib/
  core/
    theme/        ← colors, fonts, component rules
    constants/    ← routes, API URL, storage keys
    network/      ← Dio + auth interceptor + token refresh
    router/       ← all GoRouter routes
  features/
    auth/         ← login, signup
    budget/       ← budget setup
    expenses/     ← home screen, expense list, add-expense sheet
    analytics/    ← analytics screen
    goals/        ← goals screen
    challenges/   ← section inside goals tab
    health/       ← health score detail screen
    ai/           ← purchase advisor + chat coach
    settings/     ← settings screen
    home/         ← bottom nav shell + FAB
  shared/
    widgets/      ← shared UI components
    extensions/   ← num.toRupees()
  main.dart
```

---

## Known backlog

| Issue | Fix |
|---|---|
| Access token expires (1h) | Supabase dashboard → Auth → Sessions: increase JWT expiry, turn off "Detect and revoke compromised refresh tokens" |
| Health score returns 500 | Debug `healthScore.controller.ts` catch block on backend |
| Change password returns 500 | Add `SUPABASE_SERVICE_ROLE_KEY` to backend `.env`, or refactor to `supabase.auth.updateUser()` |

---

## Backend integration

API contracts and wiring details → [`be-integration.md`](./be-integration.md)
