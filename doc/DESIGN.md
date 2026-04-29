# The Design System: Precision & Serenity



## 1. Overview & Creative North Star

The Creative North Star for this design system is **"The Swiss Architect."**



This vision moves away from the cluttered, anxiety-inducing nature of traditional finance apps. Instead, it embraces the precision of Swiss editorial design—think high-end watchmaking journals and minimalist architecture. We achieve a "custom" feel by breaking the rigid, boxed-in grid of standard mobile apps. By using intentional asymmetry, generous whitespace (breathe), and high-contrast typography scales, the UI feels like a curated financial dossier rather than a database. We prioritize calm through a muted, layered palette and trust through rock-solid typographic hierarchy.



---



## 2. Colors & Surface Philosophy

The palette is rooted in a sophisticated Teal (`primary`), balanced by warm neutrals that mimic premium paper stock.



### The "No-Line" Rule

**Borders are prohibited for sectioning content.** We do not use 1px solid lines to separate modules. Instead, boundaries must be defined solely through background color shifts. A `surface-container-low` section sitting on a `surface` background creates a clear but soft structural division that feels modern and expensive.



### Surface Hierarchy & Nesting

Treat the UI as a series of physical layers—stacked sheets of frosted glass.

* **Base:** `surface` (#fbf9f9) – The desk.

* **Sectioning:** `surface-container-low` (#f5f3f3) – Large content blocks.

* **Cards:** `surface-container-lowest` (#ffffff) – Individual interactive elements.

* **Active Overlays:** `surface-bright` (#fbf9f9) – For elements requiring maximum focus.



### The "Glass & Gradient" Rule

To avoid a "flat" SaaS look, use **Glassmorphism** for floating elements (like bottom sheets or sticky headers). Apply `surface-container-lowest` at 80% opacity with a `backdrop-filter: blur(20px)`. Main CTAs should use a subtle linear gradient from `primary` (#006565) to `primary-container` (#008080) at a 135° angle to provide visual depth and "soul."



---



## 3. Typography: The Editorial Scale

We use a dual-font system to balance character with functional clarity.



* **Display & Headlines (Manrope):** Our "Authoritative" voice. Used for large Swiss Franc (CHF) amounts and section headers. High tracking (-2%) on `display-lg` to create a tight, premium look.

* **Body & Labels (Inter):** Our "Functional" voice. Highly legible at small sizes.



**The Financial Signature:**

All currency amounts must use `headline-md` or `display-sm` in **Bold**. The "CHF" suffix must be set in `label-md` with `on-surface-variant` (#3e4949) to ensure the numbers—the data the user cares about—take center stage.



---



## 4. Elevation & Depth

Depth is achieved through **Tonal Layering**, not shadows.



* **The Layering Principle:** Place a `surface-container-lowest` card on a `surface-container-low` background. The subtle 2-bit color shift creates a natural "lift."

* **Ambient Shadows:** If an element must float (e.g., a FAB or a detached Bottom Sheet), use a shadow with a 32px blur, 0px spread, and 4% opacity using the `on-surface` color. It should look like a soft glow, not a dark smudge.

* **The "Ghost Border" Fallback:** For high-density data where separation is difficult, use a "Ghost Border": `outline-variant` (#bdc9c8) at **15% opacity**. Never use 100% opaque borders.



---



## 5. Components



### Cards & Lists (The Core)

* **The Rule:** No dividers. Use `spacing-4` (1.4rem) to separate list items.

* **Style:** `rounded-lg` (1rem) for main cards. Use `surface-container-lowest` to make cards "pop" against the `surface` background.

* **Expandable Tree Rows:** Use a subtle background shift to `surface-container-high` (#e9e8e7) when a row is expanded to show child expenses.



### Circular & Linear Progress

* **On Track (<85%):** `primary` (#006565).

* **Warning (85-100%):** `tertiary-fixed` (#fbbc00) – High-end Amber.

* **Deficit (>100%):** `error` (#ba1a1a).

* **Visual Treatment:** Progress bars should have a `rounded-full` cap. The "track" (empty part) should be `surface-container-highest` (#e3e2e2) to maintain the soft look.



### Buttons & Inputs

* **Primary Button:** Gradient fill (`primary` to `primary-container`), `rounded-md` (0.75rem), `body-lg` (bold) text in `on-primary` (#ffffff).

* **Input Fields:** Use a "minimalist underline" approach or a soft-filled box (`surface-container-low`). Labels must be `label-md` in `on-surface-variant`.

* **Bottom Sheets:** Always use `rounded-xl` (1.5rem) on the top corners. Apply the Glassmorphism rule (80% opacity + blur) to ensure the user feels "connected" to the dashboard underneath.



### Signature Component: The "Offset yearly" View

* **Color:** `secondary` (#005faf).

* **Treatment:** A full-bleed `surface-container-lowest` card with a `secondary` accent flourish on the left edge (4px width).



---



## 6. Do’s and Don’ts



### Do:

* **Do** use `spacing-8` (2.75rem) as your default margin for page edges to create an "expensive" editorial feel.

* **Do** use `label-sm` in uppercase with 1px letter-spacing for metadata like "FIXED EXPENSE" or "VARIABLE."

* **Do** embrace asymmetry. A large balance on the top left balanced by a small "Settings" icon on the bottom right creates a dynamic, custom layout.



### Don't:

* **Don't** use pure black (#000000). Use `on-background` (#1b1c1c) for text to keep the "friendly" and "calm" tone.

* **Don't** use standard Material Design ripples. Use subtle opacity fades (1.0 to 0.8) for tap states to maintain a high-end feel.

* **Don't** use icons as purely decorative elements. Every icon (Lock for Fixed, Shopping Bag for Variable) must serve as a functional "anchor" for the user's eye.