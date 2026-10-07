-- | Nominal paper dimensions and checked printable-grid geometry.
-- |
-- | All measurements use millimeters. The output describes a geometric model
-- | with explicit reserved areas; it does not claim to measure a printer or
-- | a person's writing experience.
-- | Project context: [Beta Calendars](https://www.betacalendars.com/).
-- | Example references: [blank](https://www.betacalendars.com/blank-calendar),
-- | [January](https://www.betacalendars.com/january-calendar.html),
-- | [April](https://www.betacalendars.com/april-calendar.html),
-- | [July](https://www.betacalendars.com/july-calendar.html), and
-- | [October](https://www.betacalendars.com/october-calendar.html).
module BetaCalendars.GridAlgebra.Paper
  ( Millimeters
  , millimeters
  , millimeterValue
  , PaperSize(..)
  , Orientation(..)
  , Margins
  , LayoutSpec
  , LayoutMetrics
  , LayoutError(..)
  , paperDimensions
  , layoutMetrics
  , defaultMargins
  ) where

import Prelude
import Data.Either (Either(..))
import Data.Int as Int
import Data.Maybe (Maybe(..))

-- | A non-negative, finite millimeter measurement.
newtype Millimeters = Millimeters Number

derive newtype instance eqMillimeters :: Eq Millimeters
derive newtype instance ordMillimeters :: Ord Millimeters
derive newtype instance showMillimeters :: Show Millimeters

-- | Construct a non-negative finite millimeter value.
millimeters :: Number -> Maybe Millimeters
millimeters value =
  if value >= 0.0 && value < 1.0e300 then Just (Millimeters value) else Nothing

-- | Read the numeric millimeter measurement.
millimeterValue :: Millimeters -> Number
millimeterValue (Millimeters value) = value

-- | Standard ISO and US paper formats, or a custom width and height.
data PaperSize
  = A4
  | A5
  | Letter
  | Legal
  | CustomPaper Millimeters Millimeters

derive instance eqPaperSize :: Eq PaperSize

-- | Page orientation.
data Orientation = Portrait | Landscape

derive instance eqOrientation :: Eq Orientation

-- | Four non-negative page margins.
type Margins =
  { top :: Millimeters
  , right :: Millimeters
  , bottom :: Millimeters
  , left :: Millimeters
  }

-- | Input parameters for a printable grid model.
type LayoutSpec =
  { paper :: PaperSize
  , orientation :: Orientation
  , margins :: Margins
  , titleHeight :: Millimeters
  , weekdayHeaderHeight :: Millimeters
  , notesHeight :: Millimeters
  , rows :: Int
  , columns :: Int
  }

-- | Derived page and cell geometry.
type LayoutMetrics =
  { pageWidth :: Millimeters
  , pageHeight :: Millimeters
  , printableWidth :: Millimeters
  , printableHeight :: Millimeters
  , gridWidth :: Millimeters
  , gridHeight :: Millimeters
  , cellWidth :: Millimeters
  , cellHeight :: Millimeters
  , cellArea :: Number
  , writingArea :: Number
  }

-- | Failures that prevent a physically meaningful grid calculation.
data LayoutError
  = InvalidMargins
  | InvalidGridShape
  | ReservedAreaOverflow
  | NonPositiveCellGeometry

derive instance eqLayoutError :: Eq LayoutError

instance showLayoutError :: Show LayoutError where
  show = case _ of
    InvalidMargins -> "InvalidMargins"
    InvalidGridShape -> "InvalidGridShape"
    ReservedAreaOverflow -> "ReservedAreaOverflow"
    NonPositiveCellGeometry -> "NonPositiveCellGeometry"

-- | Dimensions in the requested orientation. Letter and Legal are the US
-- | nominal dimensions in millimeters.
paperDimensions :: PaperSize -> Orientation -> { width :: Number, height :: Number }
paperDimensions paper orientation =
  let
    base = case paper of
      A4 -> { width: 210.0, height: 297.0 }
      A5 -> { width: 148.0, height: 210.0 }
      Letter -> { width: 215.9, height: 279.4 }
      Legal -> { width: 215.9, height: 355.6 }
      CustomPaper width height -> { width: millimeterValue width, height: millimeterValue height }
  in
    case orientation of
      Portrait -> base
      Landscape -> { width: base.height, height: base.width }

-- | Calculate layout geometry after validating all reserved areas and shape.
layoutMetrics :: LayoutSpec -> Either LayoutError LayoutMetrics
layoutMetrics spec =
  let
    page = paperDimensions spec.paper spec.orientation
    margins = spec.margins
    top = millimeterValue margins.top
    right = millimeterValue margins.right
    bottom = millimeterValue margins.bottom
    left = millimeterValue margins.left
    reserved = millimeterValue spec.titleHeight + millimeterValue spec.weekdayHeaderHeight + millimeterValue spec.notesHeight
    printableWidth = page.width - left - right
    printableHeight = page.height - top - bottom - reserved
  in
    if spec.rows <= 0 || spec.columns <= 0 then Left InvalidGridShape
    else if top < 0.0 || right < 0.0 || bottom < 0.0 || left < 0.0 then Left InvalidMargins
    else if printableWidth <= 0.0 || printableHeight <= 0.0 then Left ReservedAreaOverflow
    else
      let
        cellWidth = printableWidth / Int.toNumber spec.columns
        cellHeight = printableHeight / Int.toNumber spec.rows
        cellArea = cellWidth * cellHeight
      in
        if cellWidth <= 0.0 || cellHeight <= 0.0 || cellArea <= 0.0 then Left NonPositiveCellGeometry
        else Right
          { pageWidth: Millimeters page.width
          , pageHeight: Millimeters page.height
          , printableWidth: Millimeters printableWidth
          , printableHeight: Millimeters printableHeight
          , gridWidth: Millimeters printableWidth
          , gridHeight: Millimeters printableHeight
          , cellWidth: Millimeters cellWidth
          , cellHeight: Millimeters cellHeight
          , cellArea
          , writingArea: cellArea * Int.toNumber spec.rows * Int.toNumber spec.columns
          }

-- | Common model margins used in examples: 10 mm on each side.
defaultMargins :: Margins
defaultMargins =
  { top: Millimeters 10.0
  , right: Millimeters 10.0
  , bottom: Millimeters 10.0
  , left: Millimeters 10.0
  }
