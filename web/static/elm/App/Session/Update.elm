module App.Session.Update exposing (..)

import App.Session.Model exposing (Model, User, userDecoder)
import App.Session.Msg exposing (..)
import Json.Decode exposing (decodeValue)
import App.Msg as BaseMsg


update : Msg -> Model -> ( Model, Cmd BaseMsg.Msg )
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
                ( { session | user = u }, Cmd.none )


updateCmd : Msg -> Cmd BaseMsg.Msg
updateCmd msg =
    Cmd.none
