module Examples.PaperComparison where

import Data.Either (Either)
import Data.Maybe (fromMaybe)
import BetaCalendars.GridAlgebra.Paper (LayoutError, LayoutMetrics, Orientation(..), PaperSize(..), defaultMargins, layoutMetrics, millimeters)

letterSixWeekLayout :: Either LayoutError LayoutMetrics
letterSixWeekLayout = layoutMetrics
  { paper: Letter
  , orientation: Portrait
  , margins: defaultMargins
  , titleHeight: fromMaybe defaultMargins.top (millimeters 15.0)
  , weekdayHeaderHeight: fromMaybe defaultMargins.top (millimeters 8.0)
  , notesHeight: fromMaybe defaultMargins.top (millimeters 20.0)
  , rows: 6
  , columns: 7
  }
