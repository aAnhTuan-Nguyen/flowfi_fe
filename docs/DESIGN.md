---
name: Organic Equilibrium
colors:
  surface: "#fff8f3"
  surface-dim: "#ffd395"
  surface-bright: "#fff8f3"
  surface-container-lowest: "#ffffff"
  surface-container-low: "#fff1e3"
  surface-container: "#ffebd3"
  surface-container-high: "#ffe4c2"
  surface-container-highest: "#ffddb1"
  on-surface: "#291800"
  on-surface-variant: "#444842"
  inverse-surface: "#442b00"
  inverse-on-surface: "#ffeedb"
  outline: "#757872"
  outline-variant: "#c5c7c0"
  surface-tint: "#5a6057"
  primary: "#040804"
  on-primary: "#ffffff"
  primary-container: "#1b211a"
  on-primary-container: "#82897f"
  inverse-primary: "#c2c8be"
  secondary: "#49672a"
  on-secondary: "#ffffff"
  secondary-container: "#caeea2"
  on-secondary-container: "#4f6d2f"
  tertiary: "#030900"
  on-tertiary: "#ffffff"
  tertiary-container: "#112400"
  on-tertiary-container: "#6f914c"
  error: "#ba1a1a"
  on-error: "#ffffff"
  error-container: "#ffdad6"
  on-error-container: "#93000a"
  primary-fixed: "#dee4d9"
  primary-fixed-dim: "#c2c8be"
  on-primary-fixed: "#171d16"
  on-primary-fixed-variant: "#424840"
  secondary-fixed: "#caeea2"
  secondary-fixed-dim: "#afd188"
  on-secondary-fixed: "#0f2000"
  on-secondary-fixed-variant: "#324e14"
  tertiary-fixed: "#c9ee9f"
  tertiary-fixed-dim: "#add286"
  on-tertiary-fixed: "#0e2000"
  on-tertiary-fixed-variant: "#314f12"
  background: "#fff8f3"
  on-background: "#291800"
  surface-variant: "#ffddb1"
typography:
  display-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 48px
    fontWeight: "700"
    lineHeight: 56px
    letterSpacing: -0.02em
  headline-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 32px
    fontWeight: "600"
    lineHeight: 40px
    letterSpacing: -0.01em
  headline-lg-mobile:
    fontFamily: Plus Jakarta Sans
    fontSize: 28px
    fontWeight: "600"
    lineHeight: 36px
    letterSpacing: -0.01em
  headline-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 24px
    fontWeight: "600"
    lineHeight: 32px
  body-lg:
    fontFamily: Plus Jakarta Sans
    fontSize: 18px
    fontWeight: "400"
    lineHeight: 28px
  body-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 16px
    fontWeight: "400"
    lineHeight: 24px
  label-md:
    fontFamily: Plus Jakarta Sans
    fontSize: 14px
    fontWeight: "600"
    lineHeight: 20px
    letterSpacing: 0.01em
  label-sm:
    fontFamily: Plus Jakarta Sans
    fontSize: 12px
    fontWeight: "500"
    lineHeight: 16px
    letterSpacing: 0.02em
rounded:
  sm: 0.25rem
  DEFAULT: 0.5rem
  md: 0.75rem
  lg: 1rem
  xl: 1.5rem
  full: 9999px
spacing:
  unit: 8px
  container-padding-mobile: 20px
  container-padding-desktop: 40px
  gutter: 24px
  stack-sm: 8px
  stack-md: 16px
  stack-lg: 32px
---

## Brand & Style

The design system is anchored in the concept of "Financial Wellness," shifting the narrative of money management from anxiety-inducing spreadsheets to a mindful, sustainable journey. It targets a modern audience seeking clarity and emotional balance in their financial lives.

The visual style is **Organic Minimalism**. It combines the structure of premium fintech with the softness of wellness applications. By utilizing a palette inspired by nature—deep forest greens and vibrant, earthy ambers—the interface feels grounded yet energized. The aesthetic avoids the harshness of traditional banking "blue" in favor of a warmer, more human experience. Elements are spacious, allowing content to breathe, and use soft shadows to mimic physical layers of paper and organic materials.

## Colors

The palette is designed to evoke a sense of growth and stability with a touch of warmth.

- **Primary Dark (#1B211A):** Used for primary headings, high-priority text, and deep-level navigation backgrounds. It provides the necessary "weight" to ensure the brand feels established and secure.
- **Primary Green (#628141):** The workhorse for interaction. Used for primary buttons, active states, and focus indicators. It represents action and health.
- **Accent Green (#8BAE66):** Reserved for positive growth indicators, AI-driven insights, and "success" states. It has a higher vibration than the primary green to draw attention to progress.
- **Golden Neutral (#E09B1A):** This serves as the foundational accent for the UI's surfaces. Used for card surfaces and secondary backgrounds, it provides a warm, autumnal energy that feels more inviting than sterile greys.

The default experience is **Light Mode**, utilizing a "Canvas" color (#FFF8F2) that maintains subtle depth without relying on heavy borders.

## Typography

This design system utilizes **Plus Jakarta Sans** across all levels to maintain a soft, modern, and highly legible presence. The typography is characterized by generous line-heights and slightly tight letter-spacing for headlines to create a customized, editorial feel.

Large display type should be used sparingly to highlight key financial milestones or "mindful moments." Body text prioritizes readability, using the slightly larger 18px `body-lg` for primary narrative content to reduce eye strain and promote a "calm" reading pace.

## Layout & Spacing

The layout philosophy follows a **Fluid Grid** with intentional "breathing room."

- **Desktop:** 12-column grid with 24px gutters. Content is often centered in a max-width container (1200px) to prevent overly long line lengths.
- **Mobile:** 4-column grid with 20px side margins.

Spacing follows a strict 8px rhythm. To enhance the "calm" mood, vertical stack spacing between unrelated sections should be aggressive (e.g., `stack-lg`), while related items within a card use `stack-sm` or `stack-md`. Avoid cramped layouts; if an element feels tight, default to the next spacing tier.

## Elevation & Depth

This design system avoids the harsh drop shadows of traditional UI. Instead, it uses **Ambient Tonal Shadows** to create a sense of soft tactility.

1.  **Level 0 (Canvas):** The base background layer (#FFF8F2).
2.  **Level 1 (Surfaces):** Cards and primary containers use the Golden Neutral (#E09B1A) tones. They feature a very soft, diffused shadow: `0px 4px 20px rgba(27, 33, 26, 0.05)`.
3.  **Level 2 (Interactive):** Elements like active buttons or hovered cards lift slightly, using a more pronounced but still soft shadow: `0px 8px 30px rgba(27, 33, 26, 0.08)`.

Depth is also communicated through color; as elements get "closer" to the user, they move from the background canvas to the warmer, more saturated surface containers.

## Shapes

The shape language is organic and approachable.

- **Standard Elements:** All buttons and small input fields use a minimum of `0.5rem` (8px) corner radius.
- **Cards & Containers:** To achieve the "premium organic" look requested, all primary containers and cards must use a **16px (1rem)** or **24px (1.5rem)** radius.
- **Iconography:** Icons should feature rounded caps and corners, avoiding sharp 90-degree angles to remain consistent with the typography and container styles.

## Components

### Buttons

Primary buttons use the Primary Green (#628141) with white text. They are large (min-height 48px) with significant horizontal padding. Secondary buttons use an outline of the Primary Dark or a subtle tint of the Golden Neutral.

### Cards

Cards are the heart of the design system. They should always use the Golden Neutral (#E09B1A) for background accents or surface containers with 16px+ rounded corners. Borders are avoided; use the soft ambient shadows defined in Elevation to create separation.

### Inputs & Forms

Input fields use a subtle tint of the background canvas with a Primary Dark bottom-border or a very thin all-around stroke. When focused, the stroke thickens and transitions to Primary Green.

### AI Insights & Chips

Small informational chips or AI-generated suggestions use the Accent Green (#8BAE66) with a 10% opacity background of the same color to create a soft "glow" effect that highlights growth without being jarring.

### Progress Bars

Used for tracking financial goals, these should be thick (8px+) with fully rounded caps (pill-shaped), using Accent Green for the "filled" state to represent healthy progress.
