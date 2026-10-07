module Test.Civil (spec) where

import Prelude
import Data.Maybe (Maybe(..), isJust)
import Test.Spec (Spec, describe, it)
import Test.Spec.Assertions (shouldEqual)
import BetaCalendars.GridAlgebra.Civil (Month(..), civilDate, daysInMonth, isLeapYear, nextDate, previousDate, weekdayOf, year)
import BetaCalendars.GridAlgebra.WeekStart (Weekday(..))

spec :: Spec Unit
spec = describe "civil Gregorian dates" do
  it "applies century and 400-year leap rules" do
    map isLeapYear (year 1900) `shouldEqual` Just false
    map isLeapYear (year 2000) `shouldEqual` Just true
    map isLeapYear (year 2024) `shouldEqual` Just true
    map isLeapYear (year 2027) `shouldEqual` Just false
    map isLeapYear (year 2100) `shouldEqual` Just false
    map isLeapYear (year 2400) `shouldEqual` Just true
  it "rejects years and dates outside the supported range" do
    year 0 `shouldEqual` Nothing
    year 10000 `shouldEqual` Nothing
    (year 2027 >>= \y -> civilDate y February 29) `shouldEqual` Nothing
    isJust (year 2024 >>= \y -> civilDate y February 29) `shouldEqual` true
  it "steps across month, leap-day, year, and supported-range boundaries" do
    let feb28 = year 2024 >>= \y -> civilDate y February 28
    let feb29 = year 2024 >>= \y -> civilDate y February 29
    let march1 = year 2024 >>= \y -> civilDate y March 1
    (feb28 >>= nextDate) `shouldEqual` feb29
    (feb29 >>= nextDate) `shouldEqual` march1
    (march1 >>= previousDate) `shouldEqual` feb29
    (year 2026 >>= \y -> civilDate y December 31 >>= nextDate) `shouldEqual` (year 2027 >>= \y -> civilDate y January 1)
    (year 1 >>= \y -> civilDate y January 1 >>= previousDate) `shouldEqual` Nothing
    (year 9999 >>= \y -> civilDate y December 31 >>= nextDate) `shouldEqual` Nothing
  it "computes known weekdays without timezone semantics" do
    map weekdayOf (year 2027 >>= \y -> civilDate y January 1) `shouldEqual` Just Friday
    map weekdayOf (year 2024 >>= \y -> civilDate y February 29) `shouldEqual` Just Thursday
  it "returns February lengths at leap and non-leap boundaries" do
    map (\y -> daysInMonth y February) (year 2024) `shouldEqual` Just 29
    map (\y -> daysInMonth y February) (year 2027) `shouldEqual` Just 28
