-- | Pure month-grid construction and topology descriptions.
-- |
-- | Natural grids use the smallest whole number of seven-day rows that can
-- | hold the month. Fixed grids always contain six rows. Adjacent dates are
-- | optional display context and never replace a current-month date.
module BetaCalendars.GridAlgebra.Grid
  ( GridMode(..)
  , AdjacentPolicy(..)
  , CellRelation(..)
  , GridCell
  , MonthTopology
  , TopologySignature
  , topologySignature
  , MonthGrid
  , monthTopology
  , monthGrid
  , currentMonthDays
  ) where

import Prelude
import Data.Array as Array
import Data.Maybe (Maybe(..))
import BetaCalendars.GridAlgebra.Civil (CivilDate, Month(..), Year, civilDate, daysInMonth, firstDateOfMonth, lastDateOfMonth, monthNumber, monthFromNumber, weekdayOf, year, yearValue)
import BetaCalendars.GridAlgebra.WeekStart (WeekStart, Weekday, offsetFromWeekStart)

-- | Natural height or a fixed six-week calendar surface.
data GridMode = NaturalRows | FixedSixWeeks

derive instance eqGridMode :: Eq GridMode

-- | Whether dates outside the displayed month are rendered in spare cells.
data AdjacentPolicy = EmptyAdjacent | IncludeAdjacent

derive instance eqAdjacentPolicy :: Eq AdjacentPolicy

-- | The relationship of a cell's date to the displayed month.
data CellRelation = PreviousMonth | CurrentMonth | NextMonth | EmptyCell

derive instance eqCellRelation :: Eq CellRelation

-- | One row-major cell in a month grid.
type GridCell =
  { index :: Int
  , date :: Maybe CivilDate
  , relation :: CellRelation
  }

-- | Structural facts about one month under one week origin.
type MonthTopology =
  { year :: Year
  , month :: Month
  , days :: Int
  , firstWeekday :: Weekday
  , lastWeekday :: Weekday
  , leadingCells :: Int
  , trailingCells :: Int
  , naturalRows :: Int
  , fixedCells :: Int
  }

-- | Descriptive signature of a month's shape under a selected week origin.
-- | This package-specific tuple is useful for comparing shapes; it is not an
-- | external calendar standard.
newtype TopologySignature = TopologySignature
  { days :: Int
  , weekOriginOffset :: Int
  , naturalRows :: Int
  , trailingCapacity :: Int
  }

derive newtype instance eqTopologySignature :: Eq TopologySignature

-- | A complete dated month surface.
type MonthGrid =
  { year :: Year
  , month :: Month
  , weekStart :: WeekStart
  , mode :: GridMode
  , adjacentPolicy :: AdjacentPolicy
  , rows :: Int
  , columns :: Int
  , topology :: MonthTopology
  , cells :: Array GridCell
  }

-- | Compute month topology without allocating its cells.
monthTopology :: Year -> Month -> WeekStart -> MonthTopology
monthTopology y m start =
  let
    first = firstDateOfMonth y m
    last = lastDateOfMonth y m
    days = daysInMonth y m
    leading = offsetFromWeekStart start (weekdayOf first)
    rows = div (leading + days + 6) 7
    trailing = rows * 7 - leading - days
  in
    { year: y
    , month: m
    , days
    , firstWeekday: weekdayOf first
    , lastWeekday: weekdayOf last
    , leadingCells: leading
    , trailingCells: trailing
    , naturalRows: rows
    , fixedCells: 42
    }

-- | Build a row-major month grid for a validated year and month.
monthGrid :: Year -> Month -> WeekStart -> GridMode -> AdjacentPolicy -> MonthGrid
monthGrid y m start mode adjacentPolicy =
  let
    topology = monthTopology y m start
    rows = case mode of
      NaturalRows -> topology.naturalRows
      FixedSixWeeks -> 6
    count = rows * 7
    cells = map (makeCell topology) (Array.range 0 (count - 1))
  in
    { year: y
    , month: m
    , weekStart: start
    , mode
    , adjacentPolicy
    , rows
    , columns: 7
    , topology
    , cells
    }
  where
  makeCell topology index =
    let
      dayNumber = index - topology.leadingCells + 1
      days = topology.days
    in
      if dayNumber >= 1 && dayNumber <= days then
        { index, date: civilDate y m dayNumber, relation: CurrentMonth }
      else if adjacentPolicy == EmptyAdjacent then
        { index, date: Nothing, relation: EmptyCell }
      else if dayNumber < 1 then
        let
          priorMonthNumber = monthNumber m - 1
        in
          case
            if priorMonthNumber == 0 then
              case year (yearValue y - 1) of
                Nothing -> Nothing
                Just priorYear -> Just { year: priorYear, month: December }
            else map (\priorMonth -> { year: y, month: priorMonth }) (monthFromNumber priorMonthNumber)
            of
            Nothing -> { index, date: Nothing, relation: EmptyCell }
            Just prior ->
              let
                priorDate = civilDate prior.year prior.month (daysInMonth prior.year prior.month + dayNumber)
              in
                { index, date: priorDate, relation: if priorDate == Nothing then EmptyCell else PreviousMonth }
      else
        let
          nextMonthNumber = monthNumber m + 1
        in
          case
            if nextMonthNumber == 13 then
              case year (yearValue y + 1) of
                Nothing -> Nothing
                Just nextYear -> Just { year: nextYear, month: January }
            else map (\nextMonth -> { year: y, month: nextMonth }) (monthFromNumber nextMonthNumber)
            of
            Nothing -> { index, date: Nothing, relation: EmptyCell }
            Just next ->
              let
                nextDateValue = civilDate next.year next.month (dayNumber - days)
              in
                { index, date: nextDateValue, relation: if nextDateValue == Nothing then EmptyCell else NextMonth }

-- | The number of current-month cells in a grid.
currentMonthDays :: MonthGrid -> Int
currentMonthDays grid = Array.length (Array.filter (\cell -> cell.relation == CurrentMonth) grid.cells)

-- | Create this package's descriptive topology tuple.
topologySignature :: MonthTopology -> WeekStart -> TopologySignature
topologySignature topology start =
  let
    offset = offsetFromWeekStart start topology.firstWeekday
  in
    TopologySignature
      { days: topology.days
      , weekOriginOffset: offset
      , naturalRows: topology.naturalRows
      , trailingCapacity: topology.naturalRows * 7 - offset - topology.days
      }
