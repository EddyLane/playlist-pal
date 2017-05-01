module App.Events.View exposing (..)

import App.Events.Model exposing (..)
import App.Msg exposing (..)
import App.Events.Msg as EventsMsg
import Html exposing (..)
import Html.Attributes exposing (class, for, type_, placeholder, value)
import Json.Encode
import Phoenix.Channel as Channel exposing (Channel)


onJoin : Json.Encode.Value -> Msg
onJoin events =
    events
        |> EventsMsg.EventChannelConnected
        |> MsgForEvents

eventChannel : Channel Msg
eventChannel =
    Channel.init "events"
        |> Channel.onJoin onJoin
        |> Channel.withDebug


newForm : Event -> Html Msg
newForm newEvent =
    form []
        [ div [ class "form-group row" ]
            [ label [ for "search", class "col-sm-2 col-form-label col-form-label-lg" ] [ text "Event" ]
            , div [ class "col-sm-10" ]
                [ input [
                    type_ "text"
                  , class "form-control form-control-lg"
                  , placeholder "New event..."
                  , value newEvent.name
                  ] []
                ]
            ]
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