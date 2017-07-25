module Channels.EventChannel exposing (join, leave, eventChannelName)

import Data.User exposing (User, usernameToString)
import Data.AuthToken exposing (tokenToString)
import Phoenix.Channel as Channel
import Json.Encode as Encode
import Phoenix.Socket as Socket


eventChannelName : User -> String
eventChannelName user =
    let
        username =
            user.username
                |> usernameToString
    in
        "events:" ++ username


join : User -> Channel.Channel msg
join user =
    let
        guardianToken =
            user.token
                |> tokenToString
    in
        Channel.init (eventChannelName user)
            |> Channel.withPayload (Encode.object [ ( "guardian_token", Encode.string guardianToken ) ])


leave : User -> Socket.Socket msg -> ( Socket.Socket msg, Cmd (Socket.Msg msg) )
leave user phxSocket =
    Socket.leave (eventChannelName user) phxSocket
