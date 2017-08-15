module Request.User exposing (login, register, storeSession)

import Http
import Data.User as User exposing (User)
import Data.Session as Session exposing (Session)
import Data.AuthToken as AuthToken exposing (AuthToken, stringToToken)
import Json.Encode as Encode
import Json.Decode as Decode
import Util exposing ((=>))
import Request.Helpers exposing (apiUrl)
import Ports
import Dict

headers : List Http.Header
headers = []

storeSession : Session -> Cmd msg
storeSession session =
    Session.encode session
        |> Encode.encode 0
        |> Just
        |> Ports.storeSession


login : { r | username : String, password : String } -> Http.Request Session
login { username, password } =
    let
        user =
            Encode.object
                [ "username" => Encode.string username
                , "password" => Encode.string password
                ]

        body =
            Encode.object [ "user" => user ]
                |> Http.jsonBody
    in
        Http.request
            { method = "POST"
            , headers = headers
            , url = apiUrl "/login"
            , body = body
            , expect = Http.expectStringResponse responseToSession
            , timeout = Nothing
            , withCredentials = False
            }


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
        case (maybeToken, maybeUser) of
            (Just _, Just _) ->
                Ok (Session maybeUser maybeToken)
            (Just _, Nothing) ->
                Err "Error parsing user in response content"
            (Nothing, Just _) ->
                Err "Error parsing token in response header"
            (Nothing, Nothing) ->
                Err "Error parsing user in response content and token in response header"

register : { r | username : String, name : String, password : String } -> Http.Request Session
register { username, name, password } =
    let
        user =
            Encode.object
                [ "username" => Encode.string username
                , "name" => Encode.string name
                , "password" => Encode.string password
                ]

        body =
            Encode.object [ "user" => user ]
                |> Http.jsonBody
    in
        Http.request
            { method = "POST"
            , headers = headers
            , url = apiUrl "/users"
            , body = body
            , expect = Http.expectStringResponse responseToSession
            , timeout = Nothing
            , withCredentials = False
            }
