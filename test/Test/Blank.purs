module Test.Blank (spec) where

import Prelude
import Data.Array as Array
import Data.Either (Either(..))
import Data.Maybe (Maybe(..))
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import BetaCalendars.GridAlgebra.Blank (blankGrid)
import BetaCalendars.GridAlgebra.Paper (LayoutError(..))

spec :: Spec Unit
spec = describe "undated blank surfaces" do
  it "constructs 5×7, 6×7, and custom rectangular grids" do
    case blankGrid 5 7 of
      Left issue -> issue `shouldEqual` InvalidGridShape
      Right grid -> do
        Array.length grid.cells `shouldEqual` 35
        Array.index grid.cells 0 `shouldEqual` Just { row: 0, column: 0 }
    case blankGrid 6 7 of
      Left issue -> issue `shouldEqual` InvalidGridShape
      Right grid -> Array.length grid.cells `shouldEqual` 42
    case blankGrid 8 4 of
      Left issue -> issue `shouldEqual` InvalidGridShape
      Right grid -> Array.length grid.cells `shouldEqual` 32
  it "rejects zero and negative dimensions" do
    case blankGrid 0 7 of
      Left issue -> issue `shouldEqual` InvalidGridShape
      Right _ -> pure unit
    case blankGrid 7 (-1) of
      Left issue -> issue `shouldEqual` InvalidGridShape
      Right _ -> pure unit
