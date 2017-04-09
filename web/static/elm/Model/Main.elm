module Model.Main exposing (..)

import Time exposing (Time)
import Debounce exposing (Debounce)
import Model.Session as Session

type alias Model =
    { search : String
    , results : List SpotifyTrack
    , error : Maybe String
    , currentTime : Time
    , tracks : List SpotifyTrack
    , debounce : Debounce String
    , session : Session.Model
    }


type alias Flags =
    { token : String }

type alias SpotifyTrack =
    { name : String, href : String, id : String, album : SpotifyAlbum, artists : List String }

type alias SpotifyAlbum =
    { name : String, images : List SpotifyImage }

type alias SpotifyImage =
    { height : Int, width : Int, url : String }

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
    , results = []
    , error = Nothing
    , currentTime = 0
    , tracks = []
    , debounce = Debounce.init
    , session = Session.model
    }

init : Flags -> ( Model, Cmd a )
init flags =
    let
        oldSession = model.session
    in
        ( { model | session = { oldSession | token = flags.token } }, Cmd.none )