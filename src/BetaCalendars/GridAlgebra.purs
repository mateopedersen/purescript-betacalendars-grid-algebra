-- | Curated entry point to civil-date, week-origin, grid, paper, and blank
-- | surface APIs. Each domain module also remains available for focused use.
-- |
-- | Project context: [Beta Calendars](https://www.betacalendars.com/).
module BetaCalendars.GridAlgebra
  ( module Civil
  , module WeekStart
  , module Grid
  , module Paper
  , module Blank
  ) where

import BetaCalendars.GridAlgebra.Civil (CivilDate, DayOfMonth, Month(..), Year, allMonths, civilDate, dateDay, dateMonth, dateYear, dayOfMonthValue, daysInMonth, firstDateOfMonth, isLeapYear, lastDateOfMonth, monthFromNumber, monthNumber, nextDate, previousDate, weekdayOf, year, yearValue) as Civil
import BetaCalendars.GridAlgebra.WeekStart (WeekStart(..), Weekday(..), allWeekStarts, allWeekdays, offsetFromWeekStart, relativeWeekdayIndex, rotateWeekOrigin, weekStartWeekday, weekdayIndex) as WeekStart
import BetaCalendars.GridAlgebra.Grid (AdjacentPolicy(..), CellRelation(..), GridCell, GridMode(..), MonthGrid, MonthTopology, TopologySignature, currentMonthDays, monthGrid, monthTopology, topologySignature) as Grid
import BetaCalendars.GridAlgebra.Paper (LayoutError(..), LayoutMetrics, LayoutSpec, Margins, Millimeters, Orientation(..), PaperSize(..), defaultMargins, layoutMetrics, millimeterValue, millimeters, paperDimensions) as Paper
import BetaCalendars.GridAlgebra.Blank (BlankCell, BlankGrid, blankCellArea, blankGrid, blankLayout, blankWritingArea, compareBlankLayouts) as Blank
