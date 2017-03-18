module Main where

import Prelude (($), (>>=), (>>>), bind, map, pure, Unit)
import CounterList as CounterList
import Data.Maybe (Maybe(Nothing), maybe)
import Data.Tuple (Tuple(Tuple))
import Data.Nullable (toMaybe)
import Data.VirtualDOM (patch)
import Data.VirtualDOM.DOM (api)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Timer (TIMER)
import DOM (DOM)
import DOM.HTML (window)
import DOM.HTML.Types (htmlDocumentToParentNode)
import DOM.HTML.Window (document)
import DOM.Node.ParentNode (querySelector)
import DOM.Node.Types (elementToNode, Node)
import Signal (sampleOn, runSignal, (~>), foldp, Signal)
import Signal.Channel (CHANNEL, Channel, subscribe, channel)
import Signal.DOM (animationFrame)
import Text.Smolder.Renderer.VDOM (render)

app ∷ ∀ e. Signal CounterList.State → Channel CounterList.Action → Node
    → Eff (dom ∷ DOM, channel ∷ CHANNEL, timer ∷ TIMER | e) Unit
app stateSignal actions target = do
  tickSignal ← animationFrame
  runSignal $ (input (sampleOn tickSignal stateSignal)) ~> write

  where
    input state = foldp go (Tuple Nothing Nothing) state
    go state (Tuple _ prev) = Tuple prev (render $ CounterList.view actions state)
    write (Tuple prev next) = patch api target prev next

main ∷ ∀ e. Eff (console ∷ CONSOLE, dom ∷ DOM, channel ∷ CHANNEL, timer ∷ TIMER | e) Unit
main = do
  doc ← window >>= document >>= htmlDocumentToParentNode >>> pure
  targetElem ← querySelector "#content" doc >>= toMaybe >>> map elementToNode >>> pure

  actions ← channel CounterList.Noop
  let stateSignal = foldp CounterList.update CounterList.initialState $ subscribe actions

  maybe (log "No div#content found!") (app stateSignal actions) targetElem
