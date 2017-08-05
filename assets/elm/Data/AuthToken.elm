module Data.AuthToken exposing (AuthToken, encode, decoder, tokenToString)

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)


type AuthToken
    = AuthToken String


encode : AuthToken -> Value
encode (AuthToken token) =
    Encode.string token


tokenToString : AuthToken -> String
tokenToString (AuthToken token) =
    token


decoder : Decoder AuthToken
decoder =
    Decode.string
        |> Decode.map AuthToken
