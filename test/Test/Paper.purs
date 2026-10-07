module Test.Paper (spec) where

import Prelude
import Data.Either (Either(..))
import Data.Maybe (fromMaybe)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual, shouldSatisfy)
import BetaCalendars.GridAlgebra.Paper (LayoutError(..), LayoutSpec, Orientation(..), PaperSize(..), defaultMargins, layoutMetrics, millimeters, paperDimensions)

spec :: Spec Unit
spec = describe "printable paper geometry" do
  it "uses exact standard paper dimensions and orientations" do
    paperDimensions A4 Portrait `shouldEqual` { width: 210.0, height: 297.0 }
    paperDimensions A5 Portrait `shouldEqual` { width: 148.0, height: 210.0 }
    paperDimensions Letter Portrait `shouldEqual` { width: 215.9, height: 279.4 }
    paperDimensions Legal Portrait `shouldEqual` { width: 215.9, height: 355.6 }
    paperDimensions Letter Landscape `shouldEqual` { width: 279.4, height: 215.9 }
  it "calculates positive A4 and Letter six-week geometry" do
    case layoutMetrics (layoutSpec A4) of
      Left issue -> issue `shouldEqual` ReservedAreaOverflow
      Right metrics -> do
        metrics.pageWidth `shouldEqual` fromMaybe defaultMargins.left (millimeters 210.0)
        metrics.cellArea `shouldSatisfy` (_ > 0.0)
        metrics.writingArea `shouldSatisfy` (_ > 0.0)
    case layoutMetrics (layoutSpec Letter) of
      Left issue -> issue `shouldEqual` ReservedAreaOverflow
      Right metrics -> metrics.cellArea `shouldSatisfy` (_ > 0.0)
  it "rejects invalid grid dimensions and reserved-area overflow" do
    case layoutMetrics ((layoutSpec A4) { rows = 0 }) of
      Left issue -> issue `shouldEqual` InvalidGridShape
      Right _ -> pure unit
    case layoutMetrics ((layoutSpec A4) { titleHeight = fromMaybe defaultMargins.top (millimeters 999.0) }) of
      Left issue -> issue `shouldEqual` ReservedAreaOverflow
      Right _ -> pure unit

layoutSpec :: PaperSize -> LayoutSpec
layoutSpec paper =
  { paper
  , orientation: Portrait
  , margins: defaultMargins
  , titleHeight: fromMaybe defaultMargins.top (millimeters 15.0)
  , weekdayHeaderHeight: fromMaybe defaultMargins.top (millimeters 8.0)
  , notesHeight: fromMaybe defaultMargins.top (millimeters 20.0)
  , rows: 6
  , columns: 7
  }
