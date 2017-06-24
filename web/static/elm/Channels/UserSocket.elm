module Channels.UserSocket exposing (phoenixSubscription)

import Phoenix exposing (connect)
import Phoenix.Socket as Socket exposing (Socket)
import Data.AuthToken exposing (AuthToken, tokenToString)
import Data.User exposing (User)
import Channels.EventChannel exposing (eventChannel)


socket : AuthToken -> Socket a
socket token =
    Socket.init "ws://localhost:4000/socket/websocket"
        |> Socket.withParams [ ( "guardian_token", (tokenToString token) ) ]
        |> Socket.heartbeatIntervallSeconds 60
        |> Socket.withDebug


phoenixSubscription : User -> Sub a
phoenixSubscription user =
    Phoenix.connect
        (socket user.token)
        [ user.username |> eventChannel
        ]
