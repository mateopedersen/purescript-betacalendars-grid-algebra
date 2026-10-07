-- | Weekday and week-origin algebra for Gregorian calendar layouts.
-- |
-- | Weekday indices use Monday = 0 through Sunday = 6. A week origin only
-- | changes presentation order; it never changes the civil date itself.
module BetaCalendars.GridAlgebra.WeekStart
  ( Weekday(..)
  , WeekStart(..)
  , allWeekdays
  , allWeekStarts
  , weekdayIndex
  , weekStartWeekday
  , relativeWeekdayIndex
  , rotateWeekOrigin
  , offsetFromWeekStart
  ) where

import Prelude

-- | A Gregorian weekday, indexed from Monday.
data Weekday
  = Monday
  | Tuesday
  | Wednesday
  | Thursday
  | Friday
  | Saturday
  | Sunday

derive instance eqWeekday :: Eq Weekday
derive instance ordWeekday :: Ord Weekday

instance showWeekday :: Show Weekday where
  show = case _ of
    Monday -> "Monday"
    Tuesday -> "Tuesday"
    Wednesday -> "Wednesday"
    Thursday -> "Thursday"
    Friday -> "Friday"
    Saturday -> "Saturday"
    Sunday -> "Sunday"

-- | The weekday shown in the first column of a calendar grid.
data WeekStart
  = MondayStart
  | TuesdayStart
  | WednesdayStart
  | ThursdayStart
  | FridayStart
  | SaturdayStart
  | SundayStart

derive instance eqWeekStart :: Eq WeekStart
derive instance ordWeekStart :: Ord WeekStart

instance showWeekStart :: Show WeekStart where
  show = case _ of
    MondayStart -> "MondayStart"
    TuesdayStart -> "TuesdayStart"
    WednesdayStart -> "WednesdayStart"
    ThursdayStart -> "ThursdayStart"
    FridayStart -> "FridayStart"
    SaturdayStart -> "SaturdayStart"
    SundayStart -> "SundayStart"

-- | Every weekday in Monday-first index order.
allWeekdays :: Array Weekday
allWeekdays = [ Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday ]

-- | Every supported week origin in weekday order.
allWeekStarts :: Array WeekStart
allWeekStarts =
  [ MondayStart
  , TuesdayStart
  , WednesdayStart
  , ThursdayStart
  , FridayStart
  , SaturdayStart
  , SundayStart
  ]

-- | Monday is 0, Tuesday is 1, and Sunday is 6.
weekdayIndex :: Weekday -> Int
weekdayIndex = case _ of
  Monday -> 0
  Tuesday -> 1
  Wednesday -> 2
  Thursday -> 3
  Friday -> 4
  Saturday -> 5
  Sunday -> 6

-- | The weekday corresponding to a week-start setting.
weekStartWeekday :: WeekStart -> Weekday
weekStartWeekday = case _ of
  MondayStart -> Monday
  TuesdayStart -> Tuesday
  WednesdayStart -> Wednesday
  ThursdayStart -> Thursday
  FridayStart -> Friday
  SaturdayStart -> Saturday
  SundayStart -> Sunday

-- | The zero-based column of a weekday under the supplied week origin.
relativeWeekdayIndex :: WeekStart -> Weekday -> Int
relativeWeekdayIndex start day = mod (weekdayIndex day - weekdayIndex (weekStartWeekday start)) 7

-- | Rotate a week origin by an arbitrary number of days, wrapping every seven.
rotateWeekOrigin :: WeekStart -> Int -> Weekday
rotateWeekOrigin start amount =
  let
    index = mod (weekdayIndex (weekStartWeekday start) + amount) 7
  in
    case index of
      0 -> Monday
      1 -> Tuesday
      2 -> Wednesday
      3 -> Thursday
      4 -> Friday
      5 -> Saturday
      _ -> Sunday

-- | Number of leading grid cells before the first day of a month.
offsetFromWeekStart :: WeekStart -> Weekday -> Int
offsetFromWeekStart = relativeWeekdayIndex
