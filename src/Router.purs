module Router where

import Prelude (Unit, (<$))
import Routing (matches)
import Routing.Match (Match)
import Routing.Match.Class (lit)
import Control.Alt ((<|>))
import Control.Monad.Eff (Eff)
import Control.Monad.Eff.Console (CONSOLE)

data Location = Home | CounterListPage | AjaxPage

oneSlash ∷ Match Unit
oneSlash = lit "/"

homeSlash ∷ Match Unit
homeSlash = lit ""

home ∷ Match Location
home = Home <$ homeSlash

counterListPage ∷ Match Location
counterListPage = CounterListPage <$ (lit "counterlist")

ajaxPage ∷ Match Location
ajaxPage = AjaxPage <$ (lit "ajax")


routing ∷ Match Location
routing =
  counterListPage <|>
  ajaxPage        <|>
  home

runRoutes ∷ ∀ e. (Location → Eff (console :: CONSOLE | e) Unit) → Eff (console :: CONSOLE | e) Unit
runRoutes changePage = matches routing (\_ new → changePage new)
