module Request.Playlist exposing (..)

import Http
import Data.Playlist as Playlist exposing (Playlist, decoder)
import Data.Session as Session exposing (Session)
import Data.AuthToken as AuthToken exposing (tokenToString)
import Data.ApiUrl as ApiUrl exposing (ApiUrl, apiUrlToString)

import Json.Encode as Encode
import Json.Decode as Decode
import Util exposing ((=>))
import Request.Helpers exposing (apiUrl)


create : { r | name : String } -> Session -> ApiUrl -> Http.Request Playlist
create { name } session baseUrl =
    let
        playlist =
            Encode.object
                [ "name" => Encode.string name ]

        body =
            Encode.object [ "playlist" => playlist ]
                |> Http.jsonBody

        decode =
            Decode.field "playlist" Playlist.decoder

        authHeader =
            session.token
                |> Maybe.map tokenToString
                |> Maybe.withDefault ""
                |> Http.header "Authorization"
    in
        Http.request
            { method = "POST"
            , headers = [ authHeader ]
            , url = apiUrl baseUrl "/playlists"
            , body = body
            , expect = Http.expectJson decode
            , timeout = Nothing
            , withCredentials = False
            }
