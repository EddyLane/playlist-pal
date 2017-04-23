module Model.Main exposing (..)

import Time exposing (Time)
import Debounce exposing (Debounce)
import Model.Session as Session
import Model.Spotify as Spotify

type alias Model =
    { search : String
    , currentTime : Time
    , tracks : List Spotify.SpotifyTrack
    , debounce : Debounce String
    , session : Session.Model
    , spotify : Spotify.Model
    }

type alias Flags =
    { token : String }

type ConnectionStatus
    = Connected
    | Disconnected
    | ScheduledReconnect { time : Time }

type State
    = JoiningLobby
    | JoinedLobby
    | LeavingLobby
    | LeftLobby

model : Model
model =
    { search = ""
    , currentTime = 0
    , tracks = []
    , debounce = Debounce.init
    , session = Session.model
    , spotify = Spotify.model
    }

init : Flags -> ( Model, Cmd a )
init flags =
    let
        oldSession = model.session
    in
        ( { model | session = { oldSession | token = flags.token } }, Cmd.none )