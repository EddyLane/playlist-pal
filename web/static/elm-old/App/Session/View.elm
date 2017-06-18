module App.Session.View exposing (..)

import Html exposing (..)
import Phoenix.Channel as Channel exposing (Channel)
import App.Session.Msg as Session
import App.Msg exposing (..)
import App.Session.Model as Model

lobby : Channel Msg
lobby =
    Channel.init "me"
        |> Channel.onJoin (Session.UserConnected >> MsgForSession)
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
