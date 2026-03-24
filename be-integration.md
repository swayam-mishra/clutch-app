# Clutch — Backend Integration Spec

> **For:** Claude Code building/refactoring the `clutch-backend` (Node.js/Express)
> **Source of truth:** This file reflects exactly what the Flutter frontend expects.
> Do not deviate from the shapes defined here without updating the frontend simultaneously.

---

## 1. Infrastructure

### Base URL
```
http://<LAN_IP>:3001/api
```
- For USB debugging (OnePlus CPH2661): set to the machine's LAN IP before each session.
- In `lib/core/constants/app_constants.dart` → `apiBaseUrl`.

### Request headers (every request)
```
Content-Type: application/json
Accept: application/json
Authorization: Bearer <access_token>   ← injected automatically by Dio interceptor
```
The Bearer token is read from `FlutterSecureStorage` key `access_token` on every request. No manual headers in feature code — the interceptor handles it.

### Response envelope
All endpoints must respond with:
```json
// Success
{ "data": <payload> }

// Error
{ "error": "Human-readable message", "code": "SNAKE_CASE_ERROR_CODE" }
```
HTTP status codes: `200` success, `201` created, `400` bad request, `401` unauthorized, `404` not found, `422` validation error, `500` server error.

### Timeout
30 seconds connect + receive. Keep all AI endpoints under this limit.

---

## 2. Auth

### POST `/auth/login`
**Request:**
```json
{
  "email": "rahul@example.com",
  "password": "secret123"
}
```
**Response `data`:**
```json
{
  "accessToken": "eyJ...",
  "refreshToken": "eyJ...",
  "user": {
    "id": "uuid",
    "name": "Rahul Sharma",
    "email": "rahul@example.com"
  },
  "hasBudget": true
}
```
**Frontend behaviour after success:**
- Store `accessToken` → `flutter_secure_storage` key `access_token`
- Store `refreshToken` → `flutter_secure_storage` key `refresh_token`
- If `hasBudget: true` → `context.go('/shell')`
- If `hasBudget: false` → `context.go('/budget-setup')` (first-time user)

**Error codes:**
- `INVALID_CREDENTIALS` → show inline error under password field

---

### POST `/auth/signup`
**Request:**
```json
{
  "name": "Rahul Sharma",
  "email": "rahul@example.com",
  "password": "secret123"
}
```
**Response `data`:** Same shape as `/auth/login`. `hasBudget` will always be `false` for new users.

**Validation rules the frontend enforces (backend must also validate):**
- `name`: non-empty
- `email`: valid email format
- `password`: min 6 characters
- Frontend also collects `confirmPassword` but does NOT send it — validated client-side only

**Error codes:**
- `EMAIL_TAKEN` → show "email already in use" under email field

---

### POST `/auth/refresh`
**Request:**
```json
{ "refreshToken": "eyJ..." }
```
**Response `data`:**
```json
{ "accessToken": "eyJ..." }
```
Call this when any request returns `401`. Replace stored `access_token` and retry the original request once.

---

### POST `/auth/logout`
**Request:** empty body (token from header)
**Response `data`:** `{}`
Frontend clears both tokens from secure storage and navigates to `/login`.

---

## 3. User / Profile

### GET `/user/profile`
**Response `data`:**
```json
{
  "id": "uuid",
  "name": "Rahul Sharma",
  "email": "rahul@example.com"
}
```
Called on app startup to hydrate `SettingsNotifier`.

---

### PUT `/user/profile`
**Request:**
```json
{
  "name": "Rahul Sharma",
  "email": "rahul@example.com"
}
```
**Response `data`:** Same as GET profile.
Called from Settings screen → "save changes" button.

---

### PUT `/user/password`
**Request:**
```json
{
  "currentPassword": "old",
  "newPassword": "new"
}
```
**Response `data`:** `{}`

---

### PUT `/user/preferences`
**Request:**
```json
{
  "spendingAlerts": true,
  "goalReminders": true,
  "challengeNudges": false,
  "appLock": false
}
```
**Response `data`:** Echo back the same object.
Called any time a toggle changes in Settings screen.

---

## 4. Budget

### POST `/budget`
Called on first setup and when the user re-saves from settings.
**Request:**
```json
{
  "amount": 3000.0,
  "currency": "INR",
  "startDate": "2026-03-01",
  "endDate": "2026-03-31",
  "distribution": "distribute"
}
```
- `distribution`: `"distribute"` (spread leftover evenly) | `"carryover"` (add to tomorrow)
- `currency`: `"INR"` | `"USD"` | `"EUR"`

**Response `data`:**
```json
{
  "id": "uuid",
  "amount": 3000.0,
  "currency": "INR",
  "startDate": "2026-03-01",
  "endDate": "2026-03-31",
  "distribution": "distribute",
  "totalDays": 31,
  "dailyLimit": 96.77
}
```

---

### GET `/budget/current`
The most-called endpoint — drives the home screen header and stats.
**Response `data`:**
```json
{
  "id": "uuid",
  "amount": 3000.0,
  "currency": "INR",
  "startDate": "2026-03-01",
  "endDate": "2026-03-31",
  "distribution": "distribute",
  "totalDays": 31,
  "daysLeft": 12,
  "daysElapsed": 19,
  "spent": 670.0,
  "remaining": 2330.0,
  "dailyLimit": 194.17,
  "todayRemaining": 233.0,
  "todaySpent": 200.0,
  "percentUsed": 22.33,
  "month": "march 2026"
}
```
**Field notes:**
- `dailyLimit`: recomputed daily based on `remaining ÷ daysLeft` (with distribution mode applied)
- `todayRemaining`: today's limit minus today's spend
- `month`: display string, e.g. `"march 2026"` — used verbatim on home screen

---

## 5. Expenses

### POST `/expenses`
Called from `AddExpenseSheet` when user taps the ✓ confirm button.
**Request:**
```json
{
  "amount": 60.0,
  "tag": "chaat",
  "category": "Food & Dining",
  "confidence": 91
}
```
- `confidence`: 0–100, from the auto-categorize step. If user manually overrode the category, send `100`.
- Timestamp is set server-side.

**Response `data`:**
```json
{
  "id": "uuid",
  "date": "2026-03-23",
  "time": "09:12",
  "tag": "chaat",
  "category": "Food & Dining",
  "amount": 60.0,
  "confidence": 91
}
```

---

### GET `/expenses`
Drives both the Expenses screen list and the Home screen "today" section.

**Query params:**
| Param | Type | Description |
|---|---|---|
| `date` | `YYYY-MM-DD` | Filter by single date |
| `category` | string | Filter by category name |
| `search` | string | Full-text search on `tag` |
| `limit` | int | Default 50 |
| `offset` | int | Default 0 |

**Response `data`:**
```json
{
  "expenses": [
    {
      "id": "uuid",
      "date": "2026-03-23",
      "time": "09:12",
      "tag": "chaat",
      "category": "Food & Dining",
      "amount": 60.0
    }
  ],
  "total": 10,
  "hasMore": false
}
```

**Note on `icon`:** The frontend maps `category` → `IconData` client-side. The backend does NOT send icon data.

**Category strings (fixed set — must match exactly):**
```
"Food & Dining"
"Transport"
"Shopping"
"Entertainment"
"Health"
"Bills"
"Education"
"Other"
```

---

### POST `/expenses/categorize`
Called from `AddExpenseSheet` as the user types a tag (on text change, debounced ~500ms).
**Request:**
```json
{ "tag": "chaat" }
```
**Response `data`:**
```json
{
  "category": "Food & Dining",
  "confidence": 91
}
```
- `confidence`: 0–100 integer.
- Frontend shows the chip in `primaryContainer` if ≥ 80, `tertiaryContainer` if < 80.
- This calls Claude Haiku on the backend. Keep latency < 2s.

---

### DELETE `/expenses/:id`
**Response `data`:** `{}`
Not yet in the UI but needed for the full CRUD cycle.

---

## 6. Analytics

### GET `/analytics/summary`
Single endpoint that returns everything the Analytics screen needs.
**Response `data`:**
```json
{
  "budget": 3000.0,
  "spent": 670.0,
  "daysLeft": 12,
  "totalDays": 31,
  "startDate": "2026-03-01",
  "endDate": "2026-03-31",
  "percentUsed": 22.33,
  "minSpend": {
    "amount": 20.0,
    "tag": "cold drink",
    "datetime": "03 Mar 05:41"
  },
  "maxSpend": {
    "amount": 168.0,
    "tag": "food",
    "datetime": "05 Mar 06:09"
  },
  "totalCount": 10,
  "categories": {
    "Food & Dining": 380.0,
    "Transport": 180.0,
    "Shopping": 60.0,
    "Entertainment": 50.0
  },
  "weeklySpend": [120.0, 0.0, 168.0, 200.0, 92.0, 60.0, 30.0],
  "calendarData": {
    "1": 0.0, "3": 20.0, "4": 60.0, "5": 168.0,
    "6": 92.0, "11": 330.0
  }
}
```

**Field notes:**
- `weeklySpend`: 7 values, Mon→Sun of the current week, used for bar chart.
- `calendarData`: keys are day-of-month integers as strings ("1"–"31"), values are total spend for that day. Omit days with 0 spend or send `0`.
- `minSpend.datetime` / `maxSpend.datetime`: formatted string used verbatim in the UI ("03 Mar 05:41").

---

## 7. Goals

### GET `/goals`
**Response `data`:**
```json
{
  "goals": [
    {
      "id": "uuid",
      "name": "New MacBook",
      "iconKey": "laptop_mac",
      "targetAmount": 120000.0,
      "savedAmount": 45000.0,
      "targetDate": "2026-12-31",
      "daysRemaining": 283,
      "estimatedCompletion": "Oct 2026"
    }
  ]
}
```
**`iconKey`** — a string key the frontend maps to `IconData`. Frontend will maintain a mapping like:
```dart
const Map<String, IconData> _goalIcons = {
  'laptop_mac': Icons.laptop_mac_rounded,
  'beach_access': Icons.beach_access_rounded,
  'shield': Icons.shield_rounded,
  'smartphone': Icons.smartphone_rounded,
  'savings': Icons.savings_rounded,
  'home': Icons.home_rounded,
};
```
Send one of these keys from the backend. Default to `"savings"` if unknown.

**`estimatedCompletion`**: Computed by backend as "MMM YYYY" string, e.g. `"Oct 2026"`.

---

### POST `/goals`
**Request:**
```json
{
  "name": "Goa Trip",
  "iconKey": "beach_access",
  "targetAmount": 15000.0,
  "targetDate": "2026-06-01"
}
```
**Response `data`:** Full goal object (same shape as GET item).

---

### PUT `/goals/:id`
Used to add savings to a goal.
**Request:**
```json
{ "savedAmount": 9000.0 }
```
**Response `data`:** Full updated goal object.

---

## 8. Challenges

### GET `/challenges/active`
Returns challenges the user has joined and is currently running.
**Response `data`:**
```json
{
  "challenges": [
    {
      "id": "uuid",
      "name": "No Eating Out Week",
      "description": "Cook at home for 7 days straight",
      "iconKey": "no_meals",
      "difficulty": "medium",
      "duration": "7 days",
      "daysLeft": 4,
      "totalDays": 7,
      "progress": 0.43,
      "reward": "₹500 saved badge",
      "rewardIconKey": "emoji_events",
      "colorScheme": "primary"
    }
  ]
}
```
- `difficulty`: `"easy"` | `"medium"` | `"hard"`
- `colorScheme`: `"primary"` | `"tertiary"` — controls card background color on the UI
- `progress`: 0.0–1.0 float
- `iconKey` / `rewardIconKey`: same icon key mapping pattern as goals

---

### GET `/challenges/available`
Returns challenges in the catalog that the user has NOT joined.
**Response `data`:**
```json
{
  "challenges": [
    {
      "id": "uuid",
      "name": "30-Day Savings Streak",
      "description": "Save something every day for 30 days",
      "iconKey": "local_fire_department",
      "difficulty": "hard",
      "duration": "30 days",
      "reward": "Savings Streak badge",
      "rewardIconKey": "workspace_premium"
    }
  ]
}
```

---

### POST `/challenges/:id/join`
**Request:** empty body
**Response `data`:** The challenge object moved to the active list (full active challenge shape).

---

## 9. Purchase Advisor

### POST `/advisor/analyze`
Called when user taps "ask clutch →" in the AI tab.
**Request:**
```json
{
  "itemName": "new earphones",
  "price": 2500.0
}
```
**Response `data`:**
```json
{
  "verdict": "MAYBE",
  "explanation": "not the best time, but not terrible either.",
  "budgetImpact": 12.9,
  "velocityStatus": "high",
  "goalImpacts": [
    {
      "goalId": "uuid",
      "goalName": "Goa Trip",
      "delayDays": 3
    },
    {
      "goalId": "uuid",
      "goalName": "New MacBook",
      "delayDays": 0
    }
  ]
}
```

**Field notes:**
- `verdict`: `"YES"` | `"NO"` | `"MAYBE"` — displayed as uppercase badge in UI
  - `YES` → `primaryContainer` (green)
  - `MAYBE` → `tertiaryContainer` (amber)
  - `NO` → `errorContainer` (red)
- `budgetImpact`: float, percentage of remaining monthly budget this purchase represents
- `velocityStatus`: `"low"` | `"medium"` | `"high"` — shown in context card
- `goalImpacts`: sorted by `delayDays` descending. Only include active goals. `delayDays: 0` = "no impact".
- This calls Claude on the backend. Must respond in < 10s.

---

## 10. Chat / AI Coach

### POST `/chat/message`
Called each time the user sends a message in the Chat screen.
**Request:**
```json
{
  "message": "am I overspending?",
  "history": [
    { "role": "user", "content": "hey" },
    { "role": "assistant", "content": "hey! i know your finances..." }
  ]
}
```
**Response `data`:**
```json
{
  "response": "based on your spending this month, you're using ₹194/day on average..."
}
```
- `history`: the last N messages for context (frontend sends full history from session)
- The backend should inject the user's current financial context (budget state, recent expenses, goals) into the system prompt before calling Claude. The frontend does NOT send financial data — the backend fetches it using the authenticated user's token.
- Keep responses concise and conversational (lowercase, friendly tone matching the app).
- Must respond in < 15s.

---

## 11. Health Score

### GET `/health/score`
Called on Health Score detail screen load and to hydrate the home screen card.
**Response `data`:**
```json
{
  "score": 82,
  "status": "doing_well",
  "factors": {
    "adherence": {
      "score": 85,
      "description": "You stayed within budget on 24 of 31 days this month."
    },
    "velocity": {
      "score": 72,
      "description": "Your spending pace is slightly above target for the month."
    },
    "streak": {
      "score": 90,
      "description": "9-day logging streak — you're building a great habit."
    }
  },
  "trendScores": [74, 78, 80, 76, 82, 84, 82],
  "tips": [
    {
      "tip": "You overspent 3 days this week. Try the ₹200/day Cap challenge to build discipline.",
      "challengeName": "₹200/day Cap",
      "challengeIconKey": "price_check"
    },
    {
      "tip": "Your spending velocity is high mid-week. Plan your Tuesday purchases in advance.",
      "challengeName": null,
      "challengeIconKey": null
    }
  ]
}
```

**Field notes:**
- `status`: `"doing_well"` (≥80) | `"watch_out"` (60–79) | `"off_track"` (<60) — frontend maps to display label
- `factors.adherence.score`, `factors.velocity.score`, `factors.streak.score`: 0–100 integers
- `trendScores`: exactly 7 integers — health score for each of the last 7 days (Mon→Sun). Used for the sparkline chart.
- `tips`: 2–3 items. `challengeName` / `challengeIconKey` may be null if no challenge is linked.
- `challengeIconKey`: same icon key convention as goals/challenges.

---

## 12. Error Handling Contract

The frontend's Dio client does not currently have a global error interceptor — that will be added during wiring. The backend must be consistent.

### Error response shape
```json
{
  "error": "Email already in use",
  "code": "EMAIL_TAKEN"
}
```

### Error codes the frontend will explicitly handle

| Code | Where shown |
|---|---|
| `INVALID_CREDENTIALS` | Login screen — inline under password |
| `EMAIL_TAKEN` | Signup screen — inline under email |
| `TOKEN_EXPIRED` | Triggers token refresh (interceptor) |
| `TOKEN_INVALID` | Clears tokens, redirects to login |
| `BUDGET_NOT_FOUND` | Redirects to `/budget-setup` |
| `VALIDATION_ERROR` | Generic inline error |

All other errors: show a generic `SnackBar` with `error` string.

---

## 13. Dates & Numbers

| Concern | Format |
|---|---|
| Dates sent to backend | ISO 8601: `YYYY-MM-DD` |
| Datetimes sent to backend | ISO 8601: `YYYY-MM-DDTHH:mm:ssZ` |
| Dates received (display strings) | Backend formats as needed per field (see specs above) |
| Amounts | `double` / `float`, always 2 decimal places in JSON |
| Currency | Always INR (₹) for now — the `currency` field is stored but UI is India-only |

---

## 14. Wiring Order

Wire in this sequence — each step unblocks the next:

1. **Auth** — login + signup + token storage. Unblocks everything.
2. **Budget** — `GET /budget/current`. Unblocks home screen header (daily limit, remaining, today's spend).
3. **Expenses** — `POST /expenses` + `GET /expenses`. Unblocks home screen list + expenses tab.
4. **Auto-categorize** — `POST /expenses/categorize`. Unblocks the categorize chip in the expense sheet.
5. **Analytics** — `GET /analytics/summary`. Unblocks analytics tab.
6. **Goals** — `GET /goals`. Unblocks goals tab.
7. **Challenges** — `GET /challenges/active` + `GET /challenges/available`. Unblocks challenges section.
8. **Purchase Advisor** — `POST /advisor/analyze`. Unblocks AI tab.
9. **Health Score** — `GET /health/score`. Unblocks home card + detail screen.
10. **Chat** — `POST /chat/message`. Unblocks chat screen.
11. **User / Profile** — `GET /user/profile` + `PUT /user/profile`. Unblocks settings screen.

---

## 15. Provider Wiring Patterns

Each provider follows the same Riverpod `AsyncNotifier` pattern. Example for expenses:

```dart
// lib/features/expenses/providers/expense_provider.dart

@riverpod
class ExpenseNotifier extends _$ExpenseNotifier {
  @override
  Future<List<Expense>> build() async {
    final dio = ref.watch(dioClientProvider);
    final res = await dio.get('/expenses');
    return (res.data['data']['expenses'] as List)
        .map((e) => Expense.fromJson(e))
        .toList();
  }

  Future<void> logExpense({
    required double amount,
    required String tag,
    required String category,
    required int confidence,
  }) async {
    final dio = ref.read(dioClientProvider);
    await dio.post('/expenses', data: {
      'amount': amount,
      'tag': tag,
      'category': category,
      'confidence': confidence,
    });
    ref.invalidateSelf(); // triggers rebuild
  }
}
```

All providers use `ref.watch(dioClientProvider)` — never create `Dio` instances manually in feature code.

---

## 16. Token Storage Keys

```dart
// lib/core/constants/app_constants.dart
static const String accessTokenKey  = 'access_token';
static const String refreshTokenKey = 'refresh_token';
```

Both stored in `flutter_secure_storage`. The `_AuthInterceptor` in `dio_client.dart` reads `access_token` on every request automatically.