module Page.NotFound exposing (view)

import Html exposing (..)
import Data.Session as Session exposing (Session)


-- VIEW --


view : Session -> Html msg
view session =
    div [] [ text "DIS ONE NOT FOUND MAN" ]
