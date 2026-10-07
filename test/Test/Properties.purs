module Test.Properties (spec) where

import Prelude
import Data.Array as Array
import Data.Maybe (Maybe(..))
import Effect.Class (liftEffect)
import Test.QuickCheck (quickCheckWithSeed, mkSeed)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import BetaCalendars.GridAlgebra.Civil (allMonths, monthFromNumber, year)
import BetaCalendars.GridAlgebra.Grid (AdjacentPolicy(..), GridMode(..), monthGrid)
import BetaCalendars.GridAlgebra.WeekStart (WeekStart(..))

spec :: Spec Unit
spec = describe "property-style topology checks" do
  it "keeps fixed month surfaces at 42 cells over generated year/month pairs" do
    liftEffect $ quickCheckWithSeed (mkSeed 20271007) 250 \sample ->
      let
        yearNumber = 1 + mod sample 9999
        monthNumberValue = 1 + mod (div sample 9999) 12
      in
        case year yearNumber, monthFromNumber monthNumberValue of
          Just y, Just month -> Array.length (monthGrid y month SundayStart FixedSixWeeks EmptyAdjacent).cells == 42
          _, _ -> false
  it "covers all twelve months as Gregorian values" do
    Array.length allMonths `shouldEqual` 12
