module Channels.UserSocket exposing (socket)

import Data.AuthToken exposing (AuthToken, tokenToString)
import Data.User exposing (User)
import Phoenix.Socket


--
--socket : AuthToken -> Socket a
--socket token =
--    Socket.init "ws://localhost:4000/socket/websocket"
--        |> Socket.withParams [ ( "guardian_token", (tokenToString token) ) ]
--        |> Socket.heartbeatIntervallSeconds 60
--        |> Socket.withDebug
--
--
--phoenixSubscription : User -> List (Channel a) -> Sub a
--phoenixSubscription user channels =
--    Phoenix.connect
--        (socket user.token)
--        channels


socketServer : String
socketServer =
    "ws://localhost:4000/socket/websocket"


socket : Phoenix.Socket.Socket a
socket =
    Phoenix.Socket.init socketServer
