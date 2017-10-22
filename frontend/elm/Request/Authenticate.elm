module Request.Authenticate exposing (..)

import Http
import Data.Playlist as Playlist exposing (Playlist, decoder)
import Data.Session as Session exposing (Session)
import Data.AuthToken as AuthToken exposing (AuthToken, tokenToString, stringToToken)
import Data.ApiUrl as ApiUrl exposing (ApiUrl, apiUrlToString)
import Data.User as User
import Dict
import Ports
import Json.Encode as Encode
import Json.Decode as Decode
import Util exposing ((=>))
import Request.Helpers exposing (apiUrl)


storeSession : Session -> Cmd msg
storeSession session =
    Session.encode session
        |> Encode.encode 0
        |> Just
        |> Ports.storeSession


headers : List Http.Header
headers =
    []


formatToken : String -> Maybe AuthToken
formatToken header =
    String.split " " header
        |> List.reverse
        |> List.head
        |> Maybe.andThen stringToToken


responseToSession : Http.Response String -> Result String Session
responseToSession resp =
    let
        maybeToken =
            resp.headers
                |> Dict.get "authorization"
                |> Maybe.andThen formatToken

        maybeUser =
            resp.body
                |> Decode.decodeString (Decode.field "data" User.decoder)
                |> Result.toMaybe
    in
        case ( maybeToken, maybeUser ) of
            ( Just _, Just _ ) ->
                Ok (Session maybeUser maybeToken)

            ( Just _, Nothing ) ->
                Err "Error parsing user in response content"

            ( Nothing, Just _ ) ->
                Err "Error parsing token in response header"

            ( Nothing, Nothing ) ->
                Err "Error parsing user in response content and token in response header"


authenticate : String -> ApiUrl -> Http.Request Session
authenticate token baseUrl =
    let
        body =
            Encode.object [ "login_token" => Encode.string token ]
                |> Http.jsonBody
    in
        Http.request
            { method = "POST"
            , headers = headers
            , url = apiUrl baseUrl "/login-token"
            , body = body
            , expect = Http.expectStringResponse responseToSession
            , timeout = Nothing
            , withCredentials = False
            }
