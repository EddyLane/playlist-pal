module Channels.EventChannel exposing (eventChannel)

import Data.User exposing (User, usernameToString)
import Data.AuthToken exposing (tokenToString)
import Phoenix.Channel
import Json.Encode as Encode


eventChannel : User -> Phoenix.Channel.Channel msg
eventChannel user =
    let
        guardianToken =
            user.token
                |> tokenToString

        username =
            user.username
                |> usernameToString
    in
        Phoenix.Channel.init ("events:" ++ username)
            |> Phoenix.Channel.withPayload (Encode.object [ ( "guardian_token", Encode.string guardianToken ) ])
