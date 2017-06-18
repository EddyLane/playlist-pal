module Model.Spotify exposing (..)

type alias SpotifyTrack =
    { name : String, href : String, id : String, album : SpotifyAlbum, artists : List String }

type alias SpotifyAlbum =
    { name : String, images : List SpotifyImage }

type alias SpotifyImage =
    { height : Int, width : Int, url : String }

type alias Model =
    { results: List SpotifyTrack, error: Maybe String }

model : Model
model = { results = []
        , error = Nothing
        }