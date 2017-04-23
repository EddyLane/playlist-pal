module App.Session.View exposing (..)

import Phoenix.Channel as Channel exposing (Channel)
import App.Session.Msg as Session
import App.Msg exposing (..)
import Json.Encode

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