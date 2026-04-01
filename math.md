# Buckwheat — Math & Calculations Reference

All mathematical logic in the app, organized by feature. For each calculation: what it computes, the exact formula, the source file, and why it exists.

All monetary values use `BigDecimal` with `RoundingMode.HALF_EVEN` at scale 2 unless noted.

---

## 1. Daily Budget Allocation

**File:** [app/src/main/java/com/danilkinkin/buckwheat/di/SpendsRepository.kt](app/src/main/java/com/danilkinkin/buckwheat/di/SpendsRepository.kt)  
**Function:** `whatBudgetForDay(excludeCurrentDay, applyTodaySpends, notCommittedSpent)`

### What it computes
How much money the user gets to spend per day, given the budget left and days remaining.

### Formula

```
restBudget = budget - spent - notCommittedSpent

if applyTodaySpends:
    restBudget -= spentFromDailyBudget
else if excludeCurrentDay:
    restBudget -= dailyBudget

restDays = countDays(finishDate, today) - (1 if excludeCurrentDay else 0)

dailyBudget = restBudget / max(restDays, 1)   // scale 2, HALF_EVEN
```

### Why
The budget covers a fixed date range. Each day needs an equal share of what's left. The function is called in two modes:
- **Live (while typing):** `applyTodaySpends=true, notCommittedSpent=currentInput` — shows what tomorrow's budget would be if the user commits this expense right now.
- **End of day:** `excludeCurrentDay=true` — computes tomorrow's allocation after today is closed out.

---

## 2. Remaining Budget Balance

**File:** [app/src/main/java/com/danilkinkin/buckwheat/di/SpendsRepository.kt](app/src/main/java/com/danilkinkin/buckwheat/di/SpendsRepository.kt)  
**Function:** `howMuchBudgetRest()`

### What it computes
Total money left in the entire budget period right now.

### Formula

```
restBudget = budget - spent - spentFromDailyBudget
```

### Why
`spent` tracks money committed to past days. `spentFromDailyBudget` tracks today's spending (not yet committed to `spent`). Both must be subtracted to get the true current balance.

---

## 3. Unspent Budget (Skipped Days Recovery)

**File:** [app/src/main/java/com/danilkinkin/buckwheat/di/SpendsRepository.kt](app/src/main/java/com/danilkinkin/buckwheat/di/SpendsRepository.kt)  
**Function:** `howMuchNotSpent(excludeSkippedPart)`

### What it computes
How much of the unspent budget from skipped days can be recovered and redistributed. Used when the user missed opening the app for several days.

### Formula

```
restDays    = countDays(finishDate, today)
skippedDays = countDays(today, lastChangeDailyBudgetDate) - 1
restBudget  = budget - spent

if restDays == 0:
    result = restBudget - spentFromDailyBudget

else if excludeSkippedPart:
    // Recover only the skipped portion, leave the rest in the pool
    result = (restBudget - dailyBudget * skippedDays) / restDays * skippedDays
           + (dailyBudget - spentFromDailyBudget)

else:
    // Spread everything (including skipped days) across all remaining days
    result = (restBudget - dailyBudget) / (restDays + skippedDays - 1) * skippedDays
           + (dailyBudget - spentFromDailyBudget)
```

### Why
If the user doesn't open the app on day 3, day 3's budget is neither spent nor rolled over automatically. `howMuchNotSpent` calculates the windfall from those idle days. The two modes give the user a choice:
- **Split to rest days** (`excludeSkippedPart=false`): spread all the windfall evenly.
- **Add to today** (`excludeSkippedPart=true`): give today a bigger budget without changing future days.

---

## 4. Next Day Budget Projection

**File:** [app/src/main/java/com/danilkinkin/buckwheat/di/SpendsRepository.kt](app/src/main/java/com/danilkinkin/buckwheat/di/SpendsRepository.kt)  
**Function:** `nextDayBudget(excludeSkippedPart)`

### What it computes
What tomorrow's daily budget will be after recovery is applied.

### Formula
Same logic as `howMuchNotSpent()` but the final `+ (dailyBudget - spentFromDailyBudget)` term is omitted — it's the projection without today's remainder.

### Why
Shown in the recalculation UI so the user can preview next-day allocation before confirming.

---

## 5. Daily Budget Rollover

**File:** [app/src/main/java/com/danilkinkin/buckwheat/di/SpendsRepository.kt](app/src/main/java/com/danilkinkin/buckwheat/di/SpendsRepository.kt)  
**Function:** `setDailyBudget(newDailyBudget)`

### What it computes
Closes out today: moves today's spending into the period total, then resets the daily counter.

### Formula

```
spent                = spent + spentFromDailyBudget
spentFromDailyBudget = 0
dailyBudget          = newDailyBudget
```

### Why
The app tracks two separate spending buckets: `spentFromDailyBudget` (today, uncommitted) and `spent` (all prior days, committed). At end of day, today's bucket is drained into the total so the next day starts clean.

---

## 6. Past-Day Expense Spreading

**File:** [app/src/main/java/com/danilkinkin/buckwheat/di/SpendsRepository.kt](app/src/main/java/com/danilkinkin/buckwheat/di/SpendsRepository.kt)  
**Functions:** `addSpent()`, `removeSpent()` (for transactions dated before today)

### What it computes
When adding or deleting an expense from a previous day, how to adjust the remaining daily budget.

### Formula

```
// Adding a past expense:
spreadDelta          = value / countDays(finishDate, today)   // scale 2, HALF_EVEN
spent               += value
dailyBudget         -= spreadDelta

// Removing a past expense:
spreadDelta          = value / countDays(finishDate, today)
dailyBudget         += spreadDelta
spent               -= value
```

### Why
A past-day expense reduces the total budget remaining. Rather than cutting one future day's budget entirely, the impact is spread evenly across all remaining days so the reduction is proportional.

---

## 7. Budget Percentage — Analytics Card

**File:** [app/src/main/java/com/danilkinkin/buckwheat/analytics/RestAndSpentBudgetCard.kt](app/src/main/java/com/danilkinkin/buckwheat/analytics/RestAndSpentBudgetCard.kt)

### What it computes
Percentage of the total budget that is remaining (or spent).

### Formula

```
percent          = restBudget / wholeBudget          // scale 4, HALF_EVEN

// For the "rest" card:
display%         = percent * 100

// For the "spent" card:
display%         = (1 - percent) * 100

// Overflow guard:
if |display%| > 1000:
    display% = clamp(display%, -1000, 1000)   // prefixed with "over"
```

### Why
Dividing at scale 4 preserves precision before multiplying by 100. The ±1000% clamp prevents absurd display values when restBudget greatly exceeds wholeBudget (e.g., after editing budget mid-period).

---

## 8. Budget Percentage — Spends Budget Card

**File:** [app/src/main/java/com/danilkinkin/buckwheat/analytics/SpendsBudgetCard.kt](app/src/main/java/com/danilkinkin/buckwheat/analytics/SpendsBudgetCard.kt)

### What it computes
Fraction of budget still remaining, for animated card display.

### Formula

```
percent      = 1 - (spend / budget)    // scale 2, HALF_EVEN
display%     = (1 - percent) * 100
```

### Why
`spend / budget` gives the consumed fraction. Subtracting from 1 gives the remaining fraction, which drives the fill animation.

---

## 9. Rest Budget Pill — Live Feedback While Typing

**File:** [app/src/main/java/com/danilkinkin/buckwheat/editor/toolbar/restBudgetPill/RestBudgetPillViewModel.kt](app/src/main/java/com/danilkinkin/buckwheat/editor/toolbar/restBudgetPill/RestBudgetPillViewModel.kt)  
**Function:** `calculateValues(context, currentSpent)`

### What it computes
As the user types an amount, the pill shows how much daily budget remains both before and after committing that amount, and whether they're overdrafting.

### Formula

```
restFromDayBudget      = dailyBudget - spentFromDailyBudget - currentSpent

percentWithNewSpent    = max(restFromDayBudget / dailyBudget, 0)    // scale 2
percentWithoutNewSpent = max((restFromDayBudget + currentSpent) / dailyBudget, 0)

isOverdraft  = restFromDayBudget < 0
isBudgetEnd  = whatBudgetForDay(excludeCurrentDay=true, applyTodaySpends=true,
                                notCommittedSpent=currentSpent) <= 0
```

### Why
The pill is the primary real-time affordance. Two percentages drive two visual layers: one shows where you are now, the other shows where you'll land after pressing confirm. State flags (`OVERDRAFT`, `BUDGET_END`, `NORMAL`) change pill color.

---

## 10. Widget Daily Budget Display

**File:** [app/src/main/java/com/danilkinkin/buckwheat/widget/CommonWidgetReceiver.kt](app/src/main/java/com/danilkinkin/buckwheat/widget/CommonWidgetReceiver.kt)  
**Function:** `whatBudgetForDay()` (local, widget-only)

### What it computes
Remaining daily budget for the home screen widget, rounded down to whole currency units.

### Formula

```
restDays    = countDaysToToday(finishDate) - 1
restBudget  = (budget - spent) - dailyBudget
splitBudget = restBudget + dailyBudget - spentFromDailyBudget

result      = floor(splitBudget / max(restDays, 1))   // scale 0, FLOOR
```

Separately, for the progress indicator:

```
percent = (dailyBudget - spentFromDailyBudget) / dailyBudget   // scale 5, HALF_EVEN
        = 0 if dailyBudget == 0
```

### Why
The widget runs outside the main app process without access to the full repository. It reimplements the core formula with `RoundingMode.FLOOR` (instead of HALF_EVEN) so the widget never shows a number the user can't actually reach.

---

## 11. Average Spend

**File:** [app/src/main/java/com/danilkinkin/buckwheat/analytics/AverageSpendCard.kt](app/src/main/java/com/danilkinkin/buckwheat/analytics/AverageSpendCard.kt)

### What it computes
The mean expense value across all spending transactions.

### Formula

```
total   = reduce(spends, acc + spend.value)   // sum via reduce
average = total / count(spends)               // scale 2, HALF_EVEN
```

### Why
Standard arithmetic mean. `reduce` is used instead of a `sum` helper because the list elements are `Transaction` objects — it folds `.value` accumulation in one pass.

---

## 12. Min/Max Spend + Color Position

**File:** [app/src/main/java/com/danilkinkin/buckwheat/analytics/MinMaxSpentCard.kt](app/src/main/java/com/danilkinkin/buckwheat/analytics/MinMaxSpentCard.kt)

### What it computes
The cheapest and most expensive transactions, and where the currently-selected transaction falls between them (for color coding).

### Formula

```
minValue = min(spends.map { it.value })
maxValue = max(spends.map { it.value })

// Normalized position of current spend in [min, max]:
if maxValue == minValue:
    t = 0.0 (min card) or 1.0 (max card)
else:
    t = (currValue - minValue) / (maxValue - minValue)

// t is passed to combineColors() for color interpolation
```

### Why
Normalizing to [0, 1] makes the value independent of currency scale and directly usable as a lerp parameter for the color gradient between "cheap" green and "expensive" red.

---

## 13. Spending Chart Bar Normalization

**File:** [app/src/main/java/com/danilkinkin/buckwheat/analytics/SpendsChart.kt](app/src/main/java/com/danilkinkin/buckwheat/analytics/SpendsChart.kt)

### What it computes
Height of each bar in the spending history chart (0–1 scale), and alpha transparency of each color band.

### Formula

```
minSpent = min(spends.map { it.value })
maxSpent = max(spends.map { it.value })
range    = maxSpent - minSpent

// Per transaction:
if range == 0:
    scale = 0.5
else:
    scale = (value - minSpent) / range   // scale 2, HALF_EVEN → Float

// Alpha per color band (when a transaction is marked/selected):
alpha = 0.3 - |scale - (index / (colors.size - 1))| * 0.25

// Alpha per color band (no selection):
alpha = 0.3 - (index / (colors.size - 1)) * 0.25
```

### Why
Normalizing to [0, 1] makes bars relative to the visible range rather than absolute amounts. The alpha formula creates a gradient highlight that peaks at the band closest to the selected transaction's scale value.

---

## 14. Donut Chart Slice Angles

**File:** [app/src/main/java/com/danilkinkin/buckwheat/analytics/categoriesChart/DonutChart.kt](app/src/main/java/com/danilkinkin/buckwheat/analytics/categoriesChart/DonutChart.kt)

### What it computes
The arc angle (in degrees) for each category slice in the spending donut chart.

### Formula

```
total      = sum(items.map { it.amount })
rawAngle_i = (amount_i / total) * 360    // scale 5, HALF_DOWN → Float

// Minimum angle enforcement:
surplus    = sum(max(0, minAngle - rawAngle_i) for each slice under minAngle)
bigSlices  = slices where rawAngle_i > minAngle

finalAngle_i =
    minAngle                                if rawAngle_i < minAngle
    rawAngle_i - surplus / count(bigSlices) if rawAngle_i > minAngle
    minAngle                                if rawAngle_i == minAngle
```

### Why
Converting amounts to angles is straightforward proportional mapping to 360°. However, tiny slices become invisible. Enforcing a `minAngle` threshold makes small categories visible, and the surplus is redistributed away from larger slices proportionally so the total still sums to 360°.

---

## 15. Category Spending Aggregation

**File:** [app/src/main/java/com/danilkinkin/buckwheat/analytics/categoriesChart/CategoriesChart.kt](app/src/main/java/com/danilkinkin/buckwheat/analytics/categoriesChart/CategoriesChart.kt)

### What it computes
Total spending per tag/category.

### Formula

```
grouped  = spends.groupBy { it.comment.trim() }
totals   = grouped.map { tag, txns -> TagUsage(tag, reduce(txns.map { it.value }, +)) }
sorted   = totals.sortedByDescending { it.amount }
```

### Why
`groupBy` + `reduce` is a standard map-reduce pattern for aggregation. No special math — pure summation after bucketing by category label.

---

## 16. Calendar Daily Aggregation + Heatmap Color

**File:** [app/src/main/java/com/danilkinkin/buckwheat/analytics/SpendsCalendar.kt](app/src/main/java/com/danilkinkin/buckwheat/analytics/SpendsCalendar.kt)

### What it computes
Total spending per calendar day, and a color representing how close spending was to the daily budget.

### Formula

```
// Aggregation (per day):
dailyTotal = sum(transactions on that day)

// Color ratio:
ratio = spending / max(budget, 0.1)     // scale 2, HALF_EVEN
ratio = clamp(ratio, 0, 1)

// ratio is passed to combineColors(colorBad, colorNotGood, colorGood, ratio)
```

### Why
Dividing by `max(budget, 0.1)` prevents division by zero. Clamping to [0, 1] ensures the color lerp stays within the defined gradient. The floor of 0.1 is arbitrary small value — budget is never legitimately zero during an active period.

---

## 17. Day Counting

**File:** [app/src/main/java/com/danilkinkin/buckwheat/util/time.kt](app/src/main/java/com/danilkinkin/buckwheat/util/time.kt)  
**Function:** `countDays(toDate, fromDate)`

### What it computes
The number of calendar days between two dates (inclusive on both ends).

### Formula

```
DAY          = 24 * 60 * 60 * 1000   // milliseconds

fromRounded  = roundToDay(fromDate)
toRounded    = roundToDay(toDate)

daysFrom     = ceil(fromRounded.time / DAY)
daysTo       = ceil(toRounded.time   / DAY)

count        = daysTo - daysFrom + 1
```

### Why
Using `ceil` on milliseconds-since-epoch / DAY converts each date to a day-index in a way that is timezone-agnostic. The `+1` makes the range inclusive (today to today = 1 day). This count drives every budget-per-day division in the app.

---

## 18. Number Display Scaling (K / M / B / T)

**File:** [app/src/main/java/com/danilkinkin/buckwheat/util/numberFormat.kt](app/src/main/java/com/danilkinkin/buckwheat/util/numberFormat.kt)

### What it computes
Abbreviates large currency amounts for compact display.

### Formula

```
THOUSAND = 1000

if value >= THOUSAND^4 * 100:   overflow = true,  displayValue = 100      (shown as "100T+")
elif value >= THOUSAND^4:        displayValue = value / THOUSAND^4          (trillions)
elif value >= THOUSAND^3:        displayValue = value / THOUSAND^3          (billions)
elif value >= THOUSAND^2:        displayValue = value / THOUSAND^2          (millions)
elif value >= THOUSAND * 100:    displayValue = value / THOUSAND            (thousands)
else:                            displayValue = value                        (raw)
```

### Why
Budget amounts in some currencies (JPY, IDR, VND) are commonly in the millions or billions. Showing full digits would overflow the UI. Powers-of-1000 thresholds match standard financial notation (K, M, B, T).

---

## 19. Dynamic Font Sizing

**File:** [app/src/main/java/com/danilkinkin/buckwheat/editor/calcMaxFontSize.kt](app/src/main/java/com/danilkinkin/buckwheat/editor/calcMaxFontSize.kt)  
**Functions:** `calcMaxFont()`, `calcAdaptiveFont()`

### What it computes
The largest font size that fits the budget/amount text within the editor's available space.

### Formula

```
// Step 1 — fit to height:
referenceFontSize = 100.sp
paragraph         = measure text at referenceFontSize
scaledFontSize    = (referenceFontSize.toPx() / paragraph.firstBaseline) * targetHeight
// convert back to sp

// Step 2 — shrink to fit width:
while intrinsicWidth(scaledFontSize) > targetWidth AND scaledFontSize > minFontSize:
    scaledFontSize *= 0.9

// Step 3 — clamp:
finalFontSize = clamp(scaledFontSize, minFontSize, maxFontSize)
```

### Why
Step 1 scales proportionally using the baseline as the reference height (more accurate than em). Step 2 iteratively reduces by 10% because intrinsic width is not linearly proportional to font size for all typefaces — a direct formula would be inaccurate. 10% steps are small enough for good precision without too many iterations.

---

## 20. Color Blending (Linear Interpolation)

**File:** [app/src/main/java/com/danilkinkin/buckwheat/util/colors.kt](app/src/main/java/com/danilkinkin/buckwheat/util/colors.kt)  
**Functions:** `combineColors(colorA, colorB, t)`, `combineColors(colors, t)`

### What it computes
Blends between two colors (or across a gradient of N colors) at position `t` ∈ [0, 1].

### Formula

```
// Two-color lerp:
weightA    = (1 - t) * 2
weightB    = t * 2
R          = (colorA.R * weightA + colorB.R * weightB) / 2
G          = (colorA.G * weightA + colorB.G * weightB) / 2
B          = (colorA.B * weightA + colorB.B * weightB) / 2

// N-color gradient:
index      = (N - 1) * t          // float index into color array
colorA     = colors[floor(index)]
colorB     = colors[ceil(index)]
localT     = index - floor(index)  // fractional part
result     = combineColors(colorA, colorB, localT)
```

### Why
Standard weighted-average color lerp. The `* 2 / 2` factors are mathematically neutral (they cancel out) but make the weight intent readable: each color gets a weight proportional to its share of `t`. The N-color variant maps `t` into the discrete array by floating-point index then interpolates between the two nearest stops.

---

## 21. Material Color Harmonization (HCT Color Space)

**Files:** [app/src/main/java/com/danilkinkin/buckwheat/ui/harmonize/](app/src/main/java/com/danilkinkin/buckwheat/ui/harmonize/)

This subsystem is Google's Material Color Utilities, adapted from the Material Design 3 spec. It converts between sRGB and HCT (Hue-Chroma-Tone) color space for perceptually uniform color operations.

### 21a. Hue Harmonization

**File:** `harmonize/blend/Blend.java`, function `harmonize(designColor, sourceColor)`

```
hueDiff       = differenceDegrees(designHue, sourceHue)
rotation      = min(hueDiff * 0.5, 15.0)   // degrees
direction     = rotationDirection(designHue, sourceHue)
outputHue     = sanitizeDegrees(designHue + rotation * direction)
```

**Why:** Shifts the design color's hue halfway toward the source color (capped at 15°). This makes UI accent colors feel "at home" with the user's wallpaper color without changing the design color significantly.

### 21b. Linear Interpolation & Degree Arithmetic

**File:** `harmonize/utils/MathUtils.java`

```
lerp(start, stop, t)        = (1 - t) * start + t * stop
differenceDegrees(a, b)     = 180 - |  |a - b| - 180  |
sanitizeDegrees(degrees)    = degrees mod 360 (kept positive)
rotationDirection(from, to) = +1 or -1 (shortest arc direction)
```

**Why:** Standard parametric lerp. `differenceDegrees` calculates the shortest angular distance on a circle (wraps around 360°).

### 21c. Matrix Multiply for Color Space Conversion

**File:** `harmonize/utils/MathUtils.java`, function `matrixMultiply(row, matrix)`

```
result[0] = row[0]*M[0][0] + row[1]*M[0][1] + row[2]*M[0][2]
result[1] = row[0]*M[1][0] + row[1]*M[1][1] + row[2]*M[1][2]
result[2] = row[0]*M[2][0] + row[1]*M[2][1] + row[2]*M[2][2]
```

**Why:** sRGB ↔ XYZ ↔ CAM16 conversions all involve linear 3×3 transformations. The specific matrices are the standard IEC 61966-2-1 (sRGB) and Bradford chromatic adaptation matrices.

### 21d. CAM16 Perceptual Color Distance

**File:** `harmonize/hct/Cam16.java`, function `distance(other)`

```
dJ      = Jstar_a - Jstar_b
dA      = Astar_a - Astar_b
dB      = Bstar_b - Bstar_b
dE'     = sqrt(dJ^2 + dA^2 + dB^2)   // Euclidean in J*a*b* space
dE      = 1.41 * dE'^0.63             // perceptual adjustment
```

**Why:** Euclidean distance in J*a*b* space is not perfectly perceptually uniform. The `1.41 * x^0.63` power curve compresses large distances (colors that are already very different don't get scored much higher than moderately different ones), matching human perception better.

### 21e. Tonal Palette Generation

**File:** `harmonize/palettes/CorePalette.java`

```
// Content palette (preserves source chroma):
a1 = TonalPalette(hue,       chroma)          // primary
a2 = TonalPalette(hue,       chroma / 3)      // secondary
a3 = TonalPalette(hue + 60,  chroma / 2)      // tertiary (hue-shifted)
n1 = TonalPalette(hue,       min(chroma/12, 4))  // neutral
n2 = TonalPalette(hue,       min(chroma/6,  8))  // neutral variant

// Standard palette (boosts low-chroma colors):
a1 = TonalPalette(hue,       max(chroma, 48))
a2 = TonalPalette(hue,       16)
a3 = TonalPalette(hue + 60,  24)
n1 = TonalPalette(hue,       4)
n2 = TonalPalette(hue,       8)
```

**Why:** These constants come from the Material Design 3 spec for generating harmonious color roles from a single seed color. The +60° hue shift for the tertiary palette is a classic complementary-ish relationship. Chroma division makes secondary/neutral roles less saturated so they don't compete with the primary.

---

## 22. Wave Animation Amplitude

**File:** [app/src/main/java/com/danilkinkin/buckwheat/editor/toolbar/restBudgetPill/BackgroundProgress.kt](app/src/main/java/com/danilkinkin/buckwheat/editor/toolbar/restBudgetPill/BackgroundProgress.kt)

### What it computes
The height (amplitude) of the wave drawn on the budget pill, and how many wave cycles to draw.

### Formula

```
// percent = percentWithNewSpent (0–1, how much of daily budget remains)

amplitude   = clamp(percent, 0.96, 1.0) * 2.dp.toPx()
              // only non-zero when >= 96% of budget remains

halfPeriod  = 30.dp.toPx() / 2   // = 15dp
cycles      = ceil(pillHeight / halfPeriod + 3)

// Each cycle alternates bezier control point direction:
quadBezierTo(
    dx1 = 2 * amplitude * (if i%2==0 then +1 else -1),
    dy1 = halfPeriod / 2,
    dx2 = 0,
    dy2 = halfPeriod,
)
```

### Why
The wave only has visible amplitude when the budget is nearly full (≥96%). Below that, amplitude = 0 and the fill looks flat. The oscillating `±1` control point direction creates the S-wave pattern via quadratic beziers. Cycle count is sized to overflow the pill height so clipping gives a clean edge.

---

## 23. Inverted Clamp (Progress Bars)

**File:** [app/src/main/java/com/danilkinkin/buckwheat/util/numberExtensions.kt](app/src/main/java/com/danilkinkin/buckwheat/util/numberExtensions.kt)  
**Function:** `Float.clamp(min, max)`

### What it computes
Clamps a float to [min, max] and then inverts it so min→1 and max→0. Used to drive progress bar fill from "full" (1.0) toward "empty" (0.0).

### Formula

```
clamped = coerceIn(value, min, max)
result  = 1 - (clamped - min) / (max - min)
```

### Why
Progress bars in this app represent remaining budget (full = good). The visual goes from full (1.0) to empty (0.0), which is the inverse of a normal 0→1 range. Rather than inverting at the call site every time, the clamp itself bakes in the inversion.

---

## Summary Table

| # | Feature | Location | Core Operation |
|---|---------|----------|---------------|
| 1 | Daily budget allocation | `SpendsRepository.whatBudgetForDay` | `restBudget / restDays` |
| 2 | Remaining balance | `SpendsRepository.howMuchBudgetRest` | `budget - spent - todaySpent` |
| 3 | Skipped-day recovery | `SpendsRepository.howMuchNotSpent` | Conditional skipped-day formula |
| 4 | Next-day projection | `SpendsRepository.nextDayBudget` | Same as #3 without today's remainder |
| 5 | Daily rollover | `SpendsRepository.setDailyBudget` | Accumulate + reset |
| 6 | Past-day expense spread | `SpendsRepository.addSpent/removeSpent` | `value / countDays` per remaining day |
| 7 | Budget % — analytics card | `RestAndSpentBudgetCard` | `rest/whole * 100`, capped at ±1000% |
| 8 | Budget % — spends card | `SpendsBudgetCard` | `1 - spend/budget` |
| 9 | Live editor pill | `RestBudgetPillViewModel` | `(daily - todaySpent - input) / daily` |
| 10 | Widget display | `CommonWidgetReceiver` | Simplified daily budget, `floor` rounding |
| 11 | Average spend | `AverageSpendCard` | `sum / count` |
| 12 | Min/max normalization | `MinMaxSpentCard` | `(x - min) / (max - min)` |
| 13 | Chart bar scaling | `SpendsChart` | `(x - min) / range` + alpha formula |
| 14 | Donut chart angles | `DonutChart` | `amount/total * 360°` + min-angle redistribution |
| 15 | Category totals | `CategoriesChart` | `groupBy` + `reduce(+)` |
| 16 | Calendar heatmap | `SpendsCalendar` | `spending / budget` → color ratio |
| 17 | Day counting | `util/time.kt` | `ceil(ms/DAY)` difference + 1 |
| 18 | Number abbreviation | `util/numberFormat.kt` | Powers of 1000 (K/M/B/T) |
| 19 | Dynamic font size | `calcMaxFontSize.kt` | Proportional scale + 10% shrink loop |
| 20 | Color blending | `util/colors.kt` | Weighted RGB average (lerp) |
| 21 | HCT harmonization | `ui/harmonize/` | Hue shift, matrix ops, CAM16 distance |
| 22 | Wave animation | `BackgroundProgress.kt` | Amplitude from budget %, bezier oscillation |
| 23 | Inverted clamp | `util/numberExtensions.kt` | `1 - (x - min) / (max - min)` |
