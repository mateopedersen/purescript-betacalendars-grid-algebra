-- | Bounded Gregorian civil-date arithmetic with no timestamps or time zones.
-- |
-- | Years are restricted to 1 through 9999. Constructors keep dates valid,
-- | while stepping past that supported boundary returns `Nothing`.
module BetaCalendars.GridAlgebra.Civil
  ( Year
  , year
  , yearValue
  , Month(..)
  , allMonths
  , monthNumber
  , monthFromNumber
  , DayOfMonth
  , dayOfMonthValue
  , CivilDate
  , civilDate
  , dateYear
  , dateMonth
  , dateDay
  , isLeapYear
  , daysInMonth
  , firstDateOfMonth
  , lastDateOfMonth
  , nextDate
  , previousDate
  , weekdayOf
  ) where

import Prelude
import Data.Array as Array
import Data.Foldable (foldl)
import Data.Maybe (Maybe(..))
import BetaCalendars.GridAlgebra.WeekStart (Weekday(..))

-- | A supported positive Gregorian year.
newtype Year = Year Int

derive newtype instance eqYear :: Eq Year
derive newtype instance ordYear :: Ord Year
derive newtype instance showYear :: Show Year

-- | Construct a supported Gregorian year.
year :: Int -> Maybe Year
year value = if value >= 1 && value <= 9999 then Just (Year value) else Nothing

-- | The numeric Gregorian year.
yearValue :: Year -> Int
yearValue (Year value) = value

-- | Gregorian month names in calendar order.
data Month
  = January
  | February
  | March
  | April
  | May
  | June
  | July
  | August
  | September
  | October
  | November
  | December

derive instance eqMonth :: Eq Month
derive instance ordMonth :: Ord Month

instance showMonth :: Show Month where
  show = case _ of
    January -> "January"
    February -> "February"
    March -> "March"
    April -> "April"
    May -> "May"
    June -> "June"
    July -> "July"
    August -> "August"
    September -> "September"
    October -> "October"
    November -> "November"
    December -> "December"

-- | The twelve months in calendar order.
allMonths :: Array Month
allMonths =
  [ January
  , February
  , March
  , April
  , May
  , June
  , July
  , August
  , September
  , October
  , November
  , December
  ]

-- | One-based month number.
monthNumber :: Month -> Int
monthNumber = case _ of
  January -> 1
  February -> 2
  March -> 3
  April -> 4
  May -> 5
  June -> 6
  July -> 7
  August -> 8
  September -> 9
  October -> 10
  November -> 11
  December -> 12

-- | Convert a one-based month number into its Gregorian month.
monthFromNumber :: Int -> Maybe Month
monthFromNumber = case _ of
  1 -> Just January
  2 -> Just February
  3 -> Just March
  4 -> Just April
  5 -> Just May
  6 -> Just June
  7 -> Just July
  8 -> Just August
  9 -> Just September
  10 -> Just October
  11 -> Just November
  12 -> Just December
  _ -> Nothing

-- | A one-based day number that can be validated against a specific month.
newtype DayOfMonth = DayOfMonth Int

derive newtype instance eqDayOfMonth :: Eq DayOfMonth
derive newtype instance ordDayOfMonth :: Ord DayOfMonth
derive newtype instance showDayOfMonth :: Show DayOfMonth

-- | The numeric day of month.
dayOfMonthValue :: DayOfMonth -> Int
dayOfMonthValue (DayOfMonth value) = value

-- | A validated Gregorian civil date.
newtype CivilDate = CivilDate
  { year :: Year
  , month :: Month
  , day :: DayOfMonth
  }

derive newtype instance eqCivilDate :: Eq CivilDate
derive newtype instance ordCivilDate :: Ord CivilDate
derive newtype instance showCivilDate :: Show CivilDate

-- | Construct a valid date, returning `Nothing` for an impossible day.
civilDate :: Year -> Month -> Int -> Maybe CivilDate
civilDate y m day =
  if day >= 1 && day <= daysInMonth y m then
    Just (CivilDate { year: y, month: m, day: DayOfMonth day })
  else
    Nothing

-- | The year component of a date.
dateYear :: CivilDate -> Year
dateYear (CivilDate value) = value.year

-- | The month component of a date.
dateMonth :: CivilDate -> Month
dateMonth (CivilDate value) = value.month

-- | The day component of a date.
dateDay :: CivilDate -> DayOfMonth
dateDay (CivilDate value) = value.day

-- | Gregorian leap-year rule, including century and 400-year exceptions.
isLeapYear :: Year -> Boolean
isLeapYear (Year value) =
  mod value 400 == 0 || (mod value 4 == 0 && mod value 100 /= 0)

-- | Number of days in a Gregorian month.
daysInMonth :: Year -> Month -> Int
daysInMonth y = case _ of
  January -> 31
  February -> if isLeapYear y then 29 else 28
  March -> 31
  April -> 30
  May -> 31
  June -> 30
  July -> 31
  August -> 31
  September -> 30
  October -> 31
  November -> 30
  December -> 31

-- | The first day of a month.
firstDateOfMonth :: Year -> Month -> CivilDate
firstDateOfMonth y m = CivilDate { year: y, month: m, day: DayOfMonth 1 }

-- | The last day of a month.
lastDateOfMonth :: Year -> Month -> CivilDate
lastDateOfMonth y m = CivilDate { year: y, month: m, day: DayOfMonth (daysInMonth y m) }

-- | Advance one civil day; returns `Nothing` after 9999-12-31.
nextDate :: CivilDate -> Maybe CivilDate
nextDate (CivilDate value) =
  let
    day = dayOfMonthValue value.day
    total = daysInMonth value.year value.month
  in
    if day < total then
      civilDate value.year value.month (day + 1)
    else if value.month /= December then
      case monthFromNumber (monthNumber value.month + 1) of
        Nothing -> Nothing
        Just nextMonth -> civilDate value.year nextMonth 1
    else
      case year (yearValue value.year + 1) of
        Nothing -> Nothing
        Just nextYear -> civilDate nextYear January 1

-- | Move one civil day backward; returns `Nothing` before 0001-01-01.
previousDate :: CivilDate -> Maybe CivilDate
previousDate (CivilDate value) =
  let
    day = dayOfMonthValue value.day
  in
    if day > 1 then
      civilDate value.year value.month (day - 1)
    else if value.month /= January then
      case monthFromNumber (monthNumber value.month - 1) of
        Nothing -> Nothing
        Just previousMonth -> Just (lastDateOfMonth value.year previousMonth)
    else
      case year (yearValue value.year - 1) of
        Nothing -> Nothing
        Just previousYear -> Just (lastDateOfMonth previousYear December)

-- | Weekday of a civil date in the proleptic Gregorian calendar.
weekdayOf :: CivilDate -> Weekday
weekdayOf (CivilDate value) =
  let
    priorYear = yearValue value.year - 1
    leapDays = div priorYear 4 - div priorYear 100 + div priorYear 400
    yearDays = priorYear * 365 + leapDays
    beforeMonth = daysBeforeMonth value.year value.month
    ordinal = yearDays + beforeMonth + dayOfMonthValue value.day - 1
  in
    case mod ordinal 7 of
      0 -> Monday
      1 -> Tuesday
      2 -> Wednesday
      3 -> Thursday
      4 -> Friday
      5 -> Saturday
      _ -> Sunday

daysBeforeMonth :: Year -> Month -> Int
daysBeforeMonth y target = foldl (\total month -> total + daysInMonth y month) 0 (Array.takeWhile (_ /= target) allMonths)
