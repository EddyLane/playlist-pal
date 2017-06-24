module Channels.UserSocket exposing (..)

import Phoenix exposing (connect)
import Phoenix.Socket as Socket exposing (Socket)
import Data.User exposing ()

socket : String -> Socket Msg
socket accessToken =
    Socket.init "ws://localhost:4000/socket/websocket"
        |> Socket.withParams [ ( "guardian_token", accessToken ) ]
        |> Socket.heartbeatIntervallSeconds 20
        |> Socket.withDebug


phoenixSubscription : Model -> Sub Msg
phoenixSubscription model =
    Sub.none