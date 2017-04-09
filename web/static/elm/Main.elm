module Main exposing (..)

import Html exposing (programWithFlags)
import Phoenix
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Socket as Socket exposing (Socket)
import Time exposing (Time)

import Model.Main exposing (..)
import Msg.Main exposing (..)
import Msg.Session as Session
import View.Main exposing (view)
import Update.Main exposing (..)

-- MODEL
socket : String -> Socket Msg
socket accessToken =
    Socket.init lobbySocket
        |> Socket.withParams [ ( "guardian_token", accessToken ) ]
        |> Socket.heartbeatIntervallSeconds 20
        |> Socket.withDebug


lobby : Channel Msg
lobby =
    Channel.init "me"
        |> Channel.onJoin (\user -> MsgForSession (Session.UserConnected user))
        |> Channel.withDebug


tracks : Channel Msg
tracks =
    Channel.init "tracks"
        |> Channel.on "new_track" NewTrack
        |> Channel.withDebug

phoenixSubscription : Model -> Sub Msg
phoenixSubscription model =
    Phoenix.connect (socket model.session.token) [ lobby, tracks ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ phoenixSubscription model, Time.every Time.second Tick ]

main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
