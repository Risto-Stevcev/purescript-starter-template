module Counter where

import Prelude ((+), (-), (*), ($), (<), (<>), show, min, bind, Unit)
import Helpers (send)
import DOM.Event.Types (Event)
import Signal.Channel (CHANNEL, Channel)
import Text.Smolder.HTML (button, h2, div)
import Text.Smolder.HTML.Attributes (style)
import Text.Smolder.Markup (Markup, (!), (#!), text, on)
import Data.Ord (abs)
import Control.Monad.Eff (Eff)

type State = Int
data Action = Increment | Decrement

initialState ∷ State
initialState = 0

view ∷ ∀ a e. (Action → a) → Channel a → State → Markup (Event → Eff (channel ∷ CHANNEL | e) Unit)
view toAction channel state = div do
  h2 ! style (setColor state) $ text ("Number " <> show state)
  button #! on "click" (send channel (toAction Increment)) $ text "Increment"
  button #! on "click" (send channel (toAction Decrement)) $ text "Decrement"

  where
    rgbScale n = show $ min ((abs n) * 8) 256
    setColor n | n < 0 = "color: rgb(" <> (rgbScale n) <> ",0,0)"
    setColor n = "color: rgb(0," <> (rgbScale n) <> ",0)"

update ∷ Action → State → State
update Increment state = state + 1
update Decrement state = state - 1
