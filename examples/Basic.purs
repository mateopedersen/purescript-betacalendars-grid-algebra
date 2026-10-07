module Examples.Basic where

import Data.Maybe (Maybe)
import BetaCalendars.GridAlgebra.Civil (Month(..), year)
import BetaCalendars.GridAlgebra.Grid (AdjacentPolicy(..), GridMode(..), MonthGrid, monthGrid)
import BetaCalendars.GridAlgebra.WeekStart (WeekStart(..))

january2027 :: Maybe MonthGrid
january2027 = do
  y <- year 2027
  pure (monthGrid y January MondayStart NaturalRows EmptyAdjacent)
