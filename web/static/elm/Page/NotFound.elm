module Page.NotFound exposing (view)

import Html exposing (Html, main_, h1, div, img, text)
import Html.Attributes exposing (class, tabindex, id, src, alt)
import Data.Session as Session exposing (Session)

-- VIEW --


view : Session -> Html msg
view session =
    div [] [ text "DIS ONE NOT FOUND MAN" ]
