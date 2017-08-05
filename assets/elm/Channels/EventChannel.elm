module Channels.EventChannel exposing (init, leave, eventChannelName, onAdded, join, get)

import Data.User exposing (User, usernameToString)
import Data.Event
import Data.AuthToken exposing (tokenToString)
import Phoenix.Channel as Channel
import Json.Encode as Encode
import Phoenix.Socket as Socket
import Dict
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value)
import Data.Event as Event exposing (Event, decoder)


eventChannelName : User -> String
eventChannelName user =
    let
        username =
            user.username
                |> usernameToString
    in
        "events:" ++ username


init :
    { name : String
    , username : Data.User.Username
    , token : Data.AuthToken.AuthToken
    }
    -> (Encode.Value -> msg)
    -> (Encode.Value -> msg)
    -> Channel.Channel msg
init user onJoin onJoinError =
    let
        guardianToken =
            user.token
                |> tokenToString

        channel =
            Channel.init (eventChannelName user)
                |> Channel.withPayload (Encode.object [ ( "guardian_token", Encode.string guardianToken ) ])
                |> Channel.onJoin onJoin
                |> Channel.onJoinError onJoinError
    in
        channel


get : User -> Socket.Socket msg -> Maybe Channel.State
get user socket =
    socket.channels
        |> Dict.get (eventChannelName user)
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


leave : User -> Socket.Socket msg -> ( Socket.Socket msg, Cmd (Socket.Msg msg) )
leave user phxSocket =
    Socket.leave (eventChannelName user) phxSocket
