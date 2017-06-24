module Channels.EventChannel exposing (eventChannel)

import Data.User exposing (Username, usernameToString)
import Phoenix.Channel as Channel exposing (Channel)


--onJoin : Json.Encode.Value -> Msg
--onJoin events =
--    events
--        |> EventsMsg.EventChannelConnected
--        |> MsgForEvents
--
--onUpdate : Json.Encode.Value -> Msg
--onUpdate event =
--    event
--        |> EventsMsg.EventChannelUpdated
--        |> MsgForEvents


eventChannel : Username -> Channel msg
eventChannel username =
    Channel.init ("events:eddy_lane")
        --        |> Channel.onJoin onJoin
        --        |> Channel.on "added" onUpdate
        |>
            Channel.withDebug
