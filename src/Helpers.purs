module Helpers where

import Prelude ((==), Unit)
import Data.Array (mapWithIndex)
import Control.Monad.Eff (Eff)
import DOM.Event.Types (Event)
import Signal.Channel (CHANNEL, Channel)
import Signal.Channel as Channel

send ∷ ∀ a e. Channel a → a → Event → Eff (channel ∷ CHANNEL | e) Unit
send actions action _ = Channel.send actions action

applyAtIndex ∷ ∀ a. (a → a) → Int → Array a → Array a
applyAtIndex fn index array =
  mapWithIndex (applyIndex fn) array
  where
    applyIndex fn' index' element | index == index' = fn' element
    applyIndex _ _ element = element
