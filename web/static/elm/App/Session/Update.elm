module App.Session.Update exposing (..)

import App.Session.Model exposing (Model, User, userDecoder)
import App.Session.Msg exposing (..)
import Json.Decode exposing (decodeValue)
import App.Msg as BaseMsg
import Http
import Json.Decode as Decode exposing (decodeValue)


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

        SetToken (Ok token) ->
            ( { session
                | token = Just token
                , initialising = False
              }
            , Cmd.none
            )

        SetToken (Err err) ->
            ( { session | initialising = False }, Debug.log "No working" Cmd.none )


guardianTokenRequest : Cmd BaseMsg.Msg
guardianTokenRequest =
    let
        url =
            "/api/token"

        request =
            Http.get url Decode.string
    in
        Http.send (\r -> SetToken r |> BaseMsg.MsgForSession) request
