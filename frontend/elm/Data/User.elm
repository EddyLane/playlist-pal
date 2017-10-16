module Data.User exposing (User, Username, decoder, usernameToString, usernameToHtml, usernameDecoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Html exposing (Html)
import Util exposing ((=>))
import Data.AuthToken as AuthToken exposing (AuthToken)


type alias User =
    { username : Username
    , name : String
        --    , token : AuthToken
    }


decoder : Decoder User
decoder =
    Decode.map2
        User
        (Decode.at [ "username" ] usernameDecoder)
        (Decode.at [ "name" ] Decode.string)



--        (Decode.at [ "token" ] AuthToken.decoder)


encode : User -> Value
encode user =
    Encode.object
        [ "username" => encodeUsername user.username
        , "name" => Encode.string user.name
          --        , "token" => AuthToken.encode user.token
        ]



-- IDENTIFIERS --


type Username
    = Username String


usernameToString : Username -> String
usernameToString (Username username) =
    username


usernameDecoder : Decoder Username
usernameDecoder =
    Decode.map Username Decode.string


encodeUsername : Username -> Value
encodeUsername (Username username) =
    Encode.string username


usernameToHtml : Username -> Html msg
usernameToHtml (Username username) =
    Html.text username
