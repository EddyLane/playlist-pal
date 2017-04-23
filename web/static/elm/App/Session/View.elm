module App.Session.View exposing (..)

import Html exposing (..)
import Phoenix.Channel as Channel exposing (Channel)
import App.Session.Msg as Session
import App.Msg exposing (..)
import Json.Encode
import App.Session.Model as Model

onJoin : Json.Encode.Value -> Msg
onJoin user =
    user
        |> Session.UserConnected
        |> MsgForSession


lobby : Channel Msg
lobby =
    Channel.init "me"
        |> Channel.onJoin onJoin
        |> Channel.withDebug

view : Model.Model -> Html Msg
view model =
    let
        greeting =
            case model.user of
                Just user ->
                    user.name
                Nothing ->
                    "Anonymous"

    in
        div [] [ text greeting ]