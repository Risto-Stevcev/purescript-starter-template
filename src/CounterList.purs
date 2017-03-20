module CounterList where

import Prelude (($), (*>), (>>>), bind, id, pure, unit, Unit)
import Counter as Counter
import Helpers (send, applyAtIndex)
import DOM.Event.Types (Event)
import Signal.Channel (CHANNEL, Channel)
import Text.Smolder.HTML (button, div, h1)
import Text.Smolder.Markup (Markup, (#!), text, on)
import Data.Maybe (maybe)
import Data.Array (snoc, init, foldl, mapWithIndex)
import Control.Monad.Eff (Eff)

type State = Array Int
data Action = Noop | Reset | AddCounter | RemoveCounter | UpdateCounter Int Counter.Action

initialState ∷ State
initialState = [Counter.initialState]

view ∷ ∀ a e. (Action → a) → Channel a → State → Markup (Event → Eff (channel ∷ CHANNEL | e) Unit)
view toAction channel state = div do
  h1 $ text "Counter List"
  div do
    foldl (*>) (pure unit) (mapWithIndex (\index → \counterState → Counter.view ((UpdateCounter index) >>> toAction) channel counterState) state)
  button #! on "click" (send channel (toAction AddCounter)) $ text "Add Counter"
  button #! on "click" (send channel (toAction RemoveCounter)) $ text "Remove Counter"

update ∷ Action → State → State
update Noop state = state
update Reset state = initialState
update AddCounter state = snoc state 0
update RemoveCounter state = maybe [] id (init state)
update (UpdateCounter index action) state = applyAtIndex (Counter.update action) index state
