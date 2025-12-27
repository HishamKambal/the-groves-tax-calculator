
---

## `Technical_Report.md` (starter)

```md
# Technical Report — The Groves

## Architecture
- Riverpod for state management
- Hive for local persistence (cart, history, settings)
- Domain logic isolated in TaxCalculator using Decimal arithmetic

## Rounding policy
- Calculations performed using Decimal to avoid floating precision
- Per-item values are rounded to 2 decimals and stored
- Grand totals are computed as sums of stored per-item components so totals always match UI

## Tobacco multiplier
- Default set to 2.30 as confirmed by IT manager
- Multiplier is configurable in Settings for flexibility
