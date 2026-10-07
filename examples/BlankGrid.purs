module Examples.BlankGrid where

import Data.Either (Either)
import BetaCalendars.GridAlgebra.Blank (BlankGrid, blankGrid)
import BetaCalendars.GridAlgebra.Paper (LayoutError)

weeklyPlannerSurface :: Either LayoutError BlankGrid
weeklyPlannerSurface = blankGrid 5 7
