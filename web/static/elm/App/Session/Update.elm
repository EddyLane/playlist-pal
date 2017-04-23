module App.Session.Update exposing (..)

import App.Session.Model exposing (Model, User, userDecoder)
import App.Session.Msg exposing (..)
import Json.Decode exposing (decodeValue)


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