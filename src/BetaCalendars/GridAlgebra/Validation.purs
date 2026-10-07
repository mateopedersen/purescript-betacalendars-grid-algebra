-- | Reusable structural checks for grids, dates, layouts, and whole years.
-- |
-- | These checks are ordinary pure values, so applications may run them at
-- | ingestion boundaries or tests without introducing effects.
module BetaCalendars.GridAlgebra.Validation
  ( ValidationIssue(..)
  , validateMonthGrid
  , validateFixedGrid
  , validateDateCompleteness
  , validateLayout
  , validateYear
  ) where

import Prelude
import Data.Array as Array
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import BetaCalendars.GridAlgebra.Civil (Month, Year, allMonths, dateDay, dayOfMonthValue, daysInMonth)
import BetaCalendars.GridAlgebra.Grid (AdjacentPolicy(..), CellRelation(..), GridMode(..), MonthGrid, monthGrid)
import BetaCalendars.GridAlgebra.Paper (LayoutError, LayoutSpec, layoutMetrics)
import BetaCalendars.GridAlgebra.WeekStart (WeekStart, allWeekStarts)

-- | A concrete invariant violation found by one of the validation functions.
data ValidationIssue
  = GridCellCountMismatch Int Int
  | CurrentMonthDateSequenceMismatch
  | FirstDayOffsetMismatch Int Int
  | NaturalRowCountOutOfRange Int
  | FixedGridHasWrongCellCount Int
  | LayoutRejected LayoutError

derive instance eqValidationIssue :: Eq ValidationIssue

-- | Check row-major size, the first-day offset, natural row bounds, and date
-- | completeness for a constructed month grid.
validateMonthGrid :: MonthGrid -> Array ValidationIssue
validateMonthGrid grid =
  let
    expectedCount = grid.rows * grid.columns
    countIssues = if Array.length grid.cells == expectedCount then [] else [ GridCellCountMismatch expectedCount (Array.length grid.cells) ]
    completenessIssues = validateDateCompleteness grid
    offsetIssues =
      let
        firstIndex = case Array.findIndex (\cell -> cell.relation == CurrentMonth) grid.cells of
          Nothing -> -1
          Just index -> index
      in
        if firstIndex == grid.topology.leadingCells then [] else [ FirstDayOffsetMismatch grid.topology.leadingCells firstIndex ]
    naturalIssues = if grid.topology.naturalRows >= 4 && grid.topology.naturalRows <= 6 then [] else [ NaturalRowCountOutOfRange grid.topology.naturalRows ]
  in
    countIssues <> completenessIssues <> offsetIssues <> naturalIssues

-- | Check that a grid explicitly selected as fixed six weeks has 42 cells.
validateFixedGrid :: MonthGrid -> Array ValidationIssue
validateFixedGrid grid =
  if grid.mode == FixedSixWeeks && Array.length grid.cells == 42 then []
  else [ FixedGridHasWrongCellCount (Array.length grid.cells) ]

-- | Confirm that days 1 through the month's final day occur exactly once and
-- | in order as current-month cells.
validateDateCompleteness :: MonthGrid -> Array ValidationIssue
validateDateCompleteness grid =
  let
    actual = Array.concatMap
      ( \cell ->
          if cell.relation == CurrentMonth then
            case cell.date of
              Nothing -> []
              Just date -> [ dayOfMonthValue (dateDay date) ]
          else []
      )
      grid.cells
    expected = Array.range 1 (daysInMonth grid.year grid.month)
  in
    if actual == expected then [] else [ CurrentMonthDateSequenceMismatch ]

-- | Validate a printable layout and report the specific geometry error.
validateLayout :: LayoutSpec -> Array ValidationIssue
validateLayout spec = case layoutMetrics spec of
  Left issue -> [ LayoutRejected issue ]
  Right _ -> []

-- | Exhaustively validate both grid modes and all seven week origins for a
-- | year. This is deterministic finite checking, not a proof over all years.
validateYear :: Year -> Array ValidationIssue
validateYear y =
  Array.concatMap validateMonth allMonths
  where
  validateMonth :: Month -> Array ValidationIssue
  validateMonth month = Array.concatMap (validateStart month) allWeekStarts

  validateStart :: Month -> WeekStart -> Array ValidationIssue
  validateStart month start = Array.concatMap (validateMode month start) [ NaturalRows, FixedSixWeeks ]

  validateMode :: Month -> WeekStart -> GridMode -> Array ValidationIssue
  validateMode month start mode =
    let
      grid = monthGrid y month start mode EmptyAdjacent
    in
      validateMonthGrid grid <> if mode == FixedSixWeeks then validateFixedGrid grid else []
