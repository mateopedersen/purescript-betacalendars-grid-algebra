-- | Undated planner surfaces with no synthetic civil dates.
-- |
-- | Blank grids are a separate primitive from dated month grids. Each cell is
-- | identified only by its zero-based row and column.
-- | A printable undated example is the [Beta Calendars blank calendar](https://www.betacalendars.com/blank-calendar).
module BetaCalendars.GridAlgebra.Blank
  ( BlankCell
  , BlankGrid
  , blankGrid
  , blankLayout
  , blankCellArea
  , blankWritingArea
  , compareBlankLayouts
  ) where

import Prelude
import Data.Array as Array
import Data.Either (Either(..))
import BetaCalendars.GridAlgebra.Paper (LayoutError(..), LayoutMetrics, LayoutSpec, layoutMetrics)

-- | A location in an undated blank surface.
type BlankCell = { row :: Int, column :: Int }

-- | A rectangular undated grid.
type BlankGrid = { rows :: Int, columns :: Int, cells :: Array BlankCell }

-- | Construct a 5×7, 6×7, or other positive rectangular blank grid.
blankGrid :: Int -> Int -> Either LayoutError BlankGrid
blankGrid rows columns =
  if rows <= 0 || columns <= 0 then Left InvalidGridShape
  else Right
    { rows
    , columns
    , cells: Array.concatMap
        (\row -> map (\column -> { row, column }) (Array.range 0 (columns - 1)))
        (Array.range 0 (rows - 1))
    }

-- | Compute printable geometry for an undated grid.
blankLayout :: LayoutSpec -> Either LayoutError LayoutMetrics
blankLayout = layoutMetrics

-- | Area of one blank cell in square millimeters.
blankCellArea :: LayoutMetrics -> Number
blankCellArea metrics = metrics.cellArea

-- | Total modeled area available in the grid cells.
blankWritingArea :: LayoutMetrics -> Number
blankWritingArea metrics = metrics.writingArea

-- | Compare the per-cell area of two valid blank layouts.
compareBlankLayouts :: LayoutSpec -> LayoutSpec -> Either LayoutError { first :: LayoutMetrics, second :: LayoutMetrics, cellAreaDifference :: Number }
compareBlankLayouts firstSpec secondSpec = do
  first <- layoutMetrics firstSpec
  second <- layoutMetrics secondSpec
  pure { first, second, cellAreaDifference: first.cellArea - second.cellArea }
