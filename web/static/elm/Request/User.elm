module Request.User exposing (login, register, storeSession)

import Http
import Data.User as User exposing (User, encode)
import Json.Encode as Encode
import Json.Decode as Decode
import Util exposing ((=>))
import Request.Helpers exposing (apiUrl)
import Ports


storeSession : User -> Cmd msg
storeSession user =
    User.encode user
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


register : { r | username : String, name : String, password : String } -> Http.Request User
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
        Decode.field "user" User.decoder
            |> Http.post (apiUrl "/users") body
