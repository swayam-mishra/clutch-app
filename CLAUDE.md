# Clutch — Claude Code Reference

## 1. Project Overview

- **Name:** Clutch
- **Type:** Flutter mobile app, Android-first
- **Purpose:** Gen Z budgeting app — bold, minimal, fast
- **Backend:** Separate repo `clutch-backend` (Node.js/Express)
- **Test device:** OnePlus CPH2661, USB debugging
- **Package:** `com.example.clutch_app` (update before production)

---

## 2. Tech Stack

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
| Charts | fl_chart |

Run after any change to files with `part '*.g.dart'`:
```bash
dart run build_runner build --delete-conflicting-outputs
```

---

## 3. Design System

### Philosophy
- Material 3 strict — `useMaterial3: true` always
- Dark only — no light theme, ever
- Flat — `elevation: 0` everywhere, no shadows
- Every color in screen files comes from `colorScheme` or `AppTheme.*` constants — never hardcode hex in screens (only exception: `clutch` wordmark uses `AppTheme.accent` directly)

### Color Tokens — M3 Dark Scheme (seed: #00F5C4)

| Role | Hex |
|---|---|
| primary | `#88D6BB` |
| onPrimary | `#00382B` |
| primaryContainer | `#00513F` |
| onPrimaryContainer | `#A3F2D6` |
| secondary | `#B2CCC1` |
| onSecondary | `#1E352D` |
| secondaryContainer | `#344C43` |
| onSecondaryContainer | `#CEE9DD` |
| tertiary | `#A8CBE2` |
| onTertiary | `#0C3446` |
| tertiaryContainer | `#274B5D` |
| onTertiaryContainer | `#C3E8FE` |
| error | `#FFB4AB` |
| onError | `#690005` |
| errorContainer | `#93000A` |
| onErrorContainer | `#FFDAD6` |
| surface | `#0F1512` |
| onSurface | `#DEE4DF` |
| surfaceContainerHighest | `#3F4945` |
| onSurfaceVariant | `#BFC9C3` |
| outline | `#89938E` |
| outlineVariant | `#3F4945` |
| inverseSurface | `#DEE4DF` |
| onInverseSurface | `#2C322F` |
| inversePrimary | `#146B55` |

**Surface container scale:**
| Token | Hex |
|---|---|
| surfaceContainerLowest | `#090F0D` |
| surfaceContainerLow | `#171D1A` |
| surfaceContainer | `#1B211E` |
| surfaceContainerHigh | `#252B29` |
| surfaceContainerHighest | `#303633` |

**AppTheme static constants** — use these in widgets, never raw hex:

| Constant | Hex | M3 role |
|---|---|---|
| `AppTheme.background` | `#0F1512` | surface / dark.background |
| `AppTheme.surface` | `#1B211E` | surfaceContainer |
| `AppTheme.card` | `#252B29` | surfaceContainerHigh |
| `AppTheme.accent` | `#88D6BB` | primary |
| `AppTheme.accentText` | `#00382B` | onPrimary |
| `AppTheme.textPrimary` | `#DEE4DF` | onSurface |
| `AppTheme.textSecondary` | `#BFC9C3` | onSurfaceVariant |
| `AppTheme.divider` | `#3F4945` | outlineVariant |
| `AppTheme.error` | `#FFB4AB` | error |
| `AppTheme.budgetGood` | `#40AC02` | budget healthy (domain semantic) |
| `AppTheme.budgetWarning` | `#E8A020` | budget caution (domain semantic) |
| `AppTheme.budgetBad` | `#C70909` | budget overspent (domain semantic) |

**Budget state helper:** `AppTheme.budgetStateColor(spentFraction)` returns the correct semantic color. Use instead of ad-hoc color comparisons for budget health.

### Typography

Typeface: **Manrope** (variable font via `google_fonts` package). `AppTheme._textTheme` defines all 15 M3 scale entries with Manrope at targeted weights (w700 for display, w600 for headlines/titles, w500/w400 for body/labels). `google_fonts` is intentionally imported in `app_theme.dart` — this is the one allowed exception.

Always use `Theme.of(context).textTheme.*` in screens. Never hardcode font sizes.

### Shape Tokens (M3 — never use pill or StadiumBorder)

| Token | Radius | Used on |
|---|---|---|
| Extra small | 4px | error borders |
| Small | 8px | chips |
| Medium | 12px | input fields, cards |
| Large | 16px | buttons, list tiles |
| Extra large | 28px | bottom sheets (top corners), dialogs |

### Spacing — 8dp Grid

Valid values: `4, 8, 12, 16, 24, 32, 40, 48, 64`. Always a multiple of 4, prefer multiples of 8.

### Component Rules

**Buttons:**
- `FilledButton` → primary action (log in, save, confirm, submit)
- `OutlinedButton` → secondary action (create account, cancel)
- `TextButton` → tertiary (forgot password, inline links)
- **Never use `ElevatedButton`**

`FilledButton` theme uses `ButtonStyle` with `WidgetStateProperty.all()` — not `styleFrom()` — to prevent M3 from overriding shape with stadium default.

**Input fields:**
- `filled: true`, `fillColor: AppTheme.surface`
- No border on any state (enabled, focused, error uses outline only)
- Radius: 12px (medium token)
- `cursorColor: AppTheme.textSecondary` on every `TextField`
- Never repeat `filled`/`fillColor`/`border` overrides in screen files — let the theme handle it

**Cards:** `AppTheme.card` background, 12px radius, elevation 0, margin zero

**AppBar:** `AppTheme.background` color, elevation 0, `scrolledUnderElevation: 2` (tonal lift when content scrolls under), `centerTitle: true`

**NavigationBar:** `AppTheme.surface` bg, height 64, elevation 2 with shadow

**Elevation rules (M3 spec):**
- FAB: elevation 6 (resting), focus/hover 8, highlight 12 — shadow visible
- Bottom sheets: scrim at `colorScheme.scrim.withValues(alpha: 0.32)`
- NavigationBar: elevation 2
- AppBar: resting 0, scrolledUnder 2 (tonal)
- Cards: NO shadows — use tonal surface colors instead
- Dialogs: elevation 6
- Never add arbitrary shadows to containers or cards
- Tonal difference via surfaceContainer levels is the primary elevation language in this app

**BottomSheet:** `AppTheme.surface` bg, top corners 28px, elevation 0

**Snackbar:** 4px radius, floating behavior

---

## 4. Folder Structure

```
lib/
  core/
    theme/app_theme.dart          ← single source of truth: colors, fonts, ThemeData
    constants/app_constants.dart  ← apiBaseUrl, route strings, storage keys
    network/dio_client.dart       ← Dio instance + Bearer token interceptor
    router/app_router.dart        ← all GoRouter route definitions
  features/
    auth/
      screens/login_screen.dart
      screens/signup_screen.dart
      providers/auth_provider.dart
    budget/
      screens/budget_setup_screen.dart
      providers/budget_provider.dart
    expenses/
      screens/home_screen.dart
      providers/expense_provider.dart
    analytics/
      screens/analytics_screen.dart
      providers/analytics_provider.dart
    goals/
      screens/goals_screen.dart
      providers/goals_provider.dart
    challenges/
      widgets/challenges_section.dart  ← challenges live inside goals screen as a section, not a separate tab. Access via goals tab → scroll down.
    ai/
      screens/purchase_advisor_screen.dart  ← main AI tab
      screens/chat_screen.dart              ← push route from advisor (/chat)
      providers/ai_provider.dart
  shared/
    widgets/
      clutch_button.dart        ← primary CTA button
      clutch_card.dart          ← base card container
      loading_indicator.dart    ← centered CircularProgressIndicator
      animated_number.dart      ← character-level slide animation for numeric values
      budget_pill.dart          ← status-aware pill (good/warning/bad), reads budgetNotifierProvider
      clutch_keyboard.dart      ← animated numpad (pill→rect on press), 3 key types
    extensions/
      currency_extension.dart   ← num.toRupees() → ₹1,234
  main.dart                     ← ProviderScope + MaterialApp.router
```

---

## 5. State Management

- Use `ConsumerWidget` by default — never `StatefulWidget`
- **Exception:** form screens with `TextEditingController` may use `ConsumerStatefulWidget` (never bare `StatefulWidget`) — always `dispose()` every controller
- All providers use `@riverpod` / `@Riverpod(keepAlive: true)` annotations — never bare `Provider()`
- Infrastructure providers (`dioClient`, `secureStorage`, `appRouter`) have `keepAlive: true`
- Feature providers use `AsyncNotifier` for async data, `Notifier` for sync state
- Never call `setState()` — use `ref.invalidate()` or `ref.read(provider.notifier).method()`

---

## 6. Navigation

- `go_router` only — never `Navigator.push`
- `context.go('/route')` — replaces stack (use for auth transitions)
- `context.push('/route')` — pushes on stack (use for drill-down)
- `context.pop()` — go back (only when pushed, not when `go`'d)
- All route path strings live in `AppConstants` — never hardcode `/home` etc. in screen files
- Router is a Riverpod provider (`appRouterProvider`) injected into `MaterialApp.router`
- Initial route: `/login`

**Current routes:**
| Constant | Path |
|---|---|
| `AppConstants.routeLogin` | `/login` |
| `AppConstants.routeSignup` | `/signup` |
| `AppConstants.routeHome` | `/home` |
| `AppConstants.routeBudgetSetup` | `/budget-setup` |
| `AppConstants.routePurchaseAdvisor` | `/purchase-advisor` |
| `AppConstants.routeChat` | `/chat` |
| `AppConstants.routeSettings` | `/settings` |
| `AppConstants.routeHealthScore` | `/health-score` |

**Shell tab structure (4 tabs):**
| Index | Label | Screen |
|---|---|---|
| 0 | home | `HomeScreen` — editor-first, always-visible keyboard |
| 1 | analytics | `AnalyticsScreen` |
| 2 | expenses | `ExpensesScreen` |
| 3 | goals | `GoalsScreen` |

Settings is **not a tab** — accessed via the ⚙️ icon in HomeScreen header → `context.push(AppConstants.routeSettings)`. Health score is a push route from the analytics screen health mini-card.

---

## 7. API & Networking

- All API calls go through `DioClient` (`lib/core/network/dio_client.dart`)
- Base URL in `AppConstants.apiBaseUrl`
- **Android emulator:** `http://10.0.2.2:3001/api`
- **USB debugging (OnePlus CPH2661):** change `apiBaseUrl` to machine's LAN IP before each session, e.g. `http://192.168.x.x:3001/api`
- Auth token stored in `flutter_secure_storage` under `AppConstants.accessTokenKey`
- Every protected request auto-injects `Bearer <token>` via Dio interceptor — never add `Authorization` headers manually in feature code

---

## 8. Currency Formatting

Always use the extension method — never format rupees manually:
```dart
someDouble.toRupees()  // → ₹1,234
```
Located at `lib/shared/extensions/currency_extension.dart`.

---

## 9. Non-Negotiable Rules

| Rule | Detail |
|---|---|
| No hardcoded hex in screens | Use `AppTheme.*` or `colorScheme.*` |
| No `ElevatedButton` | Use `FilledButton` / `OutlinedButton` / `TextButton` |
| No light theme | Dark only, always |
| No elevation or shadows | `elevation: 0` everywhere |
| No pill/stadium shapes | Use shape token scale (4/8/12/16/28px) |
| No `Navigator.push` | Use `context.go()` / `context.push()` |
| No `StatefulWidget` | Use `ConsumerWidget` or `ConsumerStatefulWidget` |
| No `setState()` | Use Riverpod |
| No hardcoded font sizes | Use `textTheme.*` (wordmark exception only) |
| Spacing on 8dp grid | Multiples of 4, prefer 8 |

---

## 10. Build Status

**Completed:**
- Full M3 theme — Space Grotesk, Teal Punch palette, `ButtonStyle` shape fix
- `login_screen.dart` — `ConsumerWidget`, `FilledButton` + `OutlinedButton`
- `signup_screen.dart` — `ConsumerStatefulWidget`, 4 fields, visibility toggle
- All feature providers stubbed
- All routes wired in `app_router.dart`
- Dio client with Bearer token interceptor

**Next:**
- Wire auth: login/signup POST → backend, store token, navigate to `/home`
- Home screen: "for today" header + large numpad expense entry
- Budget setup flow
