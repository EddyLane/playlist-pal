module Request.Playlist exposing (..)

import Http
import Data.Playlist as Playlist exposing (Playlist, decoder)
import Json.Encode as Encode
import Json.Decode as Decode
import Util exposing ((=>))
import Request.Helpers exposing (apiUrl)


create : { r | name : String } -> Http.Request Playlist
create { name } =
    let
        playlist =
            Encode.object
                [ "name" => Encode.string name ]

        body =
            Encode.object [ "playlist" => playlist ]
                |> Http.jsonBody
    in
        Decode.field "playlist" Playlist.decoder
            |> Http.post (apiUrl "/playlists") (Debug.log "body" body)
