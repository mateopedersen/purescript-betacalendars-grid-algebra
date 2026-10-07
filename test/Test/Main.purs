module Test.Main where

import Prelude
import Effect (Effect)
import Test.Spec.Reporter (consoleReporter)
import Test.Spec.Runner.Node (runSpecAndExitProcess)
import Test.Civil as Civil
import Test.Grid as Grid
import Test.Paper as Paper
import Test.Blank as Blank
import Test.Year2027 as Year2027
import Test.Boundary2027 as Boundary2027
import Test.Properties as Properties

main :: Effect Unit
main = runSpecAndExitProcess [ consoleReporter ] do
  Civil.spec
  Grid.spec
  Paper.spec
  Blank.spec
  Year2027.spec
  Boundary2027.spec
  Properties.spec
