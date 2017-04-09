module Update.Session exposing (..)

import Model.Session exposing (Model, User)
import Msg.Session exposing (..)
import Json.Decode as Decode exposing (decodeValue)

userDecoder : Decode.Decoder User
userDecoder =
    Decode.map2
        User
        (Decode.at [ "username" ] Decode.string)
        (Decode.at [ "name" ] Decode.string)

update : Msg -> Model -> Model
update msg session =
    case msg of

        UserConnected user ->
            let
                u =
                    case decodeValue userDecoder user of
                        Ok newRecord ->
                            Just newRecord

                        Err _ ->
                            Nothing

            in
                { session | user = u }


        _ -> session