module App.Events.Update exposing (..)

import Http
import App.Msg as BaseMsg
import Json.Decode as Decode
import Json.Encode as Encode
import App.Events.Model exposing (Model, eventDecoder, errorDecoder)
import App.Msg as BaseMsg
import App.Events.Msg exposing (..)
import App.Events.Model exposing (Event)
import Bootstrap.Modal as Modal
import Navigation
import Http

url : String
url =
    "/api/events"

getEvents : Cmd BaseMsg.Msg
getEvents =
    let
        request =
            Http.get url (Decode.list eventDecoder |> Decode.at [ "data" ])
    in
        Http.send (SetEvents >> BaseMsg.MsgForEvents) request


encodeEvent : String -> Encode.Value
encodeEvent name =
    let
        structure =
            [ ( "name", Encode.string name ) ]
    in
        Encode.object ([ ( "event", Encode.object (structure) ) ])


postEvent : Encode.Value -> Cmd BaseMsg.Msg
postEvent json =
    let
        request =
            Http.post url (Http.jsonBody (json)) (Decode.at [ "data" ] eventDecoder)
    in
        Http.send (CreateEventRequest >> BaseMsg.MsgForEvents) request


isIdentical : Event -> Event -> Bool
isIdentical a b =
    case ( a.id, b.id ) of
        ( Just aId, Just bId ) ->
            aId == bId

        _ ->
            False


findEvent : List Event -> Event -> Maybe Event
findEvent events event =
    List.filter (isIdentical event) events
        |> List.head


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

        EventChannelConnected eventsJson ->
            let
                events =
                    case Decode.decodeValue (Decode.list eventDecoder) eventsJson of
                        Ok events ->
                            Debug.log "EVENT CONNECTED" events

                        Err _ ->
                            model.events
            in
                ( { model | events = events }, Cmd.none )

        EventChannelUpdated eventJson ->
            let
                cmd event =
                    case ( event.slug, model.lastCreatedId, event.id ) of
                        ( Just slug, Just lastCreatedId, Just id ) ->
                            if id == lastCreatedId then
                                Navigation.newUrl ("#event/" ++ slug)
                            else
                                Cmd.none

                        _ ->
                            Cmd.none

                results =
                    case Decode.decodeValue eventDecoder eventJson of
                        Ok event ->
                            ( ( [ event ] ++ model.events, Modal.hiddenState )
                            , cmd event
                            )

                        Err _ ->
                            ( ( model.events, Modal.visibleState ), Cmd.none )

                events =
                    results |> Tuple.first |> Tuple.first

                formModalState =
                    results |> Tuple.first |> Tuple.second
            in
                ( { model
                    | events = events
                    , formModalState = formModalState
                  }
                , Tuple.second results
                )

        CreateEvent name ->
            ( { model
                | submitting = True
                , hasError = Nothing
                , errors = { name = [] }
              }
            , name |> encodeEvent |> postEvent
            )

        CreateEventRequest (Ok event) ->
            let
                cmd =
                    case findEvent model.events event of
                        Just found ->
                            case found.slug of
                                Just slug ->
                                    Navigation.newUrl ("#event/" ++ slug)

                                _ ->
                                    Cmd.none

                        _ ->
                            Cmd.none
            in
                ( { model
                    | submitting = False
                    , newForm = { id = Nothing, name = "", slug = Nothing }
                    , lastCreatedId = event.id
                  }
                , cmd
                )

        CreateEventRequest (Err err) ->
            let
                errors =
                    case err of
                        Http.BadStatus err ->
                            Result.withDefault model.errors (decodeErrors err.body)

                        _ ->
                            model.errors

                decodeErrors bodyString =
                    Decode.decodeString errorDecoder bodyString
            in
                ( { model
                    | submitting = False
                    , hasError = Just err
                    , errors = errors
                  }
                , Cmd.none
                )

        FormModal state ->
            ( { model | formModalState = state }, Cmd.none )

        Tick time ->
            let
                newCount =
                    case model.hasError of
                        Just _ ->
                            if errorHasTimedOut then
                                0
                            else
                                model.errorPresentTime + 1

                        _ ->
                            0

                hasError =
                    case model.hasError of
                        Just _ ->
                            if errorHasTimedOut then
                                Nothing
                            else
                                model.hasError

                        _ ->
                            Nothing

                errorHasTimedOut =
                    model.errorPresentTime > 5
            in
                ( { model
                    | hasError = hasError
                    , errorPresentTime = newCount
                  }
                , Cmd.none
                )
