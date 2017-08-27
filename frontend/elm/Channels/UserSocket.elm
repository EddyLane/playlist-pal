module Channels.UserSocket exposing (initPhxSocket)

import Data.AuthToken exposing (AuthToken, tokenToString)
import Data.User exposing (User)
import Data.ApiUrl exposing (ApiUrl, apiUrlToString)
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



initPhxSocket : ApiUrl -> Phoenix.Socket.Socket a
initPhxSocket baseUrl =
    Phoenix.Socket.init ("ws://" ++ (apiUrlToString baseUrl) ++ "/socket/websocket")
        |> Phoenix.Socket.withDebug



--        |> Phoenix.Socket.withoutHeartbeat
