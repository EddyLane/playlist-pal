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


storeSession : Session -> Cmd msg
storeSession session =
    Session.encode session
        |> Encode.encode 0
        |> Just
        |> Ports.storeSession


login : { r | username : String, password : String } -> Http.Request User
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
        Decode.field "user" User.decoder
            |> Http.post (apiUrl "/login") body


responseToSession : Http.Response String -> Result String Session
responseToSession resp =
    let
        token =
            Dict.get "authorization" resp.headers
                |> Maybe.andThen stringToToken

        user =
            Decode.decodeString (Decode.field "data" User.decoder) resp.body
                |> Result.toMaybe
    in
        Session user token
            |> Ok


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
            , headers = []
            , url = apiUrl "/users"
            , body = body
            , expect = Http.expectStringResponse responseToSession
            , timeout = Nothing
            , withCredentials = False
            }
