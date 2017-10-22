module Data.User exposing (User, Username, decoder, usernameToString, usernameToHtml, usernameDecoder, encode)

import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Html exposing (Html)
import Util exposing ((=>))
import Data.AuthToken as AuthToken exposing (AuthToken)


type alias User =
    { username : Username
    , image : Maybe String
    }


decoder : Decoder User
decoder =
    Decode.map2
        User
        (Decode.at [ "spotify_id" ] usernameDecoder)
        (Decode.at [ "image" ] (Decode.nullable Decode.string))


encode : User -> Value
encode user =
    let
        image =
            case user.image of
                Just img ->
                    Encode.string img

                Nothing ->
                    Encode.null
    in
        Encode.object
            [ "spotify_id" => encodeUsername user.username
            , "image" => image
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
