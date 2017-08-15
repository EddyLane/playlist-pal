module Channels.PlaylistChannel exposing (init, leave, playlistChannelName, onAdded, join, get)

import Data.User exposing (Username, usernameToString)
import Data.AuthToken exposing (AuthToken, tokenToString)
import Phoenix.Channel as Channel
import Json.Encode as Encode
import Phoenix.Socket as Socket
import Dict
import Json.Encode as Encode


playlistChannelName : Username -> String
playlistChannelName username =
    "playlists:lobby"


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
        Channel.init (playlistChannelName username)
            |> Channel.withPayload (Encode.object [ ( "guardian_token", Encode.string guardianToken ) ])
            |> Channel.onJoin onJoin
            |> Channel.onJoinError onJoinError


get : Username -> Socket.Socket msg -> Maybe Channel.State
get username socket =
    socket.channels
        |> Dict.get (playlistChannelName username)
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
    Socket.leave (playlistChannelName username) phxSocket
