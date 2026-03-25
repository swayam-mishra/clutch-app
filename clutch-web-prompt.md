# Clutch Web — Claude Code Prompt

> Paste this entire prompt into a new Claude Code session in your `clutch-web` project directory.

---

You are building a promotional landing website for "clutch" — a Gen Z budgeting
Android app. This is a pure marketing site: no login, no backend, just a
jaw-dropping single-page website that advertises the app's features and links
to the GitHub repo for APK download.

---

## STACK

- Next.js 14 (App Router, `output: 'export'` for static deployment)
- TypeScript
- Tailwind CSS v3 with custom design tokens
- Framer Motion v11 for all animations
- Google Fonts: Space Grotesk (all weights: 300–700)
- Lucide React for icons

Initialize with: `npx create-next-app@latest clutch-web --typescript --tailwind --eslint --app --src-dir --no-turbo`

Then install: `framer-motion lucide-react`

---

## DESIGN SYSTEM

### Colors — exact hex, no approximation

```js
// tailwind.config.ts — extend colors with these tokens
colors: {
  bg:           '#0F1512',  // page background
  surface:      '#1B211E',  // raised sections
  card:         '#252B29',  // cards
  cardHigh:     '#303633',  // elevated cards
  accent:       '#88D6BB',  // primary teal — brand color
  accentDark:   '#00513F',  // accent container
  accentDeep:   '#00382B',  // on-accent text
  accentLight:  '#A3F2D6',  // on-accent container
  secondary:    '#B2CCC1',
  secondaryCon: '#344C43',
  tertiary:     '#A8CBE2',
  tertiaryCon:  '#274B5D',
  textPrimary:  '#DEE4DF',
  textSecondary:'#BFC9C3',
  outline:      '#89938E',
  outlineVar:   '#3F4945',
  error:        '#FFB4AB',
  errorCon:     '#93000A',
  warning:      '#FFB800',
}
```

### Typography
- Font family: `Space Grotesk` everywhere, no exceptions
- All UI copy is **lowercase** (exception: section taglines can be sentence case)
- Weight scale: 300 (light), 400 (regular), 500 (medium), 600 (semibold), 700 (bold)

### Spacing
- 8dp grid: 4, 8, 12, 16, 24, 32, 40, 48, 64px
- Container max-width: 1200px, centered, px-6 on mobile

### Shape tokens (border-radius)
- xs: 4px | sm: 8px | md: 12px | lg: 16px | xl: 28px
- NO pill/stadium shapes anywhere

### Rules
- Dark only. No light mode. No prefers-color-scheme switching.
- Flat — no box shadows, no drop shadows. Depth via surface color layering.
- No gradients on text. Background mesh gradient is allowed (see below).
- No emojis. Use Lucide icons.

---

## PAGE ARCHITECTURE

Build as a single scrolling page with these sections (in order):

1. Navbar
2. Hero
3. Feature Grid ("what clutch does")
4. AI Spotlight ("ask clutch before you buy")
5. Health Score Spotlight ("know your financial health")
6. Analytics Spotlight ("see where your money goes")
7. Goals & Challenges Spotlight ("save for what matters")
8. How It Works (3 steps)
9. Download CTA
10. Footer

---

## SECTION 1: NAVBAR

Fixed top bar. Blurs the content behind it (backdrop-filter blur).

Layout:
```
[clutch wordmark]                    [github  ↗]
```

- "clutch" in Space Grotesk 700, 24px, color `accent` (#88D6BB)
- Right: a single outlined button "github ↗" that links to the GitHub repo
  URL (use placeholder `https://github.com/YOUR_USERNAME/clutch` — tell the
  user to replace it)
- Button: border 1px `outline` color, text `textPrimary`, border-radius 12px,
  no fill, hover fills with `surface`
- Navbar bg: `bg` at 80% opacity + backdrop blur 12px
- Smooth scroll behavior on all anchor links
- On scroll past 50px, add a 0.5px bottom border in `outlineVar`

---

## SECTION 2: HERO

Full viewport height (100dvh). Dark background with a subtle animated mesh.

### Background mesh
Create an SVG-based radial gradient mesh (not CSS gradient, use an absolutely
positioned SVG with radialGradient fills at these positions):
- Top-left: `#00513F` at 25% opacity, radius 600px
- Center-right: `#146B55` at 15% opacity, radius 800px
- Bottom-left: `#0F1512` fills the rest

Add a CSS noise texture overlay (use a base64 SVG feTurbulence filter, ~3%
opacity) to give the background organic texture.

### Content layout (centered, stacked)
```
[status pill: "android • free • open source"]

clutch.

spend smarter.

[subheadline]

[CTA button: "get the apk →"]   [secondary: "view source ↗"]
```

- Status pill: small rounded-full container, bg `surface`, text `textSecondary`
  12px, "android  •  free  •  open source", with a pulsing green dot (8px,
  `accent` color, infinite pulse animation)
- "clutch." — Space Grotesk 800, 96px desktop / 56px mobile, color `accent`.
  The period is part of the wordmark.
- "spend smarter." — Space Grotesk 700, 48px desktop / 32px mobile,
  color `textPrimary`
- Subheadline: "the budgeting app that thinks with you. track expenses, ask ai
  before buying, and hit your goals — all from your phone."
  — Space Grotesk 400, 20px, color `textSecondary`, max-width 560px, centered
- Primary CTA: FilledButton style — bg `accent`, text `accentDeep`,
  border-radius 16px, px-8 py-4, Space Grotesk 600, 18px. Links to GitHub
  releases page. Hover: scale(1.03) with Framer Motion whileHover.
- Secondary: outlined button, same size, "view source ↗" links to GitHub root.

### Entry animations (Framer Motion, staggered, triggered on mount)
Use `variants` with `staggerChildren: 0.12`. Each child:
`{ hidden: { opacity: 0, y: 24 }, visible: { opacity: 1, y: 0 } }`
with `duration: 0.6, ease: [0.16, 1, 0.3, 1]` (expo-out easing).
Order: status pill → "clutch." → "spend smarter." → subheadline → buttons.

### Phone mockup (right side on desktop, below text on mobile)
Position absolutely on the right half of the hero on desktop (lg:block hidden).
Use a generic phone frame (pure CSS/SVG rounded rectangle with notch cutout
effect — no real images). The screen inside shows a dark `bg` color with
three stacked "card" shapes in `card` color to suggest the home screen UI.
Animate this with:
- Framer Motion `y` oscillation: `animate={{ y: [0, -12, 0] }}`
  `transition={{ repeat: Infinity, duration: 4, ease: "easeInOut" }}`
- Subtle rotation: `rotate: [0, 0.5, 0, -0.5, 0]` same transition

---

## SECTION 3: FEATURE GRID

Section title: "what clutch does" (left-aligned, textSecondary, 14px,
uppercase letter-spacing 0.1em)
Main heading: "everything you need,\nnothing you don't." (Space Grotesk 700,
48px, textPrimary, white-space: pre-line)

6 cards in a 3×2 grid (desktop) / 1×6 (mobile). Each card:
- bg: `card` (#252B29)
- border-radius: 12px
- padding: 24px
- NO border, NO shadow
- Icon (Lucide, 28px, `accent` color) in a 48×48 container with bg `accentDark`
  and border-radius 12px
- Feature title: Space Grotesk 600, 18px, `textPrimary`
- Feature desc: Space Grotesk 400, 14px, `textSecondary`, margin-top 8px

The 6 features (use these exact titles and descriptions):

1. Icon: `Brain` | Title: "ai expense categorizer"
   Desc: "type what you spent on. clutch figures out the category instantly —
   food, transport, bills — with confidence scores."

2. Icon: `MessageSquare` | Title: "purchase advisor"
   Desc: "before you buy something, ask clutch. it checks your budget, goals,
   and spending velocity and tells you go for it, think twice, or skip it."

3. Icon: `Activity` | Title: "health score"
   Desc: "a live 0–100 score tracking how well you're managing money across
   adherence, velocity, and goal streaks."

4. Icon: `BarChart3` | Title: "deep analytics"
   Desc: "weekly bar charts, category pie breakdowns, and a daily heatmap
   show exactly where your money went."

5. Icon: `Target` | Title: "goals & challenges"
   Desc: "set rupee targets for anything — a trip, a laptop, an emergency fund.
   join challenges to build spending habits."

6. Icon: `Zap` | Title: "instant entry"
   Desc: "a full-screen numpad means logging an expense takes two seconds.
   no forms, no friction."

### Animation
`useInView` with `once: true`, `margin: "-100px"`. Cards stagger in with
`staggerChildren: 0.08`. Each card:
`{ hidden: { opacity: 0, y: 32, scale: 0.97 }, visible: { opacity: 1, y: 0, scale: 1 } }`
duration 0.5, expo-out.
Hover: `whileHover={{ y: -4, backgroundColor: '#303633' }}` smooth transition.

---

## SECTION 4: AI SPOTLIGHT — "ask clutch before you buy"

Split layout: left = copy + mock verdict card, right = abstract visual.
On mobile: stacked vertically.

### Left side
Label: "ai purchase advisor" (small pill, `accentDark` bg, `accentLight` text)
Heading: "should you buy it?\nclutch knows." (Space Grotesk 700, 44px)
Body: "describe what you want to buy and the price. clutch analyzes your
remaining budget, daily velocity, and savings goals to give you a straight
answer."

Below this, a mock "verdict card" — a `card`-colored rounded-xl card showing:
```
[item row]  new airpods pro        ₹24,999
──────────────────────────────────────────
[verdict]   THINK TWICE            ⚠
[reason]    "this is 67% of your remaining
             budget for today."
[impact row] budget impact: 67%   goal delay: +4d
```
Style the verdict badge: bg `#FFB80020`, text `#FFB800`, weight 700, 12px,
rounded-sm, px-2 py-1.
Verdict row icon: `AlertTriangle` from Lucide in `warning` color.

### Animation on this card (Framer Motion, triggered by inView)
After the card enters the viewport, run a 1.2s sequence:
1. Card fades in + slides up (opacity 0→1, y 20→0)
2. After 400ms: verdict badge "flips" from empty → "THINK TWICE"
   (use AnimatePresence + key change to animate the text in)
3. Impact row counts up: "67%" counts from 0 to 67 over 800ms using a
   custom useCountUp hook
4. Then idle — no looping

### Right side: abstract phone frame
A centered phone frame (same CSS/SVG approach as hero) containing a mock
screen with:
- Input field mockup at top: dark bg pill with "new airpods pro"
- Price field: "₹24,999"
- Orange verdict card taking up 60% of the screen

Animate this phone with a gentle parallax on scroll using Framer Motion's
`useScroll` + `useTransform`.

---

## SECTION 5: HEALTH SCORE SPOTLIGHT — "know your financial health"

Full-width section with `surface` (#1B211E) background.
Layout: centered, with the score ring as a hero element.

Heading: "your money, scored." (Space Grotesk 700, 48px, centered)
Subheading: "clutch watches your adherence, spending pace, and goal streaks
to give you a single number. improve it like a game."
(textSecondary, 18px, max-width 480px, centered)

### Score ring (SVG, animated)
Build a circular SVG progress ring:
- Outer circle: stroke `outlineVar`, stroke-width 12, radius 80, no fill
- Progress arc: stroke `accent`, stroke-width 12, stroke-linecap round,
  stroke-dasharray calculated from radius, stroke-dashoffset animated
- Center: large number "87" (Space Grotesk 700, 48px, `textPrimary`)
  with "/ 100" below it (Space Grotesk 400, 16px, `textSecondary`)
- Label below ring: status badge "doing well" — bg `accentDark`,
  text `accentLight`, rounded-sm, px-3 py-1, weight 600, 12px

### Animation (triggered by inView, once)
The stroke-dashoffset animates from full (empty ring) to the value
representing 87/100, over 1.5s with ease-out. Simultaneously, the number
counts up from 0 to 87 using a custom hook.

### Factor breakdown (3 cards below the ring, in a row)
Each factor card: bg `card`, rounded-xl, p-4, flex-col
- Factor name: `textSecondary` 12px uppercase
- Score: `textPrimary` 700 24px
- Mini linear progress bar: bg `outlineVar`, fill `accent`, h-1, rounded-full,
  animate width from 0 to percentage on inView

Three factors:
1. "adherence" — 91 / 100
2. "velocity" — 78 / 100
3. "streak" — 85 / 100

---

## SECTION 6: ANALYTICS SPOTLIGHT — "see where your money goes"

Dark bg (#0F1512). Heading centered: "every rupee, visualized."
Subheading: "weekly bars, category breakdowns, and a daily heatmap.
you'll actually know where it went."

Build a MOCK analytics card (does not need to use a charting library — pure
CSS/SVG or divs):

### Weekly bar chart (pure CSS flex)
7 bars in a row labeled M T W T F S S.
Heights representing: [45, 70, 30, 85, 60, 95, 40] as percentage of max.
Bar color: `accent` for all except the tallest (95) which is `error` (#FFB4AB).
Labels below in `textSecondary` 11px.
Animation: bars grow from height 0 to their target height over 0.8s,
staggered by 80ms each, triggered by inView.

### Category pie (pure SVG conic-gradient CSS trick — no charting lib)
Build a donut chart using CSS conic-gradient.
6 categories with these colors and approximate percentages:
- Food & Dining: `#88D6BB` (30%)
- Transport: `#A8CBE2` (20%)
- Shopping: `#B2CCC1` (18%)
- Entertainment: `#A3F2D6` (12%)
- Bills: `#344C43` (12%)
- Other: `#3F4945` (8%)

Center: "₹18,420" in `textPrimary` 700, "total" in `textSecondary` 12px.
Legend: small colored dot + category name + percentage, stacked vertically
to the right of the donut.

### Calendar heatmap (pure CSS grid)
31-day grid (7 columns × 5 rows approximately).
Each cell 28×28px, rounded 4px.
Color tiers:
- 0 spending: `#1B211E`
- Low: `#00513F`
- Medium: `#007A5E`
- High: `#88D6BB`

Animate cells fading in with a stagger (12ms per cell) on inView.

All three charts displayed in a single `card`-bg container with tabs or
just stacked with dividers between them.

---

## SECTION 7: GOALS & CHALLENGES SPOTLIGHT

`surface` (#1B211E) background. Split layout.

### Left: copy
- Label pill: "goals & challenges"
- Heading: "save for what matters.\nbeat your habits."
- Body: "set rupee targets for anything — a trip, new gear, an emergency fund.
  join spending challenges to build muscle memory around your budget."

### Right: mock goal card stack (2 cards, slightly offset/stacked)

**Goal card 1 (front, full opacity):**
- bg: `card`, rounded-xl, p-6
- Icon: `Plane` (Lucide), bg `accentDark`, text `accent`
- Title: "euro trip" — Space Grotesk 600 18px
- Progress bar: 62% filled, `accent` color
- Stats row: "₹37,200 of ₹60,000" | "83 days left"
- "on track for aug 2026" in `textSecondary` 12px

**Goal card 2 (behind, slightly visible, scale 0.96, translateY 12px):**
- Same structure but showing "new laptop", 38%, ₹22,800 of ₹60,000

Animation: on inView, card 1 slides up 20px to final position while card 2
stays in place (creates depth illusion).

---

## SECTION 8: HOW IT WORKS

Centered section, `bg` background.
Title: "up and running in 3 steps" (Space Grotesk 700, 44px)

3 steps in a row (mobile: stacked):

**Step 1** — Icon: `Download`, Number: "01"
Title: "download the apk"
Desc: "grab the latest release from github. enable unknown sources, install
in 10 seconds."

**Step 2** — Icon: `Wallet`, Number: "02"
Title: "set your budget"
Desc: "enter your monthly budget. clutch calculates your daily limit
automatically."

**Step 3** — Icon: `TrendingDown`, Number: "03"
Title: "log and learn"
Desc: "add expenses in seconds. watch the ai categorize, analyze, and guide
your spending in real time."

Layout: Each step has a large "01" number in `outlineVar` (Space Grotesk 700,
80px, absolute/behind the icon), icon in `accentDark` container, title and
desc below. Steps connected by a dashed line on desktop
(border-bottom or ::after pseudo, 1px dashed `outlineVar`).

Animate steps in with stagger on scroll.

---

## SECTION 9: DOWNLOAD CTA

Full-width section, centered. bg: radial gradient `#00513F` at 30% opacity
bleeding into `bg`, giving a subtle teal glow.

Large centered text:
"get clutch."
(Space Grotesk 800, 80px desktop / 48px mobile, `textPrimary`)

Subtext: "free. open source. no accounts needed to try."
(`textSecondary`, 18px)

Two buttons:
- Primary: "download apk →" (bg `accent`, text `accentDeep`, rounded-xl,
  px-10 py-5, 20px 700) — links to GitHub releases
- Secondary: "view on github ↗" (outlined, `outline` border, `textPrimary`,
  same sizing) — links to GitHub root

Both buttons: whileHover scale(1.04), whileTap scale(0.98).

---

## SECTION 10: FOOTER

Simple 3-column footer on `surface` bg, 1px top border `outlineVar`.

Left: "clutch." wordmark (same as navbar) + "spend smarter." tagline in
`textSecondary` 14px below it.

Center: small nav links — "features", "health score", "analytics", "goals" —
all scroll to their sections. `textSecondary` 14px, hover `textPrimary`.

Right: GitHub icon button (Lucide `Github`, 20px), links to repo.

Bottom bar: "built with ♥ by [your name] — open source under MIT" in
`textSecondary` 12px, centered. Replace [your name] placeholder note for user.

---

## GLOBAL ANIMATION RULES

1. All scroll-triggered animations use Framer Motion `whileInView` with
   `viewport={{ once: true, margin: "-80px" }}` — they fire once only.
2. Default transition for reveal animations:
   `{ duration: 0.55, ease: [0.16, 1, 0.3, 1] }` (custom expo-out)
3. Stagger: use `variants` with `staggerChildren` on container,
   individual items use `variants` with `hidden/visible` keys.
4. No janky layout shifts — all animated elements have explicit dimensions.
5. Use `will-change: transform, opacity` on animated elements (via Framer
   Motion's style prop or CSS).
6. Respect `prefers-reduced-motion`: wrap all non-essential animations in
   a `useReducedMotion()` check from Framer Motion, and provide a no-animation
   fallback.

---

## MISC REQUIREMENTS

- `next.config.ts`: set `output: 'export'` and `images: { unoptimized: true }`
  for static export compatibility
- Add a `<head>` via `layout.tsx` with:
  - title: "clutch — spend smarter"
  - description: "the gen z budgeting app with ai-powered expense tracking,
    purchase advice, and health scoring."
  - og:image placeholder
  - `<link>` to Google Fonts for Space Grotesk weights 300;400;500;600;700
- All copy is lowercase except "MIT" and acronyms
- No images needed — all visuals are CSS/SVG/Framer Motion
- The GitHub repo URL should be a single constant at the top of a
  `lib/constants.ts` file: `export const GITHUB_URL = 'https://github.com/YOUR_USERNAME/clutch'`
  — with a prominent TODO comment to replace it
- Mobile-first responsive. Breakpoints: sm 640, md 768, lg 1024, xl 1280
- Smooth scroll on `<html>` element

---

## DELIVERABLE

Build the complete site in this structure:

```
src/
  app/
    layout.tsx        ← font, meta, global styles
    page.tsx          ← all sections assembled
    globals.css       ← tailwind directives + custom CSS vars
  components/
    Navbar.tsx
    Hero.tsx
    FeatureGrid.tsx
    AISpotlight.tsx
    HealthScoreSpotlight.tsx
    AnalyticsSpotlight.tsx
    GoalsSpotlight.tsx
    HowItWorks.tsx
    DownloadCTA.tsx
    Footer.tsx
    ui/
      ScoreRing.tsx   ← animated SVG score ring
      BarChart.tsx    ← mock weekly bar chart
      HeatMap.tsx     ← mock calendar heatmap
      DonutChart.tsx  ← mock category donut
  lib/
    constants.ts      ← GITHUB_URL + section IDs
    hooks/
      useCountUp.ts   ← number count-up animation hook
tailwind.config.ts    ← full custom token config
```

Start with `tailwind.config.ts` to establish the design system, then
`globals.css`, then build each component top to bottom (Navbar → Hero → ... →
Footer), assembling in `page.tsx` as you go.
