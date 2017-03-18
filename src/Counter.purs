module Counter where

import Prelude ((+), (-), (*), ($), (<>), show, min, bind, Unit)
import Helpers (send)
import Control.Monad.Eff (Eff)
import DOM.Event.Types (Event)
import Signal.Channel (CHANNEL, Channel)
import Text.Smolder.HTML (button, h1, div)
import Text.Smolder.HTML.Attributes (style)
import Text.Smolder.Markup (Markup, (!), (#!), text, on)

type State = Int
data Action = Increment | Decrement

initialState ∷ State
initialState = 0

view ∷ ∀ a e. (Action → a) → Channel a → State → Markup (Event → Eff (channel ∷ CHANNEL | e) Unit)
view toAction channel state = div do
  h1 ! style ("color: rgb(" <> show (min (state * 8) 256) <> ",0,0)") $ text ("Number " <> show state)
  button #! on "click" (send channel (toAction Increment)) $ text "Increment"
  button #! on "click" (send channel (toAction Decrement)) $ text "Decrement"

update ∷ Action → State → State
update Increment state = state + 1
update Decrement state = state - 1
