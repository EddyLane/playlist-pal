module Channels.UserSocket exposing (phoenixSubscription)

import Phoenix exposing (connect)
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Channel as Channel exposing (Channel)
import Data.AuthToken exposing (AuthToken, tokenToString)
import Data.User exposing (User)


socket : AuthToken -> Socket a
socket token =
    Socket.init "ws://localhost:4000/socket/websocket"
        |> Socket.withParams [ ( "guardian_token", (tokenToString token) ) ]
        |> Socket.heartbeatIntervallSeconds 60
        |> Socket.withDebug


phoenixSubscription : User -> List (Channel a) -> Sub a
phoenixSubscription user channels =
    Phoenix.connect
        (socket user.token)
        channels
