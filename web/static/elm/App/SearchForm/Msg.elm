module App.SearchForm.Msg exposing (..)

import Debounce exposing (Debounce)
import Http


type alias SpotifyTrack =
    { name : String
    , href : String
    , id : String
    , album : SpotifyAlbum
    , artists : List String
    }


type alias SpotifyAlbum =
    { name : String
    , images : List SpotifyImage
    }


type alias SpotifyImage =
    { height : Int
    , width : Int
    , url : String
    }


type Msg
    = UpdateSearch String
    | DebounceMsg Debounce.Msg
    | SearchResults (Result Http.Error (List SpotifyTrack))
