module Test.Year2027 (spec) where

import Prelude
import Data.Array as Array
import Data.Foldable (sum)
import Data.Maybe (Maybe(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import BetaCalendars.GridAlgebra.Civil (Month(..))
import BetaCalendars.GridAlgebra.Year2027 (fixedGridOccupancy2027, mondayFirst2027, monthTopologies2027, sundayFirst2027)
import BetaCalendars.GridAlgebra.WeekStart (WeekStart(..), allWeekStarts)

spec :: Spec Unit
spec = describe "computed 2027 fixtures" do
  it "contains all twelve months and totals 365 days" do
    Array.length mondayFirst2027 `shouldEqual` 12
    sum (map (\entry -> entry.topology.days) mondayFirst2027) `shouldEqual` 365
    map (\entry -> entry.topology.days) (Array.find (\entry -> entry.month == February) mondayFirst2027) `shouldEqual` Just 28
    map (\entry -> show entry.topology.firstWeekday) mondayFirst2027 `shouldEqual`
      [ "Friday"
      , "Monday"
      , "Monday"
      , "Thursday"
      , "Saturday"
      , "Tuesday"
      , "Thursday"
      , "Sunday"
      , "Wednesday"
      , "Friday"
      , "Monday"
      , "Wednesday"
      ]
    map (\entry -> entry.topology.leadingCells) mondayFirst2027 `shouldEqual`
      [ 4, 0, 0, 3, 5, 1, 3, 6, 2, 4, 0, 2 ]
    map (\entry -> entry.topology.naturalRows) mondayFirst2027 `shouldEqual`
      [ 5, 4, 5, 5, 6, 5, 5, 6, 5, 5, 5, 5 ]
  it "derives values for every week origin and fixed-grid occupancy" do
    Array.length (monthTopologies2027 MondayStart) `shouldEqual` 12
    Array.length sundayFirst2027 `shouldEqual` 12
    Array.all (\start -> Array.length (fixedGridOccupancy2027 start) == 12) allWeekStarts `shouldEqual` true
    Array.all (\entry -> entry.currentMonthCells + entry.leadingCells + entry.remainingCells == 42)
      (fixedGridOccupancy2027 SundayStart) `shouldEqual` true
