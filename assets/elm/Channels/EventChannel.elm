module Channels.EventChannel exposing (init, leave, eventChannelName, onAdded, join, get)

import Data.User exposing (Username, usernameToString)
import Data.Event
import Data.AuthToken exposing (AuthToken, tokenToString)
import Phoenix.Channel as Channel
import Json.Encode as Encode
import Phoenix.Socket as Socket
import Dict
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value)
import Data.Event as Event exposing (Event, decoder)


eventChannelName : Username -> String
eventChannelName username =
    "events:" ++ (usernameToString username)


init :
    Username
    -> AuthToken
    -> (Encode.Value -> msg)
    -> (Encode.Value -> msg)
    -> Channel.Channel msg
init username token onJoin onJoinError =
    let
        guardianToken =
            token
                |> tokenToString
    in
        Channel.init (eventChannelName username)
            |> Channel.withPayload (Encode.object [ ( "guardian_token", Encode.string guardianToken ) ])
            |> Channel.onJoin onJoin
            |> Channel.onJoinError onJoinError


get : Username -> Socket.Socket msg -> Maybe Channel.State
get username socket =
    socket.channels
        |> Dict.get (eventChannelName username)
        |> Maybe.map .state


onAdded :
    Channel.Channel msg
    -> (Encode.Value -> msg)
    -> Socket.Socket msg
    -> Socket.Socket msg
onAdded channel onAdded socket =
    socket
        |> Socket.on "added" channel.name onAdded


join : Channel.Channel msg -> Socket.Socket msg -> ( Socket.Socket msg, Cmd (Socket.Msg msg) )
join channel socket =
    Socket.join channel socket


leave : Username -> Socket.Socket msg -> ( Socket.Socket msg, Cmd (Socket.Msg msg) )
leave username phxSocket =
    Socket.leave (eventChannelName username) phxSocket
