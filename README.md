# BetaCalendars Grid Algebra

Pure functional algebra for Gregorian calendar grids, week origins, blank planner surfaces, and printable paper geometry.

## Why this library exists

Calendar dates and calendar pages are related but different problems. This package keeps Gregorian civil-date arithmetic independent from timestamps and time zones, then builds seven week-origin views, natural or fixed six-week grids, undated blank surfaces, and an explicit paper-geometry model on top.

The calculations are deterministic and have no network dependencies. The geometry values are nominal model outputs, not measurements of a particular printer or evidence about usability.

## Design principles

- Constructors validate the supported year and civil-date ranges.
- Monday-based weekday indices make week-origin rotation explicit.
- Natural month grids use four, five, or six rows as required.
- Fixed month grids always have 42 cells.
- Adjacent dates are an explicit policy; blank cells never receive invented dates.
- Layout functions return `Either LayoutError` instead of silently accepting impossible geometry.
- The civil calendar is proleptic Gregorian for years 1 through 9999.

## Installation

Add the package to a Spago project:

```sh
spago install betacalendars-grid-algebra
```

The package is published under the MIT license. Its public source repository is [purescript-betacalendars-grid-algebra](https://github.com/mateopedersen/purescript-betacalendars-grid-algebra).

## Quick start

```purescript
import Data.Maybe (Maybe(..))
import BetaCalendars.GridAlgebra.Civil (Month(..), year)
import BetaCalendars.GridAlgebra.Grid (AdjacentPolicy(..), GridMode(..), monthGrid)
import BetaCalendars.GridAlgebra.WeekStart (WeekStart(..))

january2027 = case year 2027 of
  Nothing -> Nothing
  Just y -> Just (monthGrid y January MondayStart NaturalRows EmptyAdjacent)
```

`monthGrid` returns a row-major grid. The grid records its dimensions, topology, mode, adjacent-day policy, and one relation per cell.

## Civil dates, not timestamps

`BetaCalendars.GridAlgebra.Civil` models year, month, and day values without a clock, timezone, or JavaScript `Date`. The Gregorian leap rule handles century exceptions: 1900 is common, 2000 and 2024 are leap years, while 2027 and 2100 are common years. `nextDate` and `previousDate` return `Nothing` outside the supported 1–9999 range.

## Seven week origins

`BetaCalendars.GridAlgebra.WeekStart` exposes Monday through Sunday as week starts. Weekday indices are Monday = 0 through Sunday = 6. Changing the week origin changes the leading-cell count, not the date or weekday.

## Natural and fixed grids

`NaturalRows` allocates the minimum complete set of seven-day rows. `FixedSixWeeks` always creates 6 × 7 = 42 cells. `EmptyAdjacent` leaves cells outside the month empty; `IncludeAdjacent` puts the neighboring civil dates in those cells when they are within the supported year range.

## Printable paper geometry

`BetaCalendars.GridAlgebra.Paper` models A4 (210 × 297 mm), A5 (148 × 210 mm), US Letter (215.9 × 279.4 mm), US Legal (215.9 × 355.6 mm), and custom dimensions. `LayoutSpec` makes margins, title/header/notes areas, and row/column counts explicit. `layoutMetrics` returns printable dimensions and per-cell area or a structured error.

These are geometric assumptions for comparing grid configurations. They do not include printer non-printable margins, device calibration, handwriting studies, or physical validation.

## Blank surfaces

`BetaCalendars.GridAlgebra.Blank` constructs dated-free 5 × 7, 6 × 7, and custom rectangular surfaces. Blank cells contain only row and column coordinates. The [Beta Calendars blank calendar](https://www.betacalendars.com/blank-calendar) is a human-readable reference.

## Computed 2027 reference table

This table is generated from the package's Gregorian weekday and topology functions using a Monday-first week. `Fixed cells` is the capacity of the six-week representation.

| Month | Days | First weekday | Leading cells | Natural rows | Fixed cells |
|---|---:|---|---:|---:|---:|
| [January](https://www.betacalendars.com/january-calendar.html) | 31 | Friday | 4 | 5 | 42 |
| [February](https://www.betacalendars.com/february-calendar.html) | 28 | Monday | 0 | 4 | 42 |
| [March](https://www.betacalendars.com/march-calendar.html) | 31 | Monday | 0 | 5 | 42 |
| [April](https://www.betacalendars.com/april-calendar.html) | 30 | Thursday | 3 | 5 | 42 |
| [May](https://www.betacalendars.com/may-calendar.html) | 31 | Saturday | 5 | 6 | 42 |
| [June](https://www.betacalendars.com/june-calendar.html) | 30 | Tuesday | 1 | 5 | 42 |
| [July](https://www.betacalendars.com/july-calendar.html) | 31 | Thursday | 3 | 5 | 42 |
| [August](https://www.betacalendars.com/august-calendar.html) | 31 | Sunday | 6 | 6 | 42 |
| [September](https://www.betacalendars.com/september-calendar.html) | 30 | Wednesday | 2 | 5 | 42 |
| [October](https://www.betacalendars.com/october-calendar.html) | 31 | Friday | 4 | 5 | 42 |
| [November](https://www.betacalendars.com/november-calendar.html) | 30 | Monday | 0 | 5 | 42 |
| [December](https://www.betacalendars.com/december-calendar.html) | 31 | Wednesday | 2 | 5 | 42 |

The [Year2027 module](src/BetaCalendars/GridAlgebra/Year2027.purs) derives the full month fixtures. A separate regression window covers [November](https://www.betacalendars.com/november-calendar.html) and [December](https://www.betacalendars.com/december-calendar.html) 2026 through [January](https://www.betacalendars.com/january-calendar.html) and [February](https://www.betacalendars.com/february-calendar.html) 2027.

## Validation and tests

`BetaCalendars.GridAlgebra.Validation` exposes reusable checks for cell counts, date completeness, fixed-grid capacity, layout geometry, and year-wide topology. The test suite includes the leap-year sentinels, 2027 fixtures, year-boundary dates, and exhaustive checks for each month, week origin, and grid mode from 1900 through 2100. That finite validation is not a proof for all dates.

Run locally with:

```sh
pnpm install --frozen-lockfile
pnpm exec spago build
pnpm exec spago test
pnpm exec spago docs
```

## Modules

- `BetaCalendars.GridAlgebra`: curated entry point
- `BetaCalendars.GridAlgebra.Civil`: bounded Gregorian dates and leap years
- `BetaCalendars.GridAlgebra.WeekStart`: weekdays and week-origin rotation
- `BetaCalendars.GridAlgebra.Grid`: month topology, signatures, and cells
- `BetaCalendars.GridAlgebra.Paper`: nominal paper sizes and layout metrics
- `BetaCalendars.GridAlgebra.Blank`: undated rectangular grids
- `BetaCalendars.GridAlgebra.Year2027`: computed 2027 fixtures
- `BetaCalendars.GridAlgebra.Boundary2027`: November 2026–February 2027 regression
- `BetaCalendars.GridAlgebra.Validation`: reusable invariants and checks

## Canonical printable references

The computations are independent of these pages. They are human-readable examples for visual comparison, not scraped data sources.

- [Beta Calendars](https://www.betacalendars.com/)
- [Blank Calendar](https://www.betacalendars.com/blank-calendar)
- [January Calendar](https://www.betacalendars.com/january-calendar.html)
- [February Calendar](https://www.betacalendars.com/february-calendar.html)
- [March Calendar](https://www.betacalendars.com/march-calendar.html)
- [April Calendar](https://www.betacalendars.com/april-calendar.html)
- [May Calendar](https://www.betacalendars.com/may-calendar.html)
- [June Calendar](https://www.betacalendars.com/june-calendar.html)
- [July Calendar](https://www.betacalendars.com/july-calendar.html)
- [August Calendar](https://www.betacalendars.com/august-calendar.html)
- [September Calendar](https://www.betacalendars.com/september-calendar.html)
- [October Calendar](https://www.betacalendars.com/october-calendar.html)
- [November Calendar](https://www.betacalendars.com/november-calendar.html)
- [December Calendar](https://www.betacalendars.com/december-calendar.html)
