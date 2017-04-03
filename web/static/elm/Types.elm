module Types exposing (..)

import Http
import Time exposing (Time, second)
import Json.Encode
import Debounce exposing (Debounce)

type alias Model =
    { search : String
    , results : List SpotifyTrack
    , user : Maybe User
    , token : String
    , error : Maybe String
    , currentTime : Time
    , tracks : List SpotifyTrack
    , debounce : Debounce String
    }


type alias User =
    { username : String, name : String }


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


type Msg
    = NoOp
    | Search String
    | SearchResults (Result Http.Error (List SpotifyTrack))
    | SearchUpdated String
    | ConnectionStatusChanged ConnectionStatus
    | Tick Time
    | UpdateState State
    | UserConnected Json.Encode.Value
    | NewTrack Json.Encode.Value
    | AddTrack SpotifyTrack
    | DebounceMsg Debounce.Msg


type alias SpotifyTrack =
    { name : String, href : String, id : String, album : SpotifyAlbum, artists : List String }


type alias SpotifyAlbum =
    { name : String, images : List SpotifyImage }


type alias SpotifyImage =
    { height : Int, width : Int, url : String }