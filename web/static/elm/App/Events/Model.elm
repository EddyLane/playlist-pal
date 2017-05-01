module App.Events.Model exposing (..)

import Json.Decode as Decode

type alias Event =
    { id: Maybe Int, name: String }

type alias Model =
    { events: List Event, newForm: Event }

eventDecoder : Decode.Decoder Event
eventDecoder =
    Decode.map2
        Event
        (Decode.maybe (Decode.at ["id"] Decode.int))
        (Decode.at ["name"] Decode.string)

initialModel : Model
initialModel =
    { events = [], newForm = { id = Nothing, name = "" } }