module Data.AuthToken exposing (AuthToken, encode, decoder, tokenToString, stringToToken)

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


stringToToken : String -> Maybe AuthToken
stringToToken string =
    AuthToken string
        |> Just


decoder : Decoder AuthToken
decoder =
    Decode.string
        |> Decode.map AuthToken
