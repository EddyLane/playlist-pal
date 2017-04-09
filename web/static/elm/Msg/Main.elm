module Msg.Main exposing (..)

import Time exposing (Time)
import Debounce exposing (Debounce)
import Json.Encode
import Http
import Model.Main exposing (..)
import Msg.Session as Session

type Msg
    = NoOp
    | Search String
    | SearchResults (Result Http.Error (List SpotifyTrack))
    | SearchUpdated String
    | ConnectionStatusChanged ConnectionStatus
    | Tick Time
    | UpdateState State
    | NewTrack Json.Encode.Value
    | AddTrack SpotifyTrack
    | DebounceMsg Debounce.Msg
    | MsgForSession Session.Msg