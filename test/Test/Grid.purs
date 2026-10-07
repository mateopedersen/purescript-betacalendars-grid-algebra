module Test.Grid (spec) where

import Prelude
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import BetaCalendars.GridAlgebra.Civil (Month(..), year)
import BetaCalendars.GridAlgebra.Grid (AdjacentPolicy(..), CellRelation(..), GridMode(..), monthGrid, monthTopology)
import BetaCalendars.GridAlgebra.Validation (validateDateCompleteness, validateFixedGrid, validateMonthGrid, validateYear)
import BetaCalendars.GridAlgebra.WeekStart (WeekStart(..), Weekday(..), allWeekStarts, relativeWeekdayIndex, rotateWeekOrigin)

spec :: Spec Unit
spec = describe "month grids and week origins" do
  it "supports all seven rotations and Monday-relative offsets" do
    relativeWeekdayIndex MondayStart Monday `shouldEqual` 0
    relativeWeekdayIndex SundayStart Monday `shouldEqual` 1
    rotateWeekOrigin SundayStart 1 `shouldEqual` Monday
    rotateWeekOrigin MondayStart 8 `shouldEqual` Tuesday
    Array.length allWeekStarts `shouldEqual` 7
  it "uses four through six natural rows and exactly 42 fixed cells" do
    case year 2027 of
      Nothing -> pure unit
      Just y -> do
        let grids = map (\start -> monthGrid y February start NaturalRows EmptyAdjacent) allWeekStarts
        Array.all (\grid -> grid.rows >= 4 && grid.rows <= 6) grids `shouldEqual` true
        let fixed = monthGrid y February SundayStart FixedSixWeeks IncludeAdjacent
        Array.length fixed.cells `shouldEqual` 42
        Array.null (validateFixedGrid fixed) `shouldEqual` true
        Array.null (validateDateCompleteness fixed) `shouldEqual` true
  it "keeps adjacent cells explicit and preserves all current-month dates" do
    case year 2027 of
      Nothing -> pure unit
      Just y -> do
        let emptyGrid = monthGrid y January SundayStart FixedSixWeeks EmptyAdjacent
        let adjacentGrid = monthGrid y January SundayStart FixedSixWeeks IncludeAdjacent
        Array.length (Array.filter (\cell -> cell.relation == EmptyCell) emptyGrid.cells) `shouldEqual` 11
        Array.length (Array.filter (\cell -> cell.relation == PreviousMonth) adjacentGrid.cells) `shouldEqual` 5
        Array.null (validateMonthGrid emptyGrid) `shouldEqual` true
        Array.null (validateMonthGrid adjacentGrid) `shouldEqual` true
  it "computes a known 2027 topology from Gregorian rules" do
    case year 2027 of
      Nothing -> pure unit
      Just y -> do
        let january = monthTopology y January MondayStart
        january.days `shouldEqual` 31
        january.leadingCells `shouldEqual` 4
        january.naturalRows `shouldEqual` 5
        let february = monthTopology y February MondayStart
        february.days `shouldEqual` 28
        february.firstWeekday `shouldEqual` Monday
        february.lastWeekday `shouldEqual` Sunday
        february.naturalRows `shouldEqual` 4
  it "passes exhaustive 1900–2100 checks for every month and week origin" do
    let
      validYears = Array.all
        ( \number -> case year number of
            Nothing -> false
            Just y -> Array.null (validateYear y)
        )
        (Array.range 1900 2100)
    validYears `shouldEqual` true
