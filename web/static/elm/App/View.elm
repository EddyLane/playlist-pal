module App.View exposing (..)

import Html exposing (..)
import App.Model exposing (Model)
import App.Msg exposing (Msg)
import App.Session.View as Session


view : Model -> Html Msg
view model =
    let
        session =
            model.session
    in
        div [] [ Session.view session ]
