module Ajax where

import Prelude (($), (<>), bind, pure, show, Unit)
import DOM.Event.Types (Event)
import Signal.Channel (CHANNEL, Channel)
import Text.Smolder.HTML (pre, span)
import Text.Smolder.Markup (Markup, text)
import Network.HTTP.Affjax.Response (class Respondable, ResponseType(JSONResponse))
import Data.Show (class Show)
import Data.Maybe (Maybe(..))
import Data.Tuple (Tuple(..))
import Data.Foreign (writeObject)
import Data.Foreign.Class (class IsForeign, class AsForeign, read, readProp, writeProp)
import Data.MediaType (MediaType(..))
import Control.Monad.Eff (Eff)

data Response = Response { foo :: String, bar :: Int, baz :: { qux :: Boolean } }

instance showReponse :: Show Response where
  show (Response r) = "{ foo: " <> show r.foo <> ", bar: " <> show r.bar <> ", baz: { qux: " <> show r.baz.qux <> " } }"

instance isForeignResponse :: IsForeign Response where
  read v = do
    foo <- readProp "foo" v
    bar <- readProp "bar" v
    baz <- readProp "baz" v
    qux <- readProp "qux" baz
    pure (Response { foo, bar, baz: { qux } })

instance asForeignResponse :: AsForeign Response where
  write (Response v) =
    writeObject [(writeProp "foo" v.foo)
                ,(writeProp "bar" v.bar)
                ,(writeProp "baz" (writeObject [writeProp "qux" v.baz.qux]))
                ]

instance respondableReponse :: Respondable Response where
  fromResponse = read
  responseType = Tuple (Just (MediaType "application")) JSONResponse

type State = Maybe Response

data Action = Loading | GetFoobar Response

initialState ∷ State
initialState = Nothing

view ∷ ∀ a e. (Action → a) → Channel a → State → Markup (Event → Eff (channel ∷ CHANNEL | e) Unit)
view toAction channel Nothing = span $ text "Loading..."
view toAction channel (Just state) = pre $ span (text (show state))

update ∷ Action → State → State
update Loading _ = Nothing
update (GetFoobar response) _ = Just response
