module Msg.Main exposing (..)

import Time exposing (Time)
import Debounce exposing (Debounce)
import Json.Encode
import Model.Main exposing (..)
import Msg.Session as Session
import Msg.Spotify as Spotify
import Model.Spotify exposing (..)

type Msg
    = NoOp
    | Search String
    | SearchUpdated String
    | ConnectionStatusChanged ConnectionStatus
    | Tick Time
    | UpdateState State
    | NewTrack Json.Encode.Value
    | AddTrack SpotifyTrack
    | DebounceMsg Debounce.Msg
    | MsgForSession Session.Msg
    | MsgForSpotify Spotify.Msg