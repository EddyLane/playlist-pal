module Msg.Spotify exposing (..)

import Http
import Model.Spotify exposing (SpotifyTrack)

type Msg
    = NoOp
    | SearchResults (Result Http.Error (List SpotifyTrack))
