module App where

import Prelude (($), (<$>), (>>=), (>>>), bind, id, map, pure, const, show, unit, Unit)
import CounterList as CounterList
import Ajax as Ajax
import Router as Router
import Routing.Hash (setHash)
import Text.Smolder.HTML (button, div, hr)
import Text.Smolder.Markup (Markup, (#!), text, on)
import Text.Smolder.Renderer.VDOM (render)
import Network.HTTP.Affjax (AJAX, Affjax, get)
import Signal (sampleOn, runSignal, (~>), foldp, Signal)
import Signal.DOM (animationFrame)
import Signal.Channel (send, subscribe, channel) as Channel
import Signal.Channel (CHANNEL, Channel)
import Signal.TimeTravel (initialize) as TimeTravel
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
import Data.Foreign.Undefined (writeUndefined)
import Data.Foreign.Class (class IsForeign, class AsForeign, readProp, write, writeProp)
import Data.VirtualDOM (patch)
import Data.VirtualDOM.DOM (api)
import Control.Alt ((<|>))
import Control.Monad.ST (ST)
import Control.Monad.Aff (launchAff)
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Class (liftEff)
import Control.Monad.Eff.Timer (TIMER)
import Control.Monad.Eff.Console (CONSOLE, log)
import Control.Monad.Eff.Exception (EXCEPTION)
import Control.Monad.Except (runExcept)

data State = CounterListState CounterList.State | AjaxState Ajax.State
data Action = CounterListPage CounterList.Action | AjaxPage Ajax.Action

-- | The app state needs to be serializable so that we can inject it back on a hot module reload
-- | Otherwise it will reference stale constructors that are not the same object references as the reloaded ones
instance isForeignState ∷ IsForeign State where
  read v =  (CounterListState   <$> (readProp "CounterListState" v ∷ F CounterList.State))
        <|> (AjaxState <$> Just <$> (readProp "AjaxState" v ∷ F Ajax.Response))

instance asForeignState ∷ AsForeign State where
  write (CounterListState a) = writeObject [(writeProp "CounterListState" (write a))]
  write (AjaxState (Just a)) = writeObject [(writeProp "AjaxState" (write a))]
  write (AjaxState Nothing) = writeObject [(writeProp "AjaxState" writeUndefined)]

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
    AjaxState state' → Ajax.view AjaxPage channel state'


update ∷ Action → State → State
update (CounterListPage action) (CounterListState state) = CounterListState $ CounterList.update action state
update (CounterListPage action) _ = CounterListState CounterList.initialState
update (AjaxPage action) (AjaxState state) = AjaxState $ Ajax.update action state
update (AjaxPage action) _ = AjaxState Ajax.initialState


changePage ∷ ∀ e. Channel Action → Router.Location
           → Eff (ajax ∷ AJAX, err ∷ EXCEPTION, console ∷ CONSOLE, channel ∷ CHANNEL | e) Unit
changePage channel Router.Home = Channel.send channel (CounterListPage CounterList.Noop)
changePage channel Router.CounterListPage = Channel.send channel (CounterListPage CounterList.Noop)
changePage channel Router.AjaxPage = do
  Channel.send channel (AjaxPage Ajax.Loading)
  launchAff do
    res ← (get "http://localhost:3000/foobar") ∷ ∀ e'. Affjax e' Ajax.Response
    liftEff $ Channel.send channel (AjaxPage (Ajax.GetFoobar res.response))
  pure unit


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


-- | Used to attach the time travel debugger to the window object
foreign import data WINDOW ∷ !
foreign import setWindowProperty ∷ ∀ a effects. String → a → Eff (window ∷ WINDOW | effects) Unit


start
 ∷ ∀ effects
 . F State
 → Eff ( window ∷ WINDOW
       , st ∷ ST { action ∷ Action, state ∷ State }
       , ajax ∷ AJAX
       , err ∷ EXCEPTION
       , console ∷ CONSOLE
       , dom ∷ DOM
       , channel ∷ CHANNEL
       , timer ∷ TIMER
       | effects
       ) Unit
start state = do
  doc ← window >>= document >>= htmlDocumentToParentNode >>> pure
  targetElem ← querySelector "#content" doc >>= toMaybe >>> map elementToNode >>> pure

  channel ← Channel.channel (CounterListPage CounterList.Noop)

  timeTravel ← TimeTravel.initialize channel update
  setWindowProperty "travel" timeTravel

  let startState = either (const initialState) id $ runExcept state
  let stateSignal = foldp (\a s → captureState $ timeTravel.update a s) startState $ Channel.subscribe channel

  maybe (log "No div#content found!") (app stateSignal channel) targetElem

  Router.runRoutes (changePage channel)
