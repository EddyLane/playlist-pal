module Page.Home exposing (view, update, Model, Msg, initialModel)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Html exposing (..)
import Html.Attributes exposing (class, href, id, placeholder, attribute, classList)
import Html.Events exposing (onClick)
import Data.Session as Session exposing (Session)
import Views.Page as Page
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Task exposing (Task)
import Http
import Util exposing ((=>), onClickStopPropagation)

-- MODEL --


initialModel : Model
initialModel =
    {}

type alias Model =
    {}


-- VIEW --


view : Model -> Html Msg
view model =
    text "Hello homepage"


type Msg
    = NoOp

update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        _ ->
            model => Cmd.none