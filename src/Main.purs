module Main where

import Prelude (Unit)
import App (Action, State, WINDOW, start) as App
import DOM (DOM)
import Signal.Channel (CHANNEL)
import Network.HTTP.Affjax (AJAX)
import Data.Foreign (Foreign)
import Data.Foreign.Class (read)
import Control.Monad.ST (ST)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Timer (TIMER)
import Control.Monad.Eff.Console (CONSOLE)
import Control.Monad.Eff.Exception (EXCEPTION)

-- The main function can have the start state optionally passed into it for hot module reloading
main
 ∷ ∀ effects
 . Foreign
 → Eff ( window ∷ App.WINDOW
       , st ∷ ST { action ∷ App.Action, state ∷ App.State }
       , ajax ∷ AJAX
       , err ∷ EXCEPTION
       , console ∷ CONSOLE
       , dom ∷ DOM
       , channel ∷ CHANNEL
       , timer ∷ TIMER
       | effects
       ) Unit
main startState = App.start (read startState)
