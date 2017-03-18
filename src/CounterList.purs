module CounterList where

import Prelude (($), (*>), bind, id, pure, unit, Unit)
import Helpers (send, applyAtIndex)
import Counter as Counter
import Data.Maybe (maybe)
import Data.Array (snoc, init, foldl, mapWithIndex)
import Control.Monad.Eff (Eff)
import DOM.Event.Types (Event)
import Signal.Channel (CHANNEL, Channel)
import Text.Smolder.HTML (button, div)
import Text.Smolder.Markup (Markup, (#!), text, on)

type State = Array Int
data Action = Noop | AddCounter | RemoveCounter | UpdateCounter Int Counter.Action

initialState ∷ State
initialState = [Counter.initialState]

view ∷ ∀ e. Channel Action → State → Markup (Event → Eff (channel ∷ CHANNEL | e) Unit)
view channel state = div do
  div do
    foldl (*>) (pure unit) (mapWithIndex (\index → \element → Counter.view (UpdateCounter index) channel element) state)
  button #! on "click" (send channel AddCounter) $ text "Add Counter"
  button #! on "click" (send channel RemoveCounter) $ text "Remove Counter"

update ∷ Action → State → State
update Noop state = state
update AddCounter state = snoc state 0
update RemoveCounter state = maybe [] id (init state)
update (UpdateCounter index action) state = applyAtIndex (Counter.update action) index state
