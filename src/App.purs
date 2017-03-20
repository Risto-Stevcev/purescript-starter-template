module App where

import Prelude (($), (<$>), (>>=), (>>>), bind, id, map, pure, const, show, unit, Unit)
import CounterList as CounterList
import Router as Router
import Routing.Hash (setHash)
import Text.Smolder.HTML (button, div, span, hr)
import Text.Smolder.Markup (Markup, (#!), text, on)
import Text.Smolder.Renderer.VDOM (render)
import Signal (sampleOn, runSignal, (~>), foldp, Signal)
import Signal.DOM (animationFrame)
import Signal.Channel (send, subscribe, channel) as Channel
import Signal.Channel (CHANNEL, Channel)
import DOM (DOM)
import DOM.Node.Types (elementToNode, Node)
import DOM.Node.ParentNode (querySelector)
import DOM.HTML (window)
import DOM.HTML.Types (htmlDocumentToParentNode)
import DOM.HTML.Window (document)
import DOM.Event.Types (Event)
import Data.Show (class Show)
import Data.Tuple (Tuple(..))
import Data.Maybe (Maybe(..), maybe)
import Data.Either (either)
import Data.Nullable (toMaybe)
import Data.Foreign (F, Foreign, writeObject)
import Data.Foreign.Class (class IsForeign, class AsForeign, readProp, write, writeProp)
import Data.VirtualDOM (patch)
import Data.VirtualDOM.DOM (api)
import Control.Alt ((<|>))
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Timer (TIMER)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Except (runExcept)

data State = CounterListState CounterList.State | AjaxState Int
data Action = CounterListPage CounterList.Action | AjaxPage Unit

-- | The app state needs to be serializable so that we can inject it back on a hot module reload
-- | Otherwise it will reference stale constructors that are not the same object references as the reloaded ones
instance isForeignState ∷ IsForeign State where
  read v =  (CounterListState <$> (readProp "CounterListState" v ∷ F CounterList.State))
        <|> (AjaxState        <$> (readProp "AjaxState" v ∷ F Int))

instance asForeignState ∷ AsForeign State where
  write (CounterListState a) = writeObject [(writeProp "CounterListState" (write a))]
  write (AjaxState a) = writeObject [(writeProp "AjaxState" (write a))]

instance showState ∷ Show State where
  show (CounterListState a) = show a
  show (AjaxState i) = show i


initialState ∷ State
initialState = CounterListState CounterList.initialState


view ∷ ∀ e. Channel Action → State → Markup (Event → Eff (dom ∷ DOM, channel ∷ CHANNEL | e) Unit)
view channel state = div do
  div do
    button #! on "click" (const (setHash "counterlist")) $ text "Counter List"
    button #! on "click" (const (setHash "ajax")) $ text "Ajax Example"

  hr

  div $ case state of
    CounterListState state' → CounterList.view CounterListPage channel state'
    AjaxState state' → span $ text "Ajax page is a stub"


update ∷ Action → State → State
update (CounterListPage action) (CounterListState state) = CounterListState $ CounterList.update action state
update (CounterListPage action) _ = CounterListState CounterList.initialState
update (AjaxPage _) _ = AjaxState 0


changePage ∷ ∀ e. Channel Action → Router.Location → Eff (console ∷ CONSOLE, channel ∷ CHANNEL | e) Unit
changePage channel Router.Home = Channel.send channel (AjaxPage unit)
changePage channel Router.CounterListPage = Channel.send channel (CounterListPage CounterList.Noop)
changePage channel Router.AjaxPage = Channel.send channel (AjaxPage unit)


app ∷ ∀ e. Signal State → Channel Action → Node → Eff (dom ∷ DOM, channel ∷ CHANNEL, timer ∷ TIMER | e) Unit
app stateSignal channel target = do
  tickSignal ← animationFrame
  runSignal $ (input (sampleOn tickSignal stateSignal)) ~> write

  where
    input state = foldp go (Tuple Nothing Nothing) state
    go state (Tuple _ prev) = Tuple prev (render $ view channel state)
    write (Tuple prev next) = patch api target prev next


-- This captures the current state of the app so that we can inject it back on hot module reload
foreign import _captureState ∷ Foreign → Unit 
captureState ∷ ∀ a. (AsForeign a) ⇒ a → a
captureState a = const a $ _captureState (write a)


start ∷ ∀ e. F State → Eff (console ∷ CONSOLE, dom ∷ DOM, channel ∷ CHANNEL, timer ∷ TIMER | e) Unit
start state = do
  doc ← window >>= document >>= htmlDocumentToParentNode >>> pure
  targetElem ← querySelector "#content" doc >>= toMaybe >>> map elementToNode >>> pure

  channel ← Channel.channel (CounterListPage CounterList.Noop)

  let startState = either (const initialState) id $ runExcept state
  let stateSignal = foldp (\a s → captureState $ update a s) startState $ Channel.subscribe channel

  maybe (log "No div#content found!") (app stateSignal channel) targetElem

  Router.runRoutes (changePage channel)
