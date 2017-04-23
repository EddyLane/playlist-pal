module App.View exposing (..)

import Html exposing (..)
import App.Model exposing (Model)
import App.Msg exposing (Msg)

view : Model -> Html Msg
view model =
    div [] [ text "Hello world!" ]