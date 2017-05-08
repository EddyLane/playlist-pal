module App.Events.Update exposing (..)

import Http
import App.Msg as BaseMsg
import Json.Decode as Decode
import Json.Encode as Encode
import App.Events.Model exposing (Model, eventDecoder)
import App.Msg as BaseMsg
import App.Events.Msg exposing (..)

url : String
url = "/api/events"

getEvents : Cmd BaseMsg.Msg
getEvents =
    let
        request =
            Http.get url (Decode.list eventDecoder |> Decode.at [ "data" ])
    in
        Http.send (\result -> SetEvents result |> BaseMsg.MsgForEvents) request


encodeEvent : String -> Encode.Value
encodeEvent name =
    let
        structure =
            [ ( "name", Encode.string name) ]
    in
        Encode.object([ ( "event", Encode.object(structure) )])

postEvent : Encode.Value -> Cmd BaseMsg.Msg
postEvent json =
    let
        request =
            Http.post url (Http.jsonBody(json)) eventDecoder
     in
        Http.send (\result -> CreateEventRequest result |> BaseMsg.MsgForEvents) request

update : Msg -> Model -> ( Model, Cmd BaseMsg.Msg )
update msg model =
    case msg of
        SetEvents (Ok data) ->
            ( { model | events = data }, Cmd.none )

        SetEvents (Err err) ->
            ( model, Cmd.none )

        NewFormName name ->
            let
                newEvent =
                    model.newForm
            in
                ( { model | newForm = { newEvent | name = name } }, Cmd.none )

        EventChannelConnected eventJson ->
            let
                events =
                    case Decode.decodeValue (Decode.list eventDecoder) eventJson of
                        Ok events ->
                            events

                        Err _ ->
                            model.events
            in
                ( { model | events = events }, Cmd.none )

        CreateEvent name ->
            ( model, name |> encodeEvent |> postEvent )

        CreateEventRequest (Ok event) ->
            ( model, Cmd.none )

        CreateEventRequest (Err err) ->
            ( model, Cmd.none )
