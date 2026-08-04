# UI_REDESIGN_MASTER_PLAN.md
## Attendify — Complete UI/UX Design Bible
### Codename: Meridian | Version 1.0 | August 2026 | Internal Design Document

---

> **Document Status:** Active  
> **Audience:** Design Team, Flutter Engineers, QA, Product Management  
> **Scope:** Full UI/UX Redesign — Visual Layer Only (Architecture Unchanged)  
> **Last Updated:** August 2026

---

## TABLE OF CONTENTS

1. Overall Product Vision
2. User Personas
3. Target Audience
4. Design Principles
5. Visual Identity
6. Brand Personality
7. Design Language
8. Color Philosophy
9. Complete Color System
10. Dark Theme Strategy
11. AMOLED Theme Strategy
12. Typography System
13. Spacing System
14. Grid System
15. Layout System
16. Corner Radius System
17. Elevation Rules
18. Shadow System
19. Glassmorphism Guidelines
20. Material 3 Usage Guidelines
21. Motion Design Philosophy
22. Animation System
23. Micro-Interaction Guidelines
24. Page Transition System
25. Navigation Philosophy
26. Bottom Navigation Redesign
27. FAB Design
28. Bottom Sheet Design
29. Dialog Design
30. Snackbars
31. Search UX
32. Filter UX
33. Loading States
34. Skeleton Screens
35. Shimmer Guidelines
36. Empty States
37. Error States
38. Success States
39. Confirmation States
40. Accessibility Guidelines
41. Responsive Design
42. Landscape Behaviour
43. Tablet Behaviour
44. Gesture System
45. Haptic Feedback Strategy
46. Sound Feedback Strategy
47. SVG Illustration Guidelines
48. Lottie Animation Guidelines
49. Rive Animation Guidelines
50. 3D Usage Guidelines
51. Iconography
52. Illustration Style
53. Card Design System
54. Button System
55. Input Field System
56. Chip Design
57. Progress Indicators
58. Charts Design
59. Calendar Design
60. Analytics Visualization
61. Planner Design
62. Dashboard Design
63. Subjects Design
64. Schedule Design
65. Attendance Card Design
66. Marked Attendance UX
67. Upcoming Deadlines UX
68. Backup & Restore UI
69. Settings UI
70. Notification UI
71. Timeline UI
72. Academic Planner UI
73. Future AI Assistant UI
74. Onboarding
75. Premium Animations
76. Performance Guidelines
77. Accessibility Checklist
78. Developer Handoff Guidelines
79. Design Tokens
80. Component Library
81. Reusable Widgets
82. Naming Conventions
83. Asset Organization
84. Illustration Library
85. Animation Library
86. Icon Library
87. SVG Asset Rules
88. Image Optimization Rules
89. Performance Budget
90. UX Heuristics
91. Common UX Mistakes To Avoid
92. Visual Consistency Checklist
93. Production Readiness Checklist
94. Future Expansion Strategy
95. Phase-wise Redesign Roadmap

---

# 1. OVERALL PRODUCT VISION

## 1.1 What Attendify Is

Attendify is not an attendance tracker. That framing is too narrow.

Attendify is an **Academic Command Center** — a personal intelligence layer for the student's academic life. It aggregates attendance, deadlines, schedule, and analytics into one coherent experience that reduces cognitive load and creates clarity.

The emotional promise: **"You don't have to think. Attendify has thought for you."**

## 1.2 The Problem We Are Solving

Students suffer from:
- **Fragmentation**: Schedule on paper, attendance on Excel, tasks on WhatsApp, deadlines in memory.
- **Anxiety**: "Am I below 75%?" — answered only by manual calculation.
- **Forgetfulness**: Assignments missed because there was no intelligent reminder.
- **Overwhelm**: Too many subjects, too many deadlines, no overview.
- **Mistrust**: Apps that don't work offline lose student trust immediately.

Attendify eliminates all of these. It is the single source of truth for academic life.

## 1.3 The Promise of the Redesign

The current app is functionally complete. The redesign elevates it from a *functional tool* to a *product students love*. The difference between the two is:

- A functional tool is used when necessary.
- A loved product is opened even when not required, because it feels good.

We aim for the latter. Students should feel proud to use Attendify.

## 1.4 North Star Metric

**Daily Active Usage Rate** — the percentage of students who open Attendify at least once every academic day. The redesign must move this metric.

## 1.5 Product Pillars

| Pillar | Meaning |
|--------|---------|
| **Clarity** | Every screen should reduce cognitive load, not add to it. |
| **Speed** | Every action should feel instant. No loading, no waiting. |
| **Trust** | Offline-first. Data never disappears. |
| **Delight** | Micro-moments of surprise and pleasure throughout. |
| **Focus** | Show only what matters. Hide everything else. |

---

# 2. USER PERSONAS

## Persona 1: Arjun — The Anxious Achiever

**Age:** 20 | **Year:** 2nd Year Engineering  
**Device:** Samsung Galaxy A55 (6.6" 120Hz AMOLED)  
**Usage:** Opens app 4–5 times daily  
**Core Motivation:** Maintain exactly 75% attendance while managing projects  
**Key Pain Point:** Calculating "how many more classes can I bunk?" is stressful  
**What He Needs:** Instant visibility of attendance health. A clear bunk calculator.  
**Design Implication:** Numbers must be prominent, clear, color-coded. Status visible in 0.3 seconds.

## Persona 2: Priya — The Overloaded Overachiever

**Age:** 21 | **Year:** 3rd Year CS  
**Device:** OnePlus 12 (6.82" LTPO AMOLED)  
**Usage:** Morning planning + evening review  
**Core Motivation:** Never miss a deadline. On top of every assignment and viva.  
**Key Pain Point:** Multiple subjects with overlapping deadlines. Prioritization is exhausting.  
**What She Needs:** Smart planner that surfaces the most critical task right now, without asking.  
**Design Implication:** Intelligent prioritization on dashboard. "What do I do next?" answered immediately.

## Persona 3: Ravi — The Casual User

**Age:** 19 | **Year:** 1st Year  
**Device:** Realme Narzo 70 (budget, 6.67" AMOLED 120Hz)  
**Usage:** Once a day after college  
**Core Motivation:** Just wants to know if his attendance is fine.  
**Key Pain Point:** Doesn't understand complex analytics. Cluttered UIs overwhelm him.  
**What He Needs:** Simple answer to "Am I safe?" in 2 seconds.  
**Design Implication:** Dashboard must give one-glance health. Analytics must be simple bar charts.

## Persona 4: Diya — The Perfectionist Planner

**Age:** 22 | **Year:** Final Year Architecture  
**Device:** Google Pixel 9 (6.3", 120Hz OLED)  
**Usage:** Heavy planner user. Creates, edits, reorganizes tasks daily.  
**Core Motivation:** Every submission perfect. Every deadline tracked weeks in advance.  
**Key Pain Point:** Task creation feels clunky. Not fluid enough.  
**What She Needs:** A planner as fast and fluid as Linear or Notion.  
**Design Implication:** Task creation in under 3 taps. Task management gesture-driven.

---

# 3. TARGET AUDIENCE

## 3.1 Primary Target
Indian college students (18–24), engineering and university colleges, using Android devices (₹10,000–₹40,000+). Attendance is mandatory and tracked by institutions.

## 3.2 Secondary Target
Students in other South Asian countries (Bangladesh, Sri Lanka, Nepal, Pakistan) with similar attendance-mandatory academic systems.

## 3.3 Device Considerations
- **Must support:** 6"–6.7" Android phones, 360dp–430dp screen width
- **AMOLED prevalence:** ~70% of target audience. AMOLED theme is a primary feature.
- **RAM:** 3GB–8GB. Must not use excessive memory.
- **Performance:** Smooth 60fps on Snapdragon 680 / Helio G99 class processors.

## 3.4 Competitive Context

| Competitor | What They Do Well | Our Advantage |
|------------|-------------------|---------------|
| Notion | Flexibility, design | Too complex for mobile-first daily use |
| Todoist | Task management | No attendance/academic context |
| Google Calendar | Calendar UX | No academic-specific features |
| TickTick | Feature richness | Cluttered for students |
| Microsoft To Do | Simplicity | No attendance tracking |

Attendify wins by being the only app that merges attendance, schedule, deadlines, and analytics in one offline-first package, designed specifically for the Indian academic context.

---

# 4. DESIGN PRINCIPLES

These principles are in priority order. When two principles conflict, the higher-numbered one wins.

**P1: Clarity Over Cleverness.** Every design decision must serve comprehension. Simple and obvious beats clever and confusing.

**P2: Speed Is a Feature.** Every interaction must provide feedback within 16ms. No action should leave the user waiting without visual acknowledgment.

**P3: Content First.** UI chrome should recede. When the user looks at a screen, they should see *their data*, not our design.

**P4: Intentional Delight.** Animations must have purpose — they communicate state, provide feedback, or reduce perceived wait time. Purely decorative animations are forbidden.

**P5: Progressive Disclosure.** Show only what is needed at the current moment. The dashboard shows summaries. Details appear on demand.

**P6: Graceful Degradation.** The app must look good in every state — loading, empty, error. Design them with the same care as the "happy path."

**P7: Accessibility Is Non-Negotiable.** Meet WCAG 2.1 AA at minimum, targeting AAA. Color is never the only channel of information. Touch targets never smaller than 48×48dp.

**P8: Offline-First Trust.** UI must never show stale or ambiguous data without indicating it. The user must always trust what they see.

---

# 5. VISUAL IDENTITY

## 5.1 Brand Name: Attendify
The suffix "-ify" implies transformation. "Attend + ify" = transforming how you attend. Modern, memorable, appropriate for Play Store.

## 5.2 App Icon Philosophy
**Concept:** A rounded square with a subtle grid pattern (representing schedule) and a single, bold checkmark overlay (representing attendance confirmation). Animated during onboarding.

**Shape:** Squircle (continuous curvature) — consistent with Material You adaptive icons.

**Color:** Primary brand gradient — deep indigo to vibrant violet.

**Avoid:** Graduation caps (cliché), pencils (cliché), books (cliché). The icon should feel like a productivity tool.

## 5.3 Visual Identity Keywords
Precise. Trustworthy. Modern. Academic. Intelligent. Confident. Approachable.

---

# 6. BRAND PERSONALITY

## 6.1 If Attendify Were a Person
Attendify is a brilliant, calm, well-organized senior student who:
- Never panics about deadlines because they track everything.
- Communicates clearly without jargon.
- Is encouraging, not judgmental.
- Knows exactly when to give information and when to stay quiet.

## 6.2 Tone of Voice (Microcopy)
- **Warm but professional.** Not casual, not cold.
- **Encouraging, not alarming.** "You need 3 more classes to reach your goal" > "WARNING: Below threshold."
- **Actionable.** Every message tells the user what to do next, or reassures them they don't need to.
- **Concise.** Never use two words where one works.

## 6.3 Microcopy Examples

| Context | Wrong (Avoided) | Right (Attendify) |
|---------|-----------------|-------------------|
| Empty dashboard | "No data available" | "Your day is clear — classes and tasks will appear here." |
| 74% attendance | "WARNING: Below 75%" | "Just 2 more classes and you're on track." |
| Backup complete | "Success" | "Your data is safe." |
| No tasks | "No tasks found" | "All caught up! Add a deadline when you're ready." |
| Loading | "Loading..." | *(Shimmer, no text)* |

---

# 7. DESIGN LANGUAGE

## 7.1 Name: "Meridian"

We name our design language **Meridian** — referencing the line that brings structure to a globe. Meridian brings structure to academic life.

Meridian is characterized by:
- **Geometric precision** with **organic softness**
- **High-contrast content** on **recessive surfaces**
- **Fluid motion** with **purposeful physics**
- **Information density** balanced with **breathing room**

## 7.2 Core Aesthetic Direction

Meridian sits at the intersection of:
- **Material 3** (expressive, personalized, adaptive)
- **Linear's precision** (clean lines, focused layout, minimal chrome)
- **Notion's hierarchy** (clear typographic structure, content-first)
- **Apple Health's data visualization** (beautiful, readable, accessible)

But it is none of them. It is specifically designed for the academic context of an Indian college student.

## 7.3 Surface Philosophy

Surfaces in Meridian are not backgrounds. They are **containers of meaning**.

- **Background (L0):** The canvas. Pure. Never draws attention.
- **Surface (L1):** Cards, panels. Slightly elevated. Where content lives.
- **Surface Variant (L2):** Inputs, chips. A subtle distinction from L1.
- **Overlay (L3):** Modals, sheets. Clearly above the content layer.

## 7.4 Information Hierarchy

**Level 1 (Immediate):** Status indicators — attendance health, overdue tasks. Visible in under 1 second.  
**Level 2 (Primary):** Subject names, task titles, schedule times. Core content.  
**Level 3 (Secondary):** Counts, percentages, metadata. Supports Level 2.  
**Level 4 (Tertiary):** Labels, captions, timestamps. Available but not demanding.  
**Level 5 (Hidden):** Actions, advanced options. Revealed on interaction.

---

# 8. COLOR PHILOSOPHY

## 8.1 Our Approach: Deep Indigo System

We chose **deep indigo (HSL 248, 75%, 50%)** as our primary color.

**Why indigo?**
- Uncommon in productivity apps (most use blue at 210–230° or teal).
- Reads as *intelligent and academic*.
- Vibrant enough to feel modern, deep enough to feel trustworthy.
- Works beautifully as a surface tint in Material You.

**Why not blue?** Used by Google, Microsoft, Twitter, Facebook, and most productivity apps. We would be invisible.

**Why not green?** Associated with nature and health, not academic intelligence.

**Why not purple?** Standard purple skews gendered in the Indian market. Indigo avoids this while retaining distinctiveness.

## 8.2 Color Roles

**Primary — Indigo:** Action, progress, brand identity  
**Secondary — Amber:** Warnings, due-soon tasks, important callouts  
**Tertiary — Rose/Coral:** Critical state, overdue, danger  
**Neutral — Slate:** Surfaces, text, dividers  
**Success — Emerald:** Present, complete, safe  

---

# 9. COMPLETE COLOR SYSTEM

## 9.1 Light Theme Tokens

```
─── PRIMARY ─────────────────────────────────────────────────────────────
primary:               #4B39EF    (HSL 247° 82% 58%)
onPrimary:             #FFFFFF
primaryContainer:      #E0DEFF    (HSL 247° 100% 94%)
onPrimaryContainer:    #13008E

─── SECONDARY (Warning/Due Soon) ────────────────────────────────────────
secondary:             #F59E0B    (HSL 38° 91% 50%)
onSecondary:           #FFFFFF
secondaryContainer:    #FEF3C7
onSecondaryContainer:  #78350F

─── TERTIARY (Error/Critical) ───────────────────────────────────────────
tertiary:              #EF4444    (HSL 0° 84% 60%)
onTertiary:            #FFFFFF
tertiaryContainer:     #FEE2E2
onTertiaryContainer:   #7F1D1D

─── SUCCESS ─────────────────────────────────────────────────────────────
success:               #10B981    (HSL 161° 83% 40%)
onSuccess:             #FFFFFF
successContainer:      #D1FAE5
onSuccessContainer:    #064E3B

─── SURFACES ─────────────────────────────────────────────────────────────
background:            #FAFAFA
surface:               #FFFFFF
surfaceVariant:        #F1F0FF    (primary-tinted)
surfaceContainerLowest:#FFFFFF
surfaceContainerLow:   #F8F7FF
surfaceContainer:      #F1F0FF
surfaceContainerHigh:  #E8E7FF
surfaceContainerHighest:#DDD9FF

─── TEXT ────────────────────────────────────────────────────────────────
onBackground:          #1A1A2E    (deep navy, not pure black)
onSurface:             #1A1A2E
onSurfaceVariant:      #5C5A7A
outline:               #C4C2E0
outlineVariant:        #E8E7F5

─── SEMANTIC ─────────────────────────────────────────────────────────────
attendancePresent:     #10B981    (emerald)
attendanceAbsent:      #EF4444    (red)
attendanceMedical:     #F59E0B    (amber)
attendanceHoliday:     #6366F1    (indigo variant)
attendancePending:     #94A3B8    (slate)
attendanceGt:          #8B5CF6    (violet)

taskCritical:          #EF4444
taskHigh:              #F97316    (orange)
taskMedium:            #3B82F6    (blue)
taskLow:               #10B981    (emerald)

statusSafe:            #10B981    (≥ 85%)
statusWarning:         #F59E0B    (75–85%)
statusDanger:          #EF4444    (< 75%)
```

## 9.2 Color Usage Rules

**Rule 1:** Primary color is for actions and brand, never for decoration.

**Rule 2:** Surface tinting is subtle — 4–8% opacity.

**Rule 3:** Semantic colors must be consistent throughout the entire app.

**Rule 4:** Never use pure black (#000000) in light theme. Use `#1A1A2E`.

**Rule 5:** Color is never the only signal — always pair with icon, text, or shape.

---

# 10. DARK THEME STRATEGY

## 10.1 Philosophy

Dark theme is not "light theme with colors inverted." It is a completely different surface hierarchy. The goal: a premium evening mode — layered and dimensional.

## 10.2 Dark Theme Tokens

```
background:            #0F0E17    (HSL 247° 24% 8%)
surface:               #1A1828    (HSL 246° 22% 13%)
surfaceContainerLowest:#0C0B14
surfaceContainerLow:   #161524
surfaceContainer:      #1E1C2D
surfaceContainerHigh:  #262438
surfaceContainerHighest:#2E2C42

onBackground:          #E8E6FF    (slightly warm white)
onSurface:             #E8E6FF
onSurfaceVariant:      #A9A6CC

primary:               #8B83FF    (lighter for dark backgrounds)
onPrimary:             #220077
primaryContainer:      #3300A8
onPrimaryContainer:    #E0DEFF

attendancePresent:     #34D399    (lighter emerald)
attendanceAbsent:      #F87171    (lighter red)
attendanceMedical:     #FCD34D    (lighter amber)
```

## 10.3 Dark Theme Elevation

In dark theme, elevation is communicated by **surface lightness, not shadows**.

```
Elevation 0: #0F0E17  (background)
Elevation 1: #1A1828  (surface)
Elevation 2: #252333  (card)
Elevation 3: #2E2C42  (modal)
Elevation 4: #373551  (tooltip)
```

---

# 11. AMOLED THEME STRATEGY

## 11.1 Why AMOLED Matters

~70% of the target audience uses AMOLED screens. Pure black pixels are turned off on AMOLED, saving battery and improving visual depth. Attendify offers a true AMOLED mode as a first-class feature.

## 11.2 AMOLED Token Differences

```
background:            #000000    (pure black — pixels OFF)
surface:               #0A0A10
surfaceContainerLowest:#000000
surfaceContainerLow:   #080811
surfaceContainer:      #0E0E1E
surfaceContainerHigh:  #151526
surfaceContainerHighest:#1C1C30
```

## 11.3 AMOLED Design Rules

1. Never use grey lighter than `#2A2A3E` for large surface areas.
2. Dividers: `#FFFFFF0A` (white at 4% opacity), not opaque grey lines.
3. Text: `#F0EEFF` (bright, slightly warm) for maximum contrast.
4. Colored elements (chips, badges) "pop" dramatically — use intentionally as jewels on black canvas.
5. Cards may have a subtle border (1px, white at 8% opacity) to define boundaries.
6. No glassmorphism in AMOLED mode (blur on black = wasted GPU).

---

# 12. TYPOGRAPHY SYSTEM

## 12.1 Typeface Selection

**Primary: Plus Jakarta Sans**

Reasons: Geometric humanist sans-serif — intelligent, modern, approachable. Available on Google Fonts. Excellent legibility at small sizes (crucial for attendance stats). Wide weight range (300–800). Slightly condensed letterforms work well for data-dense UIs. Distinctive without being novelty.

**Alternatives Considered:**
- *Inter:* Excellent but overused. Lacks distinctiveness.
- *DM Sans:* Good, but slightly less readable at very small sizes.
- *Nunito:* Too rounded, feels too casual for academic app.
- *Outfit:* Very good secondary option, slightly less legible at 12sp.

**Secondary (Data only): JetBrains Mono**

For numbers, percentages, and statistics ONLY. Monospaced fonts make numbers align perfectly in lists and prevent visual jumping when values update.

## 12.2 Type Scale

```
─── DISPLAY ─────────────────────────────────────────────────────────────
displayLarge:     57sp  Regular    LS: -0.25   — Hero numbers only
displaySmall:     36sp  Regular    LS: 0        — Large stat values

─── HEADLINE ────────────────────────────────────────────────────────────
headlineLarge:    32sp  SemiBold   LS: 0        — Page titles (rare)
headlineMedium:   28sp  SemiBold   LS: 0        — Section headers
headlineSmall:    24sp  SemiBold   LS: 0        — Card headlines

─── TITLE ───────────────────────────────────────────────────────────────
titleLarge:       22sp  SemiBold   LS: 0        — AppBar titles
titleMedium:      16sp  SemiBold   LS: 0.15     — Card titles, item titles
titleSmall:       14sp  Medium     LS: 0.1      — Subsection labels

─── BODY ────────────────────────────────────────────────────────────────
bodyLarge:        16sp  Regular    LS: 0.5      — Primary body text
bodyMedium:       14sp  Regular    LS: 0.25     — Secondary body text
bodySmall:        12sp  Regular    LS: 0.4      — Captions, metadata

─── LABEL ───────────────────────────────────────────────────────────────
labelLarge:       14sp  Medium     LS: 0.1      — Buttons, tabs
labelMedium:      12sp  Medium     LS: 0.5      — Chips, badges
labelSmall:       11sp  Medium     LS: 0.5      — Micro-labels, overlines

─── DATA (JetBrains Mono) ───────────────────────────────────────────────
dataLarge:        28sp  Regular    — Large attendance percentage
dataMedium:       18sp  Regular    — Analytics stats
dataSmall:        14sp  Regular    — Inline numbers
```

*(LS = Letter Spacing)*

---

# 13. SPACING SYSTEM

## 13.1 Base Unit: 4dp

All spacing uses multiples of 4dp.

```
space1:    4dp    — Minimal separation
space2:    8dp    — Tight grouping (within a card)
space3:    12dp   — Standard internal padding
space4:    16dp   — Standard component padding (most common)
space5:    20dp   — Medium section spacing
space6:    24dp   — Comfortable section spacing
space8:    32dp   — Large section separation
space10:   40dp   — Extra large (hero sections)
space12:   48dp   — Maximum standard spacing
space16:   64dp   — Layout-level spacing
```

## 13.2 Semantic Spacing

```
screenHorizontal:   16dp    — Default screen edge margin
cardPadding:        16dp    — All four sides
sectionSpacing:     24dp    — Between sections
cardSpacing:        12dp    — Between cards in a list
iconGap:            8dp     — Between icon and label
chipGap:            8dp     — Between chips
listItemPadding:    12dp 16dp (vertical horizontal)
dialogPadding:      24dp
bottomSheetPadding: 24dp
```

---

# 14. GRID SYSTEM

## 14.1 Column Grid

**Phone (360–430dp):** 4 columns, 16dp gutter, 16dp margin  
**Large Phone (430–520dp):** 6 columns, 16dp gutter, 20dp margin  
**Tablet (600dp+):** 12 columns, 24dp gutter, 24dp margin *(future)*

## 14.2 Baseline Grid

All text elements align to a **4dp baseline grid**. All padding/spacing values are designed to maintain this baseline.

---

# 15. LAYOUT SYSTEM

## 15.1 Page Structure

```
┌─────────────────────────────────────────┐
│  StatusBar (system)                     │
├─────────────────────────────────────────┤
│  TopAppBar or LargeAppBar   (56–112dp)  │
├─────────────────────────────────────────┤
│  Content Area (Scrollable)              │
│  padding: 16dp horizontal               │
│                                         │
│  Section Header ──────────────────────  │
│  [Cards / Lists / Content]              │
│                                         │
│  Section Header ──────────────────────  │
│  [Cards / Lists / Content]              │
│                                         │
│  80dp bottom padding                    │
└─────────────────────────────────────────┘
│  NavigationBar (80dp)                   │
└─────────────────────────────────────────┘
```

## 15.2 AppBar Behavior

**Primary destinations:** `LargeTopAppBar` that collapses to `TopAppBar` on scroll. Large title creates breathing room and communicates "you are at the top level."

**Secondary screens:** Standard `TopAppBar` with back button.

## 15.3 Content Patterns

| Pattern | Used In |
|---------|---------|
| Full-width list | Planner, Settings |
| Card grid (2-col) | Subjects |
| Summary + Detail | Dashboard |
| Chart + List | Analytics |
| Calendar + Detail | Calendar |
| Timeline | Subject history |

---

# 16. CORNER RADIUS SYSTEM

## 16.1 Philosophy

Corner radius communicates the "importance" and "interactivity" of an element. Attendify uses continuous curvature (squircle-like) via `BorderRadius.circular()`.

## 16.2 Radius Tokens

```
radiusXS:   4dp    — Chips (internal), progress bars, small badges
radiusSM:   8dp    — Input fields, small cards, tooltips
radiusMD:   12dp   — Standard cards, dialogs
radiusLG:   16dp   — Large cards, bottom sheets (top corners)
radiusXL:   20dp   — Feature cards, prominent containers
radius2XL:  24dp   — Modal sheets, prominent cards
radiusFull: 9999dp — Pills (FAB label, buttons, avatar chips)
```

## 16.3 Radius Usage Reference

| Component | Radius |
|-----------|--------|
| Button (filled/tonal) | radiusFull |
| Input field | radiusMD |
| Card (standard) | radiusMD |
| Card (hero/feature) | radiusLG |
| Subject card | radiusLG |
| Bottom sheet | radiusXL (top corners only) |
| Dialog | radiusLG |
| Chip | radiusFull |
| Badge | radiusFull |
| Progress bar | radiusFull |
| Snackbar | radiusMD |

---

# 17. ELEVATION RULES

## 17.1 Elevation Model

Material 3 uses **surface tones** rather than shadows for elevation. Attendify follows this for cards and inline elements; overlay components (modals, sheets) use both surface toning AND subtle shadows.

## 17.2 Elevation Levels

```
Level 0: Background  — No tint, no shadow. Pure canvas.
Level 1: Card        — +5% primary tint (light), slightly lighter surface (dark)
Level 2: Raised card — +8% primary tint
Level 3: FAB         — +11% primary tint + subtle shadow
Level 4: Sheet/Dialog— +12% primary tint + medium shadow
Level 5: Tooltip     — Full overlay styling
```

---

# 18. SHADOW SYSTEM

## 18.1 Shadow Philosophy

Shadows communicate only **spatial separation** — functional, not decorative.

**Rule:** If an element is not floating above the content layer, it should not have a shadow. Cards in scroll views are NOT floating — use surface toning.

## 18.2 Shadow Specifications

```
Level 3 (FAB):
  0 2dp 8dp rgba(0,0,0,0.12), 0 1dp 3dp rgba(0,0,0,0.08)

Level 4 (Sheet/Dialog):
  0 8dp 32dp rgba(0,0,0,0.16), 0 2dp 8dp rgba(0,0,0,0.08)

Level 5 (Tooltip):
  0 4dp 12dp rgba(0,0,0,0.12)
```

Dark theme: Reduce all shadow opacities by 50%.

**Critical:** No shadows on `ListView` items — painting shadows during scroll causes frame drops.

---

# 19. GLASSMORPHISM GUIDELINES

## 19.1 Decision: Glassmorphism Is NOT a Default Pattern

Heavy performance cost on mid-range Android. Reduces legibility when background content is busy. Not suitable for data-dense UIs.

## 19.2 Approved Use Cases (Only 3)

1. **Floating date headers** in calendar — maximum 1 per screen.
2. **Onboarding illustrations** — static glass cards only.
3. **Achievement overlays** — future feature only.

## 19.3 Implementation Spec (When Used)

```
Blur:       12dp — NOT more. Higher values lag on target devices.
Fill:       rgba(primaryContainer, 0.6) light / rgba(surface, 0.5) dark
Border:     1dp, rgba(white, 0.15)
Corner:     radiusLG (16dp)
```

## 19.4 Absolute Prohibitions

❌ Never on scrollable list items  
❌ Never with blur radius above 20dp on Android  
❌ Never as substitute for proper surface hierarchy  
❌ Never in AMOLED mode

---

# 20. MATERIAL 3 USAGE GUIDELINES

## 20.1 What We Take From M3

- Dynamic Color seeding (`seedColor` for tonal palette)
- Surface toning for elevation
- Shape system (customized radii)
- Typography scale (Plus Jakarta Sans applied)
- State layers (Hover 8%, Press 12%, Dragged 16%, Focus 12%)
- Adaptive layouts (NavigationBar → NavigationRail for tablet)

## 20.2 What We Override

- Color palette (custom semantic token layer)
- Motion (Meridian motion system replaces M3 defaults)
- Component styling (visual customization)

## 20.3 M3 Components Used

```
NavigationBar, TopAppBar, LargeTopAppBar, FloatingActionButton,
Card, FilledButton, FilledTonalButton, TextButton, OutlinedButton,
InputDecorationTheme, ListTile, SegmentedButton, FilterChip,
InputChip, Snackbar, Dialog, ModalBottomSheet, Switch, Slider,
LinearProgressIndicator, CircularProgressIndicator, Badge, Divider
```

---

# 21. MOTION DESIGN PHILOSOPHY

## 21.1 The Purpose of Motion

Motion serves four functions:
1. **Orientation** — Tells the user where they are going.
2. **Feedback** — Confirms an action was received.
3. **Causality** — Shows relationships between elements.
4. **Continuity** — Maintains spatial model across transitions.

Motion never serves a fifth function: **entertainment**.

## 21.2 The 3-Speed Rule

```
Instant:    0–100ms    — Hover states, ripples, switch toggles
Quick:      150–250ms  — Icon changes, color transitions, badge updates
Standard:   250–350ms  — Screen transitions, card expansions, modal appearances
Deliberate: 350–500ms  — Hero transitions, shared element animations
```

**Never use durations above 500ms for interaction-triggered animations.**

## 21.3 Easing Curves

```
emphasized:           Cubic(0.2, 0.0, 0.0, 1.0)   — Primary transitions
emphasizedDecelerate: Cubic(0.05, 0.7, 0.1, 1.0)  — Entering elements
emphasizedAccelerate: Cubic(0.3, 0.0, 0.8, 0.15)  — Exiting elements
standard:             Cubic(0.2, 0.0, 0.0, 1.0)   — Default transitions
standardDecelerate:   Cubic(0.0, 0.0, 0.2, 1.0)   — Entering
standardAccelerate:   Cubic(0.3, 0.0, 1.0, 1.0)   — Exiting
linear:               Linear                        — Progress bars only
```

---

# 22. ANIMATION SYSTEM

## 22.1 Enter Animations

```
FADE IN:
  Duration: 200ms | Curve: emphasizedDecelerate
  Opacity: 0→1 | Transform: translateY(+8dp → 0)

SCALE IN (Cards, Dialogs):
  Duration: 250ms | Curve: emphasizedDecelerate
  Scale: 0.92→1.0 | Opacity: 0→1

SLIDE IN FROM BOTTOM (Sheets):
  Duration: 350ms | Curve: emphasizedDecelerate
  Transform: translateY(+100% → 0)

SLIDE IN FROM RIGHT (Forward nav):
  Duration: 300ms | Curve: emphasizedDecelerate
  Transform: translateX(+100% → 0)
  Previous: translateX(0 → -30%), opacity 1→0
```

## 22.2 Exit Animations

```
FADE OUT:       150ms, emphasizedAccelerate, opacity 1→0, translateY(0 → -8dp)
SCALE OUT:      200ms, emphasizedAccelerate, scale 1.0→0.92, opacity 1→0
SLIDE OUT DOWN: 300ms, emphasizedAccelerate, translateY(0 → +100%)
```

## 22.3 Shared Element (Hero) Transitions

**Subject Card → Subject Detail:**
```
Hero tag:    'subject_card_${subject.id}'
Duration:    350ms | Curve: emphasized
Start shape: RoundedRect(16dp)
End shape:   Rectangle (bleeds to screen edges)
```

**Task Card → Task Edit Form:**
```
Hero tag:    'task_${task.id}'
Duration:    300ms
Type:        Container Transform (Material 3 shared axis)
```

## 22.4 Stagger Animation (Lists)

```
Stagger delay:    40ms per item (max 8 items, rest instant)
Duration per item: 200ms
Animation:        fadeIn + translateY(+16dp → 0)
Max total:        ~520ms
```

## 22.5 State Change Animations

**Attendance toggle:**
```
Icon morph: radio_button_unchecked → check_circle
Duration:   200ms | Scale: 1.0→1.15 (spring) →1.0
Color:      grey → semantic color
Spring:     damping 0.4, mass 1.0, stiffness 200
```

**Task completion:**
```
Checkmark draws in: 200ms
Strikethrough draws: 0%→100% width, 150ms
Card opacity: 1.0→0.6
```

**Attendance counter update:**
```
Duration: 400ms | Curve: emphasized
Interpolate: old value → new value (integer tween)
Glow effect if crossing threshold (75%)
```

## 22.6 Spring Physics

```
Standard Spring:  damping 0.75, mass 1.0, stiffness 200
Bouncy Spring:    damping 0.50, mass 1.0, stiffness 300
Critical Damping: damping 1.00, mass 1.0, stiffness 150
```

---

# 23. MICRO-INTERACTION GUIDELINES

## 23.1 Long Press

1. Haptic feedback (heavy impact, 50ms into long press)
2. Scale down to 0.97 (communicates "held")
3. Elevation increase (shadow appears)
4. Action sheet appears

## 23.2 Swipe-to-Action

**Right swipe on attendance card:** Mark Present (green)  
**Left swipe on attendance card:** Show quick status picker  

```
Threshold:    40% of card width
Confirm:      Icon bounces (spring: damping 0.5), card updates
Reveal:       Background color slides from edge with action icon
```

## 23.3 Pull to Refresh

```
Indicator:    Custom circular, primary color
String travel: 60dp before triggering
Rotation:     0°→180° during pull
Success:      Checkmark draws in (150ms), then fades
```

## 23.4 Number Counter Animation

All changing statistics use animated counters:
```
Duration:       400ms | Curve: ease-out
Interpolation:  old → new (integer tween)
Odometer style: each digit can animate independently for ±1 changes
```

---

# 24. PAGE TRANSITION SYSTEM

## 24.1 Transition Types

| Transition | When Used | Animation |
|------------|-----------|-----------|
| Forward | Pushing deeper | Slide from right |
| Backward | Going back | Reverse slide |
| Tab switch | Bottom nav | Fade Through (M3) |
| Modal | Full-screen modal | Slide up from bottom |
| Replace | Login → Main | Fade Through |

## 24.2 Tab Switch (Fade Through) Spec

```
Phase 1 (exit):  Outgoing: opacity 1→0, scale 1→0.96, 120ms
Phase 2 (enter): Incoming: opacity 0→1, scale 0.96→1, 180ms
Total:           300ms (phases overlap at ~60ms)
Curve:           emphasized
```

## 24.3 Predictive Back Gesture

Supports Android 13+ predictive back. Screen follows finger with resistance. Destination screen appears in "gap" at scale 0.85. Spring to final position on completion.

---

# 25. NAVIGATION PHILOSOPHY

## 25.1 The Navigation Problem

Attendify has 8+ destinations. 8 items in a bottom nav = poor UX (cramped, inaccessible). Material 3 recommends 3–5 for NavigationBar.

## 25.2 Solution: Tiered Navigation (5-Tab + More)

**Bottom NavigationBar (5 items):**
1. **Dashboard** — Home/overview
2. **Subjects** — Subject management + quick attendance
3. **Schedule** — Weekly timetable
4. **Planner** — Academic tasks and deadlines
5. **More** — Calendar, Analytics, Settings, Backup

**"More" opens a ModalBottomSheet** with a beautiful grid of destination tiles.

**Alternatives rejected:**
- Navigation Drawer — Hides navigation, increasing discovery friction.
- 7-tab bottom bar — Icons at 24dp with no labels are inaccessible.

**Decision Justification:** 5-tab pattern is proven (Instagram, Spotify, YouTube). "More" is a recognized pattern (iOS App Store, TikTok) that students understand immediately.

---

# 26. BOTTOM NAVIGATION REDESIGN

## 26.1 Visual Specifications

```
Height:             80dp
Background:         surface + 8% primary tint (elevated surface)
Top border:         1dp, outlineVariant (very subtle)
Icon size:          24dp
Label size:         12sp, labelSmall
Active indicator:   Pill shape, 64×32dp, primaryContainer
Active icon:        primary color, filled variant
Inactive icon:      onSurfaceVariant, outlined variant
```

## 26.2 Active State Animation

- Icon changes to filled variant
- Label appears in primary color
- Pill indicator expands behind icon (spring, 250ms)
- Haptic: light impact on selection

## 26.3 Badge System

```
Size:     18dp minimum (4dp padding around count)
Color:    tertiary (red)
Position: Top-right of icon, offset (-2dp, -2dp)
Max:      "9+" for counts above 9
Planner badge: count of overdue tasks
```

## 26.4 "More" Destination

```
Transition:  Slide up modal, 350ms
Content:     2-column grid of destination tiles
Items:       Calendar, Analytics, Settings, Backup & Restore
Style:       Large tappable tiles, surfaceContainerHigh
Padding:     24dp all around, 16dp gap
Dismiss:     Swipe down / tap outside / back gesture
```

---

# 27. FAB DESIGN

## 27.1 Per-Screen FAB Reference

| Screen | FAB | Action |
|--------|-----|--------|
| Dashboard | None | — |
| Subjects | add | Add Subject |
| Schedule | edit_calendar | Add Schedule Slot |
| Planner | add_task (Extended) | Add Task |
| Calendar | None | — |

## 27.2 Extended FAB Specifications

```
Background:  primaryContainer | Foreground: onPrimaryContainer
Icon:        24dp leading | Label: labelLarge, Medium weight
Corner:      radiusFull | Elevation: Level 3
Position:    Bottom-right, 16dp from edge, 16dp above NavigationBar

Behavior:    Collapses to icon-only on scroll down
             Re-expands on scroll up
Animation:   Label fades/shrinks, width animates (250ms, emphasized)
```

---

# 28. BOTTOM SHEET DESIGN

## 28.1 Modal Sheet Specifications

```
Background:     surfaceContainerHigh
Corner radius:  radiusXL (24dp) top corners, 0dp bottom
Drag handle:    4dp × 32dp, outlineVariant, 12dp from top
Padding:        24dp
Max height:     75% of screen (scrollable beyond)
Scrim opacity:  0.40 (black)
Dismiss:        Drag below 25%, or tap scrim

Animation enter: Slide up, 350ms, emphasizedDecelerate
Animation exit:  Slide down, 300ms, emphasizedAccelerate
```

## 28.2 Sheet Header Pattern

```
┌────────────────────────────────────────┐
│     ────   ← drag handle (centered)   │
│                                        │
│  Title                        [Close] │
│  Subtitle (optional)                   │
│ ─────────────────────────────────────  │
│  Content...                            │
```

---

# 29. DIALOG DESIGN

## 29.1 When to Use

**Dialog:** Binary decisions (delete, permission, single question).  
**Sheet:** Multi-step actions, form inputs, lists of options.

## 29.2 Specifications

```
Max width:     280dp
Background:    surfaceContainerHigh
Corner:        radiusLG (16dp)
Icon:          48dp, centered, primaryContainer background (optional)
Title:         headlineSmall, centered or left
Body:          bodyMedium, onSurfaceVariant
Actions:       FilledButton (confirm) + TextButton (cancel), right-aligned
Scrim:         30% black
Animation:     Scale 0.87→1.0 + fade, 250ms, emphasizedDecelerate
```

## 29.3 Destructive Dialogs

- Icon: `delete_forever`, tertiaryContainer background
- Confirm: `FilledButton` with `tertiary` (red) color scheme
- Copy: "This cannot be undone."

---

# 30. SNACKBARS

```
Background:    onSurface (near-black light / near-white dark)
Text:          surface color
Action:        secondary color, TextButton
Height:        48dp minimum
Corner:        radiusMD (12dp)
Position:      Bottom, 16dp above NavigationBar
Duration:      4000ms informational / 8000ms actionable

Types:
  Info:    info_outline icon, neutral
  Success: check_circle icon, successContainer tint
  Warning: warning_amber icon, secondaryContainer tint
  Error:   error_outline icon, tertiaryContainer tint
  Action:  + TextButton (Undo, View)
```

---

# 31. SEARCH UX

## 31.1 Pattern

Contextual per-screen search. No global search in MVP.

**Entry:** Tapping search icon expands a search field in-place in AppBar.  
**Transition:** SearchBar slides down, pushing content. 200ms.  
**Results:** Appear in-place with stagger. Matching text highlighted (primaryContainer background).  
**No Results:** Empty state with search-context message.

---

# 32. FILTER UX

## 32.1 Pattern

Horizontally scrollable `FilterChip` row directly below AppBar. Persistent, not hidden.

**Rationale:** Students filter by task type repeatedly. The chip row allows instant toggle without an extra tap.

```
Row height:   52dp (with padding)
Style:        FilterChip, filled when selected
Padding:      16dp left
Scroll:       Horizontal, no snap
Chip gap:     8dp
Animate:      Select: 150ms fill + checkmark | Deselect: 120ms reverse
```

---

# 33. LOADING STATES

```
0–150ms:   Nothing — let content appear (instant feel)
150–500ms: Skeleton screen
500ms–2s:  Skeleton + subtle progress indicator in AppBar
2s+:       Full loading state with contextual message
```

---

# 34. SKELETON SCREENS

```
Color (light): surfaceContainerHigh → surfaceContainerHighest (shimmer sweep)
Color (dark):  surfaceContainer → surfaceContainerHigh
Shape:         Exactly matches content shape (same radius, same height)

Dashboard skeleton:  3 stat rectangles + attendance card + 3 deadline items
Subjects skeleton:   2×2 card grid
Planner skeleton:    5 task list items (circle + 2 text lines each)
```

---

# 35. SHIMMER GUIDELINES

```
Gradient direction:  Left-to-right
Gradient width:      30% of element width
Light colors:        [surfaceContainerHigh, surfaceContainerHighest, surfaceContainerHigh]
Dark colors:         [surfaceContainer, surfaceContainerHigh, surfaceContainer]
Speed:               1500ms per sweep
Sync:                All skeletons on a screen share one shimmer clock
Stop:                Immediately when content loads → replace with fade-in (150ms)
```

---

# 36. EMPTY STATES

Every empty state includes:
1. **Illustration** (SVG, brand-consistent)
2. **Heading** (warm, direct)
3. **Subheading** (explains why, suggests action)
4. **(Optional) CTA Button**

| Screen | Heading | Subheading | CTA |
|--------|---------|------------|-----|
| Dashboard | "Ready to start?" | "Add your subjects to begin tracking." | "Add Subject" |
| Subjects | "No subjects yet." | "Add your first subject to start tracking." | "Add Subject" |
| Planner | "All caught up!" | "No pending tasks. Add one when ready." | "Add Task" |
| Calendar | "Nothing on this day." | "Long-press a date to mark attendance manually." | — |
| Analytics | "Nothing to analyse yet." | "Start marking attendance to see insights." | — |

---

# 37. ERROR STATES

```
Error Card:
  Background:  tertiaryContainer
  Icon:        error_outline, tertiary color
  Title:       Specific error message
  Body:        What happened + what user can do
  Action:      "Try Again" or specific resolution
```

**Inline error:** One section fails, others fine — show error card within that section.  
**Full-page error:** Entire screen fails — centered error state with retry.

---

# 38. SUCCESS STATES

```
Snackbar (most cases):
  Text:     "Saved." / "Marked present." / "Task complete." / "Backup created."
  Icon:     check_circle (successContainer tint)
  Duration: 2000ms (brief — success shouldn't linger)

Inline (form fields):
  Border:   transitions to success color
  Icon:     checkmark trails in (scale 0.8→1.0, 150ms)

Celebration (achievements only):
  Lottie:   confetti animation (3s, auto-dismiss)
  Haptic:   double-light success pattern
```

---

# 39. CONFIRMATION STATES

**Confirmation dialogs:** Required ONLY for irreversible/high-impact actions (delete, restore backup).

**For reversible actions:** Use **Undo snackbar** instead. Optimistic UI + escape hatch.

**Optimistic UI Pattern:**
1. Immediately update UI.
2. Show "Undo" snackbar for 4 seconds.
3. Commit to database in parallel.
4. If undo tapped: revert database + revert UI.

This makes the app feel instant.

---

# 40. ACCESSIBILITY GUIDELINES

## 40.1 Color & Contrast

- Body text: 4.5:1 minimum contrast (WCAG AA), target 7:1 (AAA)
- Large text (18sp+): 3:1 minimum
- Status colors always have secondary non-color indicator

## 40.2 Touch Targets

- All interactive elements ≥ 48×48dp
- Swipe-to-action has long-press menu fallback
- No touch targets overlap (minimum 8dp gap)

## 40.3 Screen Reader (TalkBack)

```
Requirements:
  - Semantic.label for all non-text interactives
  - Semantic.button for button-like elements
  - Semantic.liveRegion for dynamic content (attendance %)
  - Group card semantics (title + subtitle + action as one unit)
  - Decorative images: empty semanticsLabel
```

## 40.4 Reduce Motion

Respect `MediaQuery.of(context).disableAnimations`:
- All animations → instant (effectively 0ms)
- Transitions → simple crossfade
- No spring physics
- No shimmer → replace with static placeholder

---

# 41. RESPONSIVE DESIGN

## 41.1 Breakpoints

```
Compact:   < 400dp    — Small phones
Default:   400–480dp  — Standard phones (primary target)
Medium:    480–600dp  — Large phones
Expanded:  > 600dp    — Tablets (future)
```

## 41.2 Adaptive Behaviors

**Subject Grid:** 2 columns (Compact/Default) → 3 columns (Medium) → 4 columns (Expanded)  
**Analytics Charts:** Full width (Compact) → Side-by-side (Medium+)  
**Navigation:** NavigationBar (phone) → NavigationRail (tablet)

---

# 42. LANDSCAPE BEHAVIOUR

- **NavigationBar:** Collapses to 56dp height. Labels hidden.
- **Content:** Switches to 2-column layout where appropriate.
- **Keyboard:** Content scrolls up when keyboard appears. Nothing hidden.
- **Calendar:** Uses extra horizontal space — wider week view.

---

# 43. TABLET BEHAVIOUR

*(Future Phase — Architected now, implemented later)*

```
NavigationRail (left, 72dp) replaces NavigationBar
Planner + Calendar: Side-by-side master-detail
Subjects: 3-column grid
Dashboard: 2-column with larger stats cards
```

---

# 44. GESTURE SYSTEM

| Gesture | Action | Screen |
|---------|--------|--------|
| Tap | Primary action | All |
| Long press | Context menu | Cards, list items |
| Swipe right | Mark Present | Attendance items |
| Swipe left | Show status picker | Attendance items |
| Pull down | Refresh | All lists |
| Edge swipe left | Back navigation | All |
| Long press → drag | Reorder | Schedule (future) |

## 44.1 Gesture Conflict Resolution

- Horizontal vs Vertical: Detect first direction within 10dp. Commit to that axis.
- Swipe threshold: 8dp horizontal triggers swipe mode (disables vertical scroll on that item).
- Cancel zone: Diagonal beyond 30° cancels swipe action.

---

# 45. HAPTIC FEEDBACK STRATEGY

## 45.1 Haptic Events

```
Light impact:    Tab switch, chip selection, switch toggle
Medium impact:   Card selection, list item selection
Heavy impact:    Long press activation, drag start

Success pattern: double-light (80ms apart)
Warning:         single medium
Error:           single heavy

Selection:       Slider drag, segmented button, date picker
```

## 45.2 Implementation

```dart
HapticFeedback.lightImpact();    // tab switch, chip
HapticFeedback.mediumImpact();   // card select
HapticFeedback.heavyImpact();    // long press, error

// Success pattern
HapticFeedback.lightImpact();
await Future.delayed(const Duration(milliseconds: 80));
HapticFeedback.lightImpact();
```

## 45.3 Haptic Setting

Add user-facing **"Haptic Feedback"** toggle in Settings > Appearance. Respect `MediaQuery.disableAnimations` as soft hint.

---

# 46. SOUND FEEDBACK STRATEGY

**Decision: No UI sounds by default.**

Students use phones in silent/class mode. UI sounds in productivity apps are generally unwelcome. System sounds are sufficient.

**Future optional sounds** (opt-in in Settings):
- Gentle "tick" when marking attendance
- Success chime on task completion

---

# 47. SVG ILLUSTRATION GUIDELINES

## 47.1 When to Use SVG

✓ Empty state illustrations  
✓ Onboarding screens  
✓ Feature introduction cards

✗ NOT icons (Material Symbols)  
✗ NOT backgrounds (use color fills)  
✗ NOT data visualizations

## 47.2 Style Specifications

```
Style:       2D flat geometric (not isometric, not 3D)
Colors:      Meridian palette tokens only
Max colors:  4 (primary, secondary, neutral, white)
Stroke:      1.5–2dp, onSurface at 30% opacity
Size:        200×200dp maximum in context
Complexity:  Maximum 30 paths (<5KB file size)
ViewBox:     200×200 consistent
Characters:  Abstract, geometric, gender-neutral, culturally neutral
```

---

# 48. LOTTIE ANIMATION GUIDELINES

## 48.1 Approved Uses

1. Success celebrations (task complete, backup success) — max 2 seconds
2. Brand loader (first launch only)
3. Onboarding transitions (future)

## 48.2 Rules

```
Max file size:     50KB per animation
Max frame rate:    30fps
Max duration:      2s (feedback), 4s (onboarding)
Hardware accel:    Required. Use RepaintBoundary.
Colors:            Must use Meridian palette. Customize externally if needed.
```

---

# 49. RIVE ANIMATION GUIDELINES

## 49.1 Rive vs Lottie

**Use Rive for interactive, state-machine animations:**
- FAB icon morph (add → close → check)
- Bottom nav icon animations on select
- Attendance status icon morph (absent → present)

**Use Lottie for one-shot celebrations:**
- Task complete confetti
- Non-interactive sequences

## 49.2 Rules

```
Max file size:     30KB per animation
FPS:               60fps (GPU-rendered, acceptable)
State machines:    Use Rive state machines for multi-state
Artboard size:     Match actual rendered size exactly
```

---

# 50. 3D USAGE GUIDELINES

## 50.1 Default Stance: No 3D

3D on mobile causes: High GPU usage, visual inconsistency with flat design, long asset loading, maintenance difficulty.

## 50.2 WHERE 3D MAY BE USED (Approved)

1. **App Icon** — Static PNG render only. Subtle depth via adaptive icon foreground layer.
2. **Onboarding hero** (future) — Pre-rendered PNG asset only. Never real-time.
3. **Achievement badges** (future) — Only if GPU benchmarks on Snapdragon 680 show < 5% additional frame drop.

## 50.3 WHERE 3D IS ABSOLUTELY FORBIDDEN

❌ Card surfaces or backgrounds (use flat surface + tonal elevation)  
❌ Navigation elements (destroys accessibility and performance)  
❌ Charts and data visualizations (3D charts mislead data perception)  
❌ Scrollable content of any kind (catastrophic for scroll performance)  
❌ Real-time 3D without explicit benchmarking on target hardware  

---

# 51. ICONOGRAPHY

## 51.1 Icon System: Material Symbols (Outlined default)

```
Default weight:   400 | Active/selected: 700 or Filled variant
Icon sizes:       24dp (standard), 20dp (compact), 28dp (hero)
Optical sizing:   Match opticalSize param to rendered size
```

## 51.2 Icon Colors

```
Primary action icons:   primary
Navigation active:      primary
Navigation inactive:    onSurfaceVariant
Status icons:           semantic color
Informational:          onSurfaceVariant
Destructive:            tertiary (red)
```

## 51.3 Semantic Icon Mapping

```
Dashboard:         home / home_filled
Subjects:          menu_book
Schedule:          view_week
Planner:           checklist / task_alt
Calendar:          calendar_month
Analytics:         bar_chart / analytics
Settings:          tune
Backup:            backup / cloud_upload

Present:           check_circle / check_circle_outline
Absent:            cancel / cancel_outlined
Medical:           healing
Holiday:           beach_access
GT/Duty:           military_tech
Pending:           radio_button_unchecked

Task Critical:     priority_high
Task High:         keyboard_double_arrow_up
Task Medium:       drag_handle
Task Low:          keyboard_arrow_down

Add:               add | Edit: edit | Delete: delete_outline
More: more_vert | Close: close | Back: arrow_back
Search: search | Filter: filter_list
```

---

# 52. ILLUSTRATION STYLE

## 52.1 Style: Geometric Minimalist

Flat geometric, 2D. Orthographic perspective. Abstract characters (circle heads, simple bodies). Maximum 15% detail in any illustration. Maximum 4 colors from Meridian palette. Consistent 2dp stroke throughout.

## 52.2 Illustration Catalog (MVP)

| Context | Description |
|---------|-------------|
| Dashboard empty | Calendar with sunrise glow |
| Subjects empty | Grid of empty squares waiting to be filled |
| Planner complete | Large checkmark with celebratory shapes |
| Analytics not ready | Bar chart outline with question marks |
| Backup success | Shield with checkmark |
| Error | Broken link / warning triangle |
| Onboarding 1 | Student figure with calendar and books |
| Onboarding 2 | Timetable with clock |
| Onboarding 3 | Pie chart and statistics |

---

# 53. CARD DESIGN SYSTEM

## 53.1 Card Hierarchy

**Level 1 — Hero Card:**
```
Min height: 100dp | Background: primaryContainer / surfaceContainerHigh
Corner: radiusLG (16dp) | Padding: 20dp | Shadow: None
```

**Level 2 — Content Card (Standard):**
```
Min height: 64dp | Background: surfaceContainerLow
Corner: radiusMD (12dp) | Padding: 16dp | Margin: 12dp vertical
```

**Level 3 — Compact / Chip Card:**
```
Height: 40–56dp | Background: surfaceContainerHighest
Corner: radiusSM (8dp) | Padding: 8dp 12dp
```

## 53.2 Card States

```
Default:   Normal surface color
Pressed:   +12% primary tint (ripple)
Selected:  primaryContainer bg + 1dp primary border
Disabled:  50% opacity, no interaction
Loading:   Shimmer overlay
```

---

# 54. BUTTON SYSTEM

## 54.1 Hierarchy

```
FILLED (Primary):
  Background: primary | Text: onPrimary | Height: 48dp
  Corner: radiusFull | Padding: 24dp horizontal
  Font: labelLarge, SemiBold
  Use: "Save", "Add Subject", "Create Backup"

FILLED TONAL (Secondary):
  Background: secondaryContainer | Text: onSecondaryContainer
  Height: 48dp | Corner: radiusFull
  Use: "Import", "View All"

OUTLINED (Low-emphasis):
  Background: transparent | Border: 1dp outline | Text: primary
  Height: 48dp | Corner: radiusFull
  Use: "Cancel" adjacent to Filled button

TEXT (Ghost):
  No background, no border | Text: primary | Height: 48dp minimum
  Use: "Dismiss", "Skip", third-level actions

ICON BUTTON:
  Touch target: 48×48dp | Icon: 24dp
  Background: transparent (standard) or surfaceContainerHighest (tonal)
  Use: AppBar actions, card secondary actions
```

## 54.2 Button States

```
Pressed:   +12% primary tint + scale 0.97
Focused:   3dp focus ring, primary
Disabled:  onSurface at 38%, surface bg at 12%
Loading:   Replace label with CircularProgressIndicator (16dp, onPrimary)
```

---

# 55. INPUT FIELD SYSTEM

## 55.1 Style: Filled (Primary)

```
Background:   surfaceContainerHighest
Corner:       radiusMD top, 0dp bottom (Material Filled style)
Height:       56dp standard / 48dp compact
Label:        bodySmall when active, bodyLarge when empty (floating)
Border bottom: 1dp outline inactive / 2dp primary focused
```

## 55.2 States

```
Inactive:  Bottom border outlineVariant
Focused:   Label floats up, 2dp primary border, label color primary
Filled:    Label stays up, 1dp outline border
Error:     Tertiary (red) border, error text below in bodySmall
Disabled:  38% opacity
```

## 55.3 Validation

- Fires on **focus loss**, not on every keystroke.
- Error messages below field in `bodySmall`, `tertiary` color.
- Never show errors before user has interacted with the field.

---

# 56. CHIP DESIGN

```
FILTER CHIP:
  Unselected: surfaceVariant bg, 1dp border, 32dp height
  Selected:   secondaryContainer bg, checkmark, no border
  Corner: radiusFull | Font: labelMedium, Medium

INPUT CHIP:
  Background: surfaceContainerLow | Border: 1dp
  Trailing: close icon (16dp) for removal

ASSIST CHIP:
  Background: transparent | Border: 1dp | Optional leading icon

Animation: Select 150ms fill + checkmark scale | Deselect 120ms reverse
```

---

# 57. PROGRESS INDICATORS

```
LINEAR BAR (Attendance):
  Height: 8dp | Corner: radiusFull
  Track: surfaceContainerHighest
  Fill: < 75% tertiary (red) | 75–85% secondary (amber) | ≥ 85% success (green)
  Animation: Width animates on change (500ms, emphasized)

CIRCULAR (Loading):
  Size: 48dp standard / 24dp inline | Stroke: 4dp | Color: primary

STEP INDICATOR (Onboarding):
  Active: 8dp, primary | Inactive: 8dp, outlineVariant | Complete: 8dp, success + check
```

---

# 58. CHARTS DESIGN

## 58.1 Philosophy

Charts must be: immediately readable (insight visible in 2 seconds), accessible (never color-only), and appropriate (simplest chart for the data).

## 58.2 Chart Types

```
Subject Attendance: Horizontal bar chart (sorted: lowest % at top)
                    Bars colored by health (green/amber/red)
                    Values at end of each bar

Weekly Trend:       Smooth bezier line chart
                    Filled area under curve (15% primary opacity)
                    Grid lines: 10% opacity

Distribution:       Donut chart
                    Inner label: total classes
                    Segments: Present/Absent/Medical/Holiday
                    Tap segment → show count in center

Month-over-Month:   Simple vertical bars (current vs previous)
                    No 3D effects
```

## 58.3 Chart Styling

```
Grid lines:    onSurface at 8% opacity, 1dp
Axis labels:   bodySmall, onSurfaceVariant
Value labels:  labelMedium, onSurface
Tooltip:       surfaceContainerHighest card, bodyMedium, shadow
```

## 58.4 Chart Animations

```
Bar charts:  Bars grow from 0%, 600ms, emphasizedDecelerate
Line charts: Line draws left-to-right, 600ms
Donut:       Segments arc from 0°, staggered 40ms each
Updates:     400ms tween between old and new values
```

---

# 59. CALENDAR DESIGN

## 59.1 Calendar Component

`table_calendar` package, heavily themed to Meridian.

## 59.2 Header

```
Month/Year:  titleLarge, SemiBold, left-aligned
Nav arrows:  IconButton, chevron_left / chevron_right
Weekday row: labelSmall, onSurfaceVariant, 3-letter abbreviations
```

## 59.3 Day Cell

```
Size:          ~40×48dp
Selected:      Filled circle, primary bg, onPrimary text
Today:         Ring outline (primary), primary text
Other month:   onSurfaceVariant at 40% opacity

Event dots:    Max 3 dots, 6dp diameter, centered below date
               Layout: Wrap (not Row — prevents overflow!)
               Attendance: semantic color | Task: primary (tertiary if overdue)
```

## 59.4 Calendar Modes

```
Month View (default): Full month grid
2-Week View (compact): 2 rows. Activated by swipe up on calendar.
Week View: 7 days.

Mode switch: Animated height change, 350ms
```

## 59.5 Day Detail Panel

Scrollable panel below calendar showing selected day's classes and tasks. Separated by `Divider`. Uses list card pattern.

---

# 60. ANALYTICS VISUALIZATION

## 60.1 Screen Layout

```
AppBar: "Analytics" + period filter chips
↓
3-column summary stat cards (Total / Present / Absent)
↓
Horizontal bar chart (subject-wise attendance)
↓
Line chart (weekly trend)
↓
Donut chart (distribution breakdown)
```

## 60.2 Stat Cards

```
Width:       (screenWidth - 48dp) / 3
Height:      80dp
Background:  surfaceContainerLow
Top label:   labelSmall, onSurfaceVariant
Number:      dataMedium, JetBrains Mono, semantic color
Corner:      radiusMD
```

---

# 61. PLANNER DESIGN

## 61.1 Screen Layout

```
LargeAppBar: "Planner" / "N tasks pending"
↓
Filter Chips: [All][Today][This Week][Overdue][Assignment][Quiz][Lab][Viva]
↓
OVERDUE section (red header) → task cards with red left border
↓
TODAY section (amber header) → task cards with amber left border
↓
UPCOMING section → task cards
↓
FAB: Add Task (Extended FAB)
```

## 61.2 Task Card (Redesigned)

```
Height:       72dp minimum
Background:   surfaceContainerLow
Corner:       radiusMD (12dp)
Margin:       8dp vertical, 16dp horizontal

Left border:  4dp, priority color
              critical=red | high=orange | medium=blue | low=green

Layout:
│ [4dp border] │ [Title + Subject + Due badge] │ [Checkbox] │

Title:        titleMedium, SemiBold
Subject:      bodySmall, onSurfaceVariant
Due badge:    Chip style, semantic color (labelMedium)
Checkbox:     Custom animated (§23, §75)
```

---

# 62. DASHBOARD DESIGN

## 62.1 Full Layout

```
LargeAppBar: Greeting + Date
↓
[Hero] Attendance Health Card (circular progress + overall %)
↓
[Section] Today's Schedule
  Next class card (prominent, high-emphasis)
  + compressed list of remaining classes
↓
[Section] Upcoming Deadlines
  Priority-sorted, max 5, "View all →" if more
↓
[Section] Quick Stats (Classes Today / This Week / Month)
```

## 62.2 Greeting Logic

```
5am–12pm:  "Good morning, [name]"
12–5pm:    "Good afternoon, [name]"
5–9pm:     "Good evening, [name]"
9pm+:      "Hey, [name]"
```

## 62.3 Hero Attendance Health Card

```
Height:       160dp
Background:   Gradient primaryContainer → surfaceContainerHigh
Corner:       radiusLG (16dp)
Padding:      20dp

Left side:    80dp circular progress donut
              Overall % in center (dataMedium, JetBrains Mono)
Right side:   "Overall Attendance" label
              Large % (headlineLarge)
              Status pill: "Safe Zone ✓" / "At Risk ⚠" / "Below Target ✗"
              6 subject health mini-dots
```

## 62.4 Next Class Card

```
Background:   primary (filled, high emphasis)
Text:         onPrimary
Shows:        Subject, start time, room, faculty
Countdown:    "Starts in 45 minutes" (live update)
Status badge: "Not marked" / "Present ✓" / "Absent ✗"
Tap action:   Mark attendance (if within 15 min of class start)
```

---

# 63. SUBJECTS DESIGN

## 63.1 Screen Layout

```
AppBar: "Subjects" + Search icon
↓
Summary banner: "N subjects · Overall: 81.2%"
↓
2-column subject card grid
↓
FAB: Add Subject
```

## 63.2 Subject Card

```
Width:    (screenWidth - 48dp) / 2
Height:   160dp (fixed)
Corner:   radiusLG (16dp)
BG:       surfaceContainerLow
Top:      16dp color stripe (subject's assigned color, rounded top corners)

Content:
  Subject name: titleMedium, SemiBold, max 2 lines
  Faculty name: bodySmall, onSurfaceVariant
  Percentage:   dataMedium, JetBrains Mono
  Progress bar: 8dp, colored by health (red/amber/green)
  Status chip:  "Safe" / "At Risk" / "Below"
```

## 63.3 Subject Colors (8-Color Cycle)

```
#6366F1 Indigo    #8B5CF6 Violet
#EC4899 Pink      #F59E0B Amber
#10B981 Emerald   #3B82F6 Blue
#14B8A6 Teal      #F97316 Orange
```

User can change color in subject settings.

## 63.4 Subject Detail Screen

```
Header:          Full-width color banner, subject name overlaid
Stats row:       Present / Absent / Total (3 stat cards)
Percentage:      Large circular progress + dataMedium
Bunk Calculator: "You can miss N more classes" OR "You need N more classes"
History list:    All attendance records, date-sorted, grouped by month (timeline §71)
```

---

# 64. SCHEDULE DESIGN

## 64.1 Screen Layout

```
AppBar: "Schedule"
↓
Day Selector: [M][T][W][T][F][S] horizontal pills
              Current day highlighted | Today has dot indicator
↓
Timeline-style list for selected day
↓
FAB: Add Class
```

## 64.2 Day Selector

```
Background:    surfaceContainerLow (full row)
Day chip:      40×40dp, radiusFull
Active:        primaryContainer bg, primary text
Today:         Dot below chip
```

## 64.3 Schedule Item

```
Layout:     Left time column (56dp) + content card
Time:       labelSmall, onSurfaceVariant, top-aligned
Card:       surfaceContainerLow, radiusMD
            Subject: titleMedium, SemiBold
            Faculty + Room: bodySmall with icons
            Status badge: attendance for selected day
            Tap: expand → full details + attendance action
```

---

# 65. ATTENDANCE CARD DESIGN

## 65.1 Card Anatomy

```
Height:        72dp collapsed / 120dp expanded
Background:    surfaceContainerLow
Corner:        radiusMD (12dp)
Left accent:   4dp bar, semantic color

Left accent colors:
  Present:   #10B981 (emerald)
  Absent:    #EF4444 (red)
  Medical:   #F59E0B (amber)
  Holiday:   #6366F1 (indigo)
  GT/Duty:   #8B5CF6 (violet)
  Pending:   outlineVariant
```

## 65.2 Card Content

```
Row layout:
  [Left accent] | [Subject + Time/Room] | [Status badge]

Subject area:
  Title:    titleMedium, SemiBold
  Subtitle: bodySmall, onSurfaceVariant (time or faculty)

Status badge:
  Background: semantic color at 15% opacity
  Text:       labelMedium, SemiBold, semantic color
  Corner:     radiusFull
```

---

# 66. MARKED ATTENDANCE UX

## 66.1 Marking Flow

1. **Tap card** → expands to show status options.
2. **Tap status** → immediate UI update (optimistic).
3. **Haptic** → light impact + success pattern.
4. **Snackbar** → "Marked [status]. Undo" (4 seconds).
5. **Card updates** → accent + badge animate with semantic color.

## 66.2 Quick Marking (Swipe)

Right swipe → Mark Present instantly  
Left swipe → Quick status picker slides in from right  

## 66.3 Bulk Marking

Long press on calendar date → "Mark all as..." → Single status selection → Apply to all classes that day.

---

# 67. UPCOMING DEADLINES UX

## 67.1 Priority Display Order

```
1. OVERDUE   — Red header, red left border, most recently overdue first
2. TODAY     — Amber header, amber left border, sorted by task priority
3. TOMORROW  — Blue header, sorted by task priority
4. THIS WEEK — Neutral header, sorted by date then priority

Max 5 cards total | "and N more · View all →" if exceeded
```

## 67.2 Deadline Card (Dashboard Compact)

```
Height:       64dp
Left border:  3dp, priority color
Background:   surfaceContainerLow
Layout:       [Type icon 18dp] [Title + Subject] [Due badge]

Title:        bodyMedium, SemiBold, max 1 line (ellipsis)
Subject:      bodySmall, onSurfaceVariant, max 1 line
Due badge:    labelSmall, semantic color
```

---

# 68. BACKUP & RESTORE UI

## 68.1 Screen Layout

```
AppBar: "Storage & Backup"
↓
[Data Safety Status card]
  Shield icon + "Your data is safe."
  Last backup: date/time
  Green indicator
↓
ListTile: "Create Backup" — backup icon + "Save to .atfy file"
↓
ListTile: "Restore from file" — restore icon + "Import .atfy backup"
↓
ListTile: "Cloud Backup" — disabled + "Coming Soon" chip
↓
[Backup History section] — if tracking available
```

## 68.2 Progress State

```
Replaces content with:
  [Branded circular progress]
  Percentage: dataMedium, JetBrains Mono
  "Creating backup..." / "Restoring data..."
  [Cancel: TextButton]
```

## 68.3 Restore Preview Dialog

```
Title:   "Restore This Backup?"
Icon:    restore, secondaryContainer
Details: Date, App Version, Platform
Warning: Red text — "Current data will be replaced. Rollback backup auto-created."
Actions: [Cancel] [Restore] (Restore uses tertiary/red color)
```

---

# 69. SETTINGS UI

## 69.1 Settings Architecture

```
Appearance:        Theme (Light/Dark/System/AMOLED), Haptic Feedback
Academic Profile:  Semester Start/End Date
Attendance Rules:  Goal %, Medical Policy, GT Policy
Notifications:     Master switch, Lecture offset, Daily reminder, Task reminders
Storage & Backup:  Link to backup screen
Advanced:          Import Timetable (collapsed), Clear Today's Attendance (red)
About:             App version, Feedback (future), Privacy Policy (future)
```

## 69.2 Visual Style

```
Section header:   labelLarge, primary color, 16dp top padding
Dividers:         outlineVariant, full-width
ListTile:         M3 ListTile, 56–72dp height
Leading icon:     24dp, onSurfaceVariant
Trailing:         Control widget (Switch/Dropdown/Chevron)
Destructive:      Red text + red icon, visually separated
```

---

# 70. NOTIFICATION UI

## 70.1 Notification Types

```
Lecture Reminder (15 min before):
  Title:   "[Subject] class in 15 minutes"
  Body:    "[Time] · [Room] · [Faculty]"
  Action:  "Open App"
  Priority: High

Task Deadline (24h before due):
  Title:   "[Task] due tomorrow"
  Body:    "[Subject] · [Type]"
  Actions: "Mark Complete" + "Open App"
  Priority: High

Overdue Alert:
  Title:   "You have N overdue tasks"
  Body:    "[First task] and N-1 more"
  Priority: Max (heads-up)

Daily Reminder:
  Title:   "Attendance Check-in"
  Body:    "You have N classes today."
  Priority: Default
  Schedule: User-defined time
```

## 70.2 Channels

```
Channel 1: Lecture Reminders (HIGH importance)
Channel 2: Task Deadlines (HIGH importance)
Channel 3: Daily Digest (DEFAULT importance)
Channel 4: System/Backup (DEFAULT importance)
```

---

# 71. TIMELINE UI

## 71.1 Component

```
Layout:
  Left column (40dp): Time connector (vertical line + date dots)
  Right column:       Content cards

Date group:
  Label:   labelMedium, onSurfaceVariant (e.g., "August 2026")
  Dot:     8dp filled circle, outlineVariant

Event:
  Dot:     12dp filled circle, semantic color
  Card:    surfaceContainerLow, radiusMD
  Line:    2dp vertical, outlineVariant, connecting dots
```

---

# 72. ACADEMIC PLANNER UI

## 72.1 Task Form (Bottom Sheet)

```
Sheet height:   85% of screen
Header:         "New Task" / "Edit Task" + close button
Content:        Scrollable form

Fields:
  1. Title (required)        — TextField
  2. Type (required)         — SegmentedButton row (Assignment/Quiz/Viva/Lab/Homework)
  3. Subject (required)      — DropdownButton
  4. Due Date (required)     — DatePicker → "Due Aug 12"
  5. Priority                — FilterChip row
  6. Notes (optional)        — Multi-line TextField, 4 lines
  7. Reminders               — Switch + chip row for offsets

Actions:        [Cancel TextButton] [Save Task FilledButton]
```

---

# 73. FUTURE AI ASSISTANT UI

## 73.1 Vision

Natural language interface for querying academic data:
- "What's my attendance in Physics?"
- "Can I skip tomorrow's class?"
- "When is my next assignment due?"

## 73.2 UI Concept

**Entry:** AI button in AppBar (future phase — not in bottom nav).

**Interface:** Slide-up sheet. Not a full-screen chatbot — a quick-query overlay.

**Responses:** Primarily structured cards with data, not raw text.

**Visual:** User messages right-aligned, assistant left-aligned. Attendify icon as assistant identifier (not a robot).

---

# 74. ONBOARDING

## 74.1 Flow (3+2 Screens)

```
Screen 1: Welcome
  "Your Academic Life, Organized."
  "Track attendance, manage deadlines, never miss a class."
  CTA: "Get Started →"

Screen 2: Feature Highlights (3 cards, horizontal scroll)
  Attendance tracking / Smart planner / Insights
  CTA: "Next →"

Screen 3: Goal Setup
  "Set up your attendance goal"
  Slider: 60–90%, default 75%
  CTA: "Continue →"

Screen 4: Add First Subject
  Minimal inline form (name + type)
  CTA: "Add Subject" + "Skip for now"

Screen 5: Done
  Lottie success animation (2s)
  "You're all set, [name]!"
  "Dashboard →"
```

## 74.2 Onboarding Transitions

Each screen: Shared Axis Horizontal (M3). Illustration: scale + fade in (300ms). Headline stagger-fades after illustration.

---

# 75. PREMIUM ANIMATIONS

## 75.1 Attendance % Counter Update

1. Number counts up/down (odometer interpolation, 400ms).
2. Circular progress bar animates to new value (500ms, spring).
3. Glow effect if crossing 75% threshold.
4. Haptic: success pattern if crossing from below to above threshold.

## 75.2 Subject Card Load

```
Stagger: 40ms per card | Duration: 200ms
Animation: Scale 0.93→1.0 + fade-in
Progress bars fill after cards appear (200ms delay + 400ms fill)
```

## 75.3 Task Completion

1. Checkbox: draws checkmark (200ms).
2. Title: strikethrough draws left-to-right (150ms).
3. Card: desaturates (opacity 1.0→0.6, 200ms).
4. If last task: "All caught up!" empty state scale + fade in.

## 75.4 Backup Success

1. Progress fills to 100%.
2. Morphs into checkmark (Rive, 400ms).
3. Shield animation (security metaphor).
4. Snackbar: "Your data is safe."
5. Haptic: double-light success.

---

# 76. PERFORMANCE GUIDELINES

**Rule 1:** No `Opacity` widget in `AnimatedBuilder` on large trees. Use `AnimatedOpacity`.

**Rule 2:** Use `const` constructors everywhere possible.

**Rule 3:** All list items wrapped in `RepaintBoundary`.

**Rule 4:** All PNG assets compressed. SVG for illustrations. No unnecessary image loading in lists.

**Rule 5:** Shimmer uses a single `AnimationController` shared across all skeleton items.

**Rule 6:** Charts use `CustomPainter` — not widget trees.

**Rule 7:** `table_calendar` wrapped in `RepaintBoundary`.

**Rule 8:** Isar queries never block the UI thread during scroll.

**Rule 9:** `ListView.builder` always — never `Column` for dynamic lists.

**Rule 10:** Dispose all `AnimationController`s and stream subscriptions when not in use.

---

# 77. ACCESSIBILITY CHECKLIST

## Color & Contrast
- [ ] Body text: 4.5:1 contrast minimum (light + dark + AMOLED)
- [ ] Heading text: 3:1 contrast minimum
- [ ] All status colors have secondary non-color indicators
- [ ] Chart data labeled numerically, not color-only

## Touch Targets
- [ ] All interactive elements ≥ 48×48dp
- [ ] Swipe-to-action has long-press fallback
- [ ] Touch targets have minimum 8dp gap between them

## Screen Reader
- [ ] All icon buttons have `tooltip` / `semanticLabel`
- [ ] Form fields have proper `labelText`
- [ ] Decorative images have empty `semanticsLabel`
- [ ] Dynamic content uses `Semantics(liveRegion: true)`

## Motion
- [ ] Respects `MediaQuery.disableAnimations`
- [ ] No critical information conveyed only through animation
- [ ] Auto-playing animations have pause control

## Typography
- [ ] Minimum font size 11sp everywhere
- [ ] Supports up to 200% system font scaling
- [ ] No layout breaks at 200% text scale

---

# 78. DEVELOPER HANDOFF GUIDELINES

## 78.1 Asset Delivery

- **SVG** for all illustrations and decorative graphics
- **2× PNG** for raster assets (splash only)
- **JSON** for Lottie animations
- **RIV** for Rive animations
- **TTF** for font files (all weights)

## 78.2 Spec Annotations

Every spec includes:
- Component name (matching Flutter widget)
- All measurements in `dp`
- Colors as hex + token name (`#4B39EF | primary`)
- Font: name + size + weight + letter-spacing
- All states documented

## 78.3 Token Usage Rule

**Engineers must use `Theme.of(context)` tokens exclusively. No hardcoded hex values in Flutter code.** Every color, spacing, and radius from the design token system.

## 78.4 Component Readiness Checklist

- [ ] All states specified (normal, hover, pressed, focused, disabled, loading, error)
- [ ] Accessibility labels defined
- [ ] Animation spec documented
- [ ] Dark theme verified
- [ ] AMOLED theme verified

---

# 79. DESIGN TOKENS

## 79.1 Flutter Implementation

```dart
// Conceptual token structure via ThemeExtension
class AttendifyTokens extends ThemeExtension<AttendifyTokens> {
  // Spacing
  static const double space1 = 4;
  static const double space2 = 8;
  static const double space3 = 12;
  static const double space4 = 16;
  static const double space6 = 24;
  static const double space8 = 32;

  // Radius
  static const double radiusXS  = 4;
  static const double radiusSM  = 8;
  static const double radiusMD  = 12;
  static const double radiusLG  = 16;
  static const double radiusXL  = 20;
  static const double radius2XL = 24;

  // Duration
  static const Duration durationInstant   = Duration(milliseconds: 100);
  static const Duration durationQuick     = Duration(milliseconds: 200);
  static const Duration durationStandard  = Duration(milliseconds: 300);
  static const Duration durationDeliberate= Duration(milliseconds: 400);

  // Curves
  static const Curve curveEmphasized  = Curves.easeInOutCubicEmphasized;
  static const Curve curveDecelerate  = Curves.easeOutCubic;
  static const Curve curveAccelerate  = Curves.easeInCubic;
}
```

## 79.2 Token Naming

```
[category][Variant][State]

colorPrimary / colorOnPrimary / colorPrimaryContainer
spacingMD / spacingLG
radiusLG / radius2XL
durationStandard / durationDeliberate
curveEmphasized / curveDecelerate
shadowLevel1 / shadowLevel3
```

---

# 80. COMPONENT LIBRARY

## 80.1 Core Components

```
Navigation:
  AtdNavigationBar, AtdTopAppBar, AtdLargeTopAppBar, AtdMoreSheet

Cards:
  AtdCard, AtdSubjectCard, AtdTaskCard, AtdTaskCardDashboard,
  AtdAttendanceCard, AtdStatCard, AtdNextClassCard

Charts:
  AtdCircularProgress, AtdLinearProgress, AtdBarChart,
  AtdLineChart, AtdDonutChart

States:
  AtdEmptyState, AtdErrorState, AtdSkeletonCard, AtdSkeletonList

Controls:
  AtdFilledButton, AtdTonalButton, AtdIconButton, AtdTextField,
  AtdFilterChipRow, AtdStatusBadge, AtdPriorityBadge

Overlays:
  AtdBottomSheet, AtdActionSheet, AtdConfirmDialog,
  AtdDestructiveDialog, AtdSnackbar, AtdRestorePreviewDialog

Indicators:
  AtdAttendanceDot, AtdBadge, AtdSectionHeader, AtdDivider
```

---

# 81. REUSABLE WIDGETS

Every component follows these rules:

1. **Pure presentation** — No business logic. Data in via constructor, events out via callbacks.
2. **`const` compatible** — Use `const` constructors where possible.
3. **Documented** — Dartdoc comment on every widget.
4. **Theme-aware** — All colors from `Theme.of(context)`.
5. **Accessibility-first** — Semantic labels built in.

## 81.1 Widget File Organization

```
lib/
├── design_system/
│   ├── tokens/
│   │   ├── app_colors.dart
│   │   ├── app_spacing.dart
│   │   ├── app_radius.dart
│   │   ├── app_typography.dart
│   │   └── app_motion.dart
│   ├── components/
│   │   ├── navigation/
│   │   ├── cards/
│   │   ├── charts/
│   │   ├── states/
│   │   ├── controls/
│   │   ├── overlays/
│   │   └── indicators/
│   └── theme/
│       ├── app_theme.dart
│       └── app_theme_extension.dart
```

---

# 82. NAMING CONVENTIONS

## 82.1 Widget Naming

```
Prefix:   Atd (for all custom components)
Format:   PascalCase
Examples: AtdCard, AtdSubjectCard, AtdTaskCard
```

## 82.2 File Naming

```
Widget:   atd_subject_card.dart
Provider: subject_provider.dart
Screen:   subjects_screen.dart
Model:    subject_model.dart
Token:    app_colors.dart
```

## 82.3 Asset Naming

```
SVG:      ic_empty_subjects.svg, ic_onboarding_welcome.svg
PNG:      img_app_logo.png
Lottie:   anim_task_complete.json, anim_backup_success.json
Rive:     rive_checkbox_toggle.riv, rive_fab_morph.riv
```

---

# 83. ASSET ORGANIZATION

```
assets/
├── images/
│   └── app_logo.png
├── icons/
│   ├── ic_empty_dashboard.svg
│   ├── ic_empty_subjects.svg
│   ├── ic_empty_planner.svg
│   ├── ic_empty_calendar.svg
│   ├── ic_empty_analytics.svg
│   ├── ic_error.svg
│   └── ic_backup_shield.svg
├── animations/
│   ├── lottie/
│   │   ├── anim_task_complete.json
│   │   ├── anim_backup_success.json
│   │   └── anim_celebration.json
│   └── rive/
│       ├── rive_checkbox.riv
│       └── rive_fab_icons.riv
└── fonts/
    ├── PlusJakartaSans-*.ttf
    └── JetBrainsMono-Regular.ttf
```

---

# 84. ILLUSTRATION LIBRARY

| ID | File | Context | Priority |
|----|------|---------|----------|
| IL-01 | ic_empty_dashboard.svg | Dashboard no subjects | High |
| IL-02 | ic_empty_subjects.svg | No subjects added | High |
| IL-03 | ic_empty_planner.svg | All tasks complete | High |
| IL-04 | ic_empty_calendar.svg | No events on day | Medium |
| IL-05 | ic_empty_analytics.svg | Not enough data | Medium |
| IL-06 | ic_error_general.svg | Error states | High |
| IL-07 | ic_backup_shield.svg | Backup screen header | Medium |
| IL-08 | ic_onboarding_1.svg | Onboarding screen 1 | Low |
| IL-09 | ic_onboarding_2.svg | Onboarding screen 2 | Low |
| IL-10 | ic_onboarding_3.svg | Onboarding screen 3 | Low |

---

# 85. ANIMATION LIBRARY

| ID | File | Trigger | Duration |
|----|------|---------|----------|
| AN-01 | anim_task_complete.json | Task checked | 1.5s |
| AN-02 | anim_backup_success.json | Backup created | 2.0s |
| AN-03 | anim_celebration.json | Achievement | 3.0s |
| AN-04 | rive_checkbox.riv | Checkbox toggle | 0.2s |
| AN-05 | rive_fab_icons.riv | FAB state change | 0.25s |

---

# 86. ICON LIBRARY

```yaml
# pubspec.yaml
dependencies:
  material_symbols_icons: ^4.2799.0
```

```dart
import 'package:material_symbols_icons/symbols.dart';

Icon(Symbols.home, fill: 1)   // active/filled
Icon(Symbols.home)            // default/outlined
```

**Rules:** Material Symbols exclusively. No custom icon fonts. No icon PNGs.

---

# 87. SVG ASSET RULES

1. Remove metadata, editor attributes, comments before committing.
2. Optimize with SVGO (reduce file size).
3. No embedded fonts — convert text to paths.
4. Explicit `viewBox` attribute required.
5. Use 200×200 or 240×240 viewBox for illustrations.
6. Name main paths with `id` attributes for programmatic color updates.

---

# 88. IMAGE OPTIMIZATION RULES

1. All PNGs through TinyPNG. Target < 50KB for UI images.
2. SVG preferred over PNG always.
3. No JPEG in UI — use PNG or WebP.
4. App icon: 512×512 PNG for Play Store + adaptive icon layers.
5. No 1x/2x/3x PNG sets — use single SVG.
6. Splash screen: simple vector, not full-resolution image.

---

# 89. PERFORMANCE BUDGET

## 89.1 Startup

```
Cold start to first interactive frame: < 1.5 seconds
Splash duration:                       < 500ms
First data display (from Isar):        < 200ms
```

## 89.2 Scroll

```
Target:  60fps during all list scrolling
Budget:  < 16ms per frame
Rules:   No overdraw > 2× screen area during scroll
         No charts/shimmer in scroll without RepaintBoundary
         No Isar queries on UI thread during scroll
```

## 89.3 Animation

```
Target:  60fps on Snapdragon 680+
Budget:  < 16ms per animation frame
Rules:   Use Transform/Opacity (GPU-composited) for all animations
         Never animate layout properties (width/height) — use Transform.scale
         Lottie: max 30fps, RepaintBoundary wrapped
```

## 89.4 Memory

```
Target:  < 150MB RAM normal usage
Peak:    < 200MB (during backup/restore)
Rules:   No in-memory image caches beyond visible items
         Dispose all controllers/streams when leaving screen
         Pagination for history lists (never load all records)
```

## 89.5 APK Size

```
Target:  < 25MB download size
Maximum: < 30MB
Rules:   SVG over PNG, flutter tree shaking, R8 minification,
         split APKs by ABI for Play Store
```

---

# 90. UX HEURISTICS

| # | Nielsen's Heuristic | How Attendify Satisfies It |
|---|--------------------|-----------------------------|
| 1 | Visibility of system status | Progress bars, skeletons, real-time %, haptic |
| 2 | Match system and real world | "Mark Present/Absent/Medical" not "Status 1/2/3" |
| 3 | User control & freedom | Undo snackbar for changes, back navigation everywhere |
| 4 | Consistency & standards | Meridian design system throughout |
| 5 | Error prevention | Date validation, no future attendance, confirmation dialogs |
| 6 | Recognition over recall | Chips, dropdowns, icon labels — never require memory |
| 7 | Flexibility & efficiency | Swipe gestures for power users, tap for novice |
| 8 | Aesthetic & minimalist design | Content first, progressive disclosure |
| 9 | Help recognize, diagnose, recover from errors | Specific error messages + guidance + auto-rollback |
| 10 | Help & documentation | Contextual tooltips, onboarding, microcopy throughout |

---

# 91. COMMON UX MISTAKES TO AVOID

## Navigation
❌ 7+ bottom navigation items  
❌ Hiding primary navigation in a drawer  
❌ No visual indication of active tab  
❌ Inconsistent back behavior  

## Typography
❌ More than 3 font weights per screen  
❌ Text below 11sp  
❌ ALL CAPS for sentences or long text  
❌ Light weight (300) for small text (12sp and below — use Medium 500)  

## Color
❌ Color as the only status indicator  
❌ More than 3 semantic colors simultaneously  
❌ Full-saturation colors as backgrounds  
❌ Pure black (#000000) text on white  

## Animation
❌ Animations over 500ms for user-triggered actions  
❌ Bounce animation on error states  
❌ Animating everything (animation blindness)  
❌ Blocking user interaction during animation  

## Data Display
❌ Raw numbers without context ("Present: 47" → "Present: 47 of 64 (73%)")  
❌ No offline status indication when data is cached  
❌ Burying the bunk calculator  
❌ Empty charts without explanation  

---

# 92. VISUAL CONSISTENCY CHECKLIST

Before any screen is marked implementation-complete:

**Colors:**
- [ ] All colors from `Theme.of(context)` — no hardcoded hex
- [ ] Status colors consistent with global semantic palette
- [ ] Dark + AMOLED theme verified for all states

**Typography:**
- [ ] Font is Plus Jakarta Sans throughout
- [ ] Type scale matches tokens exactly
- [ ] JetBrains Mono used for numbers/stats only

**Spacing:**
- [ ] All padding/margin from spacing tokens
- [ ] Screen horizontal margin = 16dp
- [ ] Card padding = 16dp | Section spacing = 24dp

**Components:**
- [ ] Buttons from AtdButton system
- [ ] Cards from AtdCard system
- [ ] Bottom sheets use AtdBottomSheet wrapper
- [ ] No one-off components without design system registration

**Motion:**
- [ ] All animations use motion tokens
- [ ] Reduce motion respected
- [ ] No animations blocking user input

---

# 93. PRODUCTION READINESS CHECKLIST

**Design:**
- [ ] All screens designed (light + dark + AMOLED)
- [ ] All states documented
- [ ] All components in library
- [ ] Animation specs complete
- [ ] Accessibility reviewed

**Engineering:**
- [ ] All colors from ThemeData / ThemeExtension
- [ ] `const` constructors throughout
- [ ] `RepaintBoundary` on all expensive widgets
- [ ] All lists use `ListView.builder`
- [ ] Semantic labels on all interactive elements
- [ ] Haptic feedback per spec

**Quality:**
- [ ] 60fps on Snapdragon 680
- [ ] Memory < 150MB normal usage
- [ ] APK < 25MB
- [ ] TalkBack navigation tested
- [ ] 200% text scale tested (no overflow)
- [ ] All orientations tested
- [ ] Offline mode tested

**Store:**
- [ ] App icon (512×512, adaptive layers)
- [ ] Play Store screenshots
- [ ] Feature graphic (1024×500)
- [ ] Description updated
- [ ] Privacy policy ready

---

# 94. FUTURE EXPANSION STRATEGY

## Cloud Sync

BackupRepository abstraction already supports it. UI needed:
- Cloud provider selection (Google Drive, OneDrive, iCloud)
- Auto-sync status in Settings
- Conflict resolution dialog

## AI Assistant

Entry point reserved in AppBar. Chat panel design specified in §73.

## Android Homescreen Widget

Shows: next class, attendance health, overdue count. Must match Meridian design tokens.

## Study Groups

Minimal — sharing attendance goals or deadlines with a peer group. Not a full social network.

## Institutional Integration

Import timetable from university portal via API. Plugin architecture for different university systems.

---

# 95. PHASE-WISE REDESIGN ROADMAP

## Phase 1: Foundation (Weeks 1–2) — CRITICAL

```
Deliverables:
  AppTheme with complete M3 + Meridian tokens
  ThemeExtension (spacing, radius, motion tokens)
  Plus Jakarta Sans + JetBrains Mono integration
  Dark theme + AMOLED theme complete
  Color token system
  AtdNavigationBar (5-tab + More sheet)
  AtdTopAppBar + AtdLargeTopAppBar
  AtdCard base component
  AtdFilledButton, AtdTextButton, AtdIconButton
  AtdTextField
  AtdSnackbar helper
  AtdEmptyState + AtdSkeletonCard
```

## Phase 2: Dashboard (Weeks 2–3) — HIGH

```
  Hero attendance health card (circular progress)
  Greeting with time-based logic
  Next class card (live countdown + attendance action)
  Upcoming deadlines widget (priority-sorted, max 5)
  Quick stats row
  Dashboard empty state + skeleton
  Stagger animation on load
```

## Phase 3: Subjects (Weeks 3–4) — HIGH

```
  Subject card (2-column grid, color stripe, progress bar)
  Subject detail screen (Hero transition, bunk calculator)
  Subject color picker
  Add/Edit form (bottom sheet)
  Empty state + skeleton
```

## Phase 4: Planner (Weeks 4–5) — HIGH

```
  Task card (left color border redesign)
  Priority sections (Overdue/Today/Tomorrow/Week)
  Task form sheet redesign
  Filter chips (scrollable two-row)
  Task completion animation
  Planner empty state
  FAB extended → Add Task
```

## Phase 5: Schedule (Weeks 5–6) — MEDIUM

```
  Day selector (horizontal pills)
  Timeline-style schedule list
  Quick attendance mark from schedule
  Add/Edit slot form
  Empty state
```

## Phase 6: Calendar (Weeks 6–7) — MEDIUM

```
  TableCalendar full Meridian theme
  Day cell dots — Wrap layout (overflow fix)
  Day detail panel redesign
  Calendar mode switching (month/2-week/week)
  Calendar empty state
```

## Phase 7: Analytics (Weeks 7–8) — MEDIUM

```
  AtdBarChart (subject-wise)
  AtdLineChart (weekly trend)
  AtdDonutChart (distribution)
  Summary stat cards row
  Period filter chips
  Chart animations
  Analytics empty state
```

## Phase 8: Settings + Backup (Weeks 8–9) — LOW-MEDIUM

```
  Settings screen full re-style
  AMOLED theme toggle
  Backup & Restore screen redesign
  Restore preview dialog
  Backup progress animation
  Cloud "Coming Soon" placeholder
```

## Phase 9: Polish & Micro-interactions (Weeks 9–10) — HIGH FOR QUALITY

```
  Swipe-to-action attendance marking
  Haptic feedback throughout
  Animated attendance counter
  Task completion animation (checkbox + strikethrough)
  Subject card load stagger
  FAB collapse/expand on scroll
  Pull-to-refresh custom animation
  All page transitions verified
```

## Phase 10: Accessibility & Performance (Weeks 10–11) — CRITICAL FOR RELEASE

```
  TalkBack testing and all fixes
  200% text scale testing
  60fps verification on Snapdragon 680
  Memory profiling + optimization
  APK size optimization
  Accessibility checklist §77: 100% complete
  Production readiness checklist §93: 100% complete
```

## Phase 11: Onboarding (Weeks 11–12) — MEDIUM

```
  3-screen onboarding flow
  SVG illustrations for each screen
  First subject setup inline form
  Completion animation
  Skip/resume logic
  Play Store screenshots from onboarding
```

---

## DOCUMENT COMPLETE

```
UI_REDESIGN_MASTER_PLAN.md
Attendify — Meridian Design Language
Version 1.0 | August 2026

Sections:         95
Status:           Complete. Implementation begins in Phase 1.
Architecture:     Unchanged. Visual layer only.
```

> This document is the single source of truth for the entire Attendify UI redesign.  
> Every design decision must reference this document.  
> Deviations require explicit justification and document update.

---
*End of UI_REDESIGN_MASTER_PLAN.md*
