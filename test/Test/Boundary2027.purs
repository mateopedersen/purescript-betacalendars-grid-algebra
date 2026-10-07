module Test.Boundary2027 (spec) where

import Prelude
import Data.Array as Array
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import BetaCalendars.GridAlgebra.Boundary2027 (boundary2027, boundaryRegressionValid)
import BetaCalendars.GridAlgebra.Civil (Month(..))
import BetaCalendars.GridAlgebra.WeekStart (WeekStart(..))

spec :: Spec Unit
spec = describe "November 2026 through February 2027 regression" do
  it "keeps the four-month boundary window and month lengths" do
    map _.month (boundary2027 MondayStart) `shouldEqual` [ November, December, January, February ]
    map _.days (boundary2027 MondayStart) `shouldEqual` [ 30, 31, 31, 28 ]
  it "validates the year rollover and non-leap February" do
    boundaryRegressionValid `shouldEqual` true
    Array.length (boundary2027 MondayStart) `shouldEqual` 4
