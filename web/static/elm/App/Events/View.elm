module App.Events.View exposing (..)

import App.Events.Model exposing (..)
import App.Msg exposing (..)
import App.Events.Msg as EventsMsg
import Html exposing (..)
import Html.Attributes exposing (class, for, type_, placeholder, value, id)
import Html.Events exposing (onSubmit, onInput)
import Json.Encode
import Phoenix.Channel as Channel exposing (Channel)
import App.Session.Model exposing (User)

onJoin : Json.Encode.Value -> Msg
onJoin events =
    events
        |> EventsMsg.EventChannelConnected
        |> MsgForEvents

onUpdate : Json.Encode.Value -> Msg
onUpdate event =
    event
        |> EventsMsg.EventChannelUpdated
        |> MsgForEvents

eventChannel : User -> Channel Msg
eventChannel user =
    Channel.init ("events:" ++ user.username)
        |> Channel.onJoin onJoin
        |> Channel.on "added" onUpdate
        |> Channel.withDebug


newForm : Event -> Html Msg
newForm newEvent =

    let
        submit =
            newEvent.name
            |> EventsMsg.CreateEvent
            |> MsgForEvents

        updateName newName =
            newName
            |> EventsMsg.NewFormName
            |> MsgForEvents
    in
        form [ class "form-inline", onSubmit submit ]
            [ label
                [ for "event-name"
                , class "sr-only"
                ]
                [ text "Event" ]
            , input
                [ class "mb-2 mr-sm-2 mb-sm-0"
                , type_ "text"
                , id "event-name"
                , class "form-control"
                , placeholder "New event..."
                , value newEvent.name
                , onInput updateName
                ]
                []
            , button
                [ class "btn btn-primary"
                , type_ "submit"
                ]
                [ text "Create" ]
            ]


eventList : List Event -> Html Msg
eventList events =
    let
        row event =
            tr [] [ td [] [ text event.name ] ]
    in
        table [ class "table table-inversed" ] (List.map row events)


view : Model -> Html Msg
view model =
    div [] [ (eventList model.events), newForm model.newForm ]
