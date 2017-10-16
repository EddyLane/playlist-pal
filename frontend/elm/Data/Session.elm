module Data.Session exposing (Session, decoder, encode, initialModel)

import Data.User as User exposing (User)
import Data.AuthToken as AuthToken exposing (AuthToken)
import Json.Decode as Decode exposing (Decoder)
import Json.Encode as Encode exposing (Value)
import Util exposing ((=>))


type alias Session =
    { user : Maybe User
    , token : Maybe AuthToken
    }


initialModel : Session
initialModel =
    { user = Nothing
    , token = Nothing
    }


decoder : Decoder Session
decoder =
    Decode.map2
        Session
        (Decode.maybe <| Decode.at [ "user" ] User.decoder)
        (Decode.maybe <| Decode.at [ "token" ] AuthToken.decoder)


encode : Session -> Value
encode session =
    let
        nullOr maybeProperty encoder =
            Maybe.andThen (Just << encoder) maybeProperty
                |> Maybe.withDefault Encode.null
    in
        Encode.object
            [ "user" => nullOr session.user User.encode
            , "token" => nullOr session.token AuthToken.encode
            ]