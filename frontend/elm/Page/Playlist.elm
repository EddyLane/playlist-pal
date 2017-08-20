module Page.Playlist exposing (Model, Msg, view, initialModel)

import Data.Playlist exposing (Playlist)
import Data.Session as Session exposing (Session)

import Bootstrap.Grid as Grid
import Html exposing (..)

import Util exposing ((=>))


-- MODEL --


type alias Model =
    {}

initialModel : Model
initialModel =
    {}

-- UPDATE __

type Msg
    = Pass

type ExternalMsg
    = NoOp

update : Session -> Msg -> Model -> ( ( Model, Cmd Msg), ExternalMsg )
update session msg model =
    model
    => Cmd.none
    => NoOp


-- VIEW --

view : Session -> Model -> Html Msg
view session model =
    Grid.container []
        [ text "Playlist page isnt it" ]