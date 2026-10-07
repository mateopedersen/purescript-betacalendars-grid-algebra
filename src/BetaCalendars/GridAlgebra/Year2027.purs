-- | Computed month-topology fixtures for the Gregorian year 2027.
-- |
-- | All weekday and row values are derived through the civil-date and grid
-- | algorithms in this package rather than hand-entered fixture literals.
-- |
-- | Printable references: [January](https://www.betacalendars.com/january-calendar.html),
-- | [February](https://www.betacalendars.com/february-calendar.html),
-- | [March](https://www.betacalendars.com/march-calendar.html),
-- | [April](https://www.betacalendars.com/april-calendar.html),
-- | [May](https://www.betacalendars.com/may-calendar.html),
-- | [June](https://www.betacalendars.com/june-calendar.html),
-- | [July](https://www.betacalendars.com/july-calendar.html),
-- | [August](https://www.betacalendars.com/august-calendar.html),
-- | [September](https://www.betacalendars.com/september-calendar.html),
-- | [October](https://www.betacalendars.com/october-calendar.html),
-- | [November](https://www.betacalendars.com/november-calendar.html), and
-- | [December](https://www.betacalendars.com/december-calendar.html).
module BetaCalendars.GridAlgebra.Year2027
  ( YearMonthTopology
  , FixedGridOccupancy
  , year2027
  , monthTopologies2027
  , mondayFirst2027
  , sundayFirst2027
  , fixedGridOccupancy2027
  ) where

import Prelude
import Data.Maybe (Maybe(..))
import BetaCalendars.GridAlgebra.Civil (Month, allMonths, year)
import BetaCalendars.GridAlgebra.Grid (MonthTopology, monthTopology)
import BetaCalendars.GridAlgebra.WeekStart (WeekStart(..))

-- | Month identity paired with its computed topology.
type YearMonthTopology = { month :: Month, topology :: MonthTopology }

-- | Occupied and spare capacity of one fixed 42-cell month surface.
type FixedGridOccupancy =
  { month :: Month
  , leadingCells :: Int
  , currentMonthCells :: Int
  , remainingCells :: Int
  }

-- | Monday-first computed topology for all twelve months of 2027.
year2027 :: Array YearMonthTopology
year2027 = mondayFirst2027

-- | Compute all twelve month topologies for a selected week origin.
monthTopologies2027 :: WeekStart -> Array YearMonthTopology
monthTopologies2027 start = case year 2027 of
  Nothing -> []
  Just y -> map (\month -> { month, topology: monthTopology y month start }) allMonths

-- | Monday-first reference values for 2027.
mondayFirst2027 :: Array YearMonthTopology
mondayFirst2027 = monthTopologies2027 MondayStart

-- | Sunday-first reference values for 2027.
sundayFirst2027 :: Array YearMonthTopology
sundayFirst2027 = monthTopologies2027 SundayStart

-- | Cell occupancy when each 2027 month is laid out on six fixed rows.
fixedGridOccupancy2027 :: WeekStart -> Array FixedGridOccupancy
fixedGridOccupancy2027 start = map toOccupancy (monthTopologies2027 start)
  where
  toOccupancy value =
    { month: value.month
    , leadingCells: value.topology.leadingCells
    , currentMonthCells: value.topology.days
    , remainingCells: 42 - value.topology.leadingCells - value.topology.days
    }
