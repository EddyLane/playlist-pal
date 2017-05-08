module App.Events.Msg exposing (..)

import App.Events.Model exposing (Event)
import Http
import Json.Encode as Encode


type Msg
    = SetEvents (Result Http.Error (List Event))
    | NewFormName String
    | EventChannelConnected Encode.Value
    | CreateEvent String
    | CreateEventRequest (Result Http.Error (Event))