module App.Events.Msg exposing (..)

import App.Events.Model exposing (Event)
import Http
import Json.Encode as Encode
import Bootstrap.Modal as Modal


type Msg
    = SetEvents (Result Http.Error (List Event))
    | NewFormName String
    | EventChannelConnected Encode.Value
    | EventChannelUpdated Encode.Value
    | CreateEvent String
    | CreateEventRequest (Result Http.Error Event)
    | FormModal Modal.State
