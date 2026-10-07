-- | Regression fixtures around the 2026–2027 year boundary.
-- |
-- | The window covers November and December 2026 followed by January and
-- | February 2027, including a non-leap February and the year rollover.
-- | References: [November](https://www.betacalendars.com/november-calendar.html),
-- | [December](https://www.betacalendars.com/december-calendar.html),
-- | [January](https://www.betacalendars.com/january-calendar.html), and
-- | [February](https://www.betacalendars.com/february-calendar.html).
module BetaCalendars.GridAlgebra.Boundary2027
  ( BoundaryMonth
  , boundary2027
  , boundaryRegressionValid
  ) where

import Prelude
import Data.Maybe (Maybe(..))
import BetaCalendars.GridAlgebra.Civil (Month(..), Year, civilDate, daysInMonth, nextDate, year)
import BetaCalendars.GridAlgebra.Grid (MonthTopology, monthTopology)
import BetaCalendars.GridAlgebra.WeekStart (WeekStart)

-- | One date-topology entry in the regression window.
type BoundaryMonth =
  { year :: Year
  , month :: Month
  , days :: Int
  , topology :: MonthTopology
  }

-- | The computed November 2026–February 2027 regression window.
boundary2027 :: WeekStart -> Array BoundaryMonth
boundary2027 start = case year 2026, year 2027 of
  Just y2026, Just y2027 ->
    [ entry y2026 November
    , entry y2026 December
    , entry y2027 January
    , entry y2027 February
    ]
  _, _ -> []
  where
  entry y month =
    { year: y
    , month
    , days: daysInMonth y month
    , topology: monthTopology y month start
    }

-- | True when month lengths and the December-to-January civil transition match
-- | the intended boundary fixture.
boundaryRegressionValid :: Boolean
boundaryRegressionValid =
  let
    lengthsCorrect = case year 2026, year 2027 of
      Just y2026, Just y2027 ->
        daysInMonth y2026 November == 30
          && daysInMonth y2026 December == 31
          && daysInMonth y2027 January == 31
          && daysInMonth y2027 February == 28
      _, _ -> false
    rolloverCorrect = case year 2026, year 2027 of
      Just y2026, Just y2027 -> case civilDate y2026 December 31, civilDate y2027 January 1 of
        Just december31, Just january1 -> nextDate december31 == Just january1
        _, _ -> false
      _, _ -> false
  in
    lengthsCorrect && rolloverCorrect
