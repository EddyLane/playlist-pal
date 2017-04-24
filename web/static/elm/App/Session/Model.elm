module App.Session.Model exposing (..)

import Json.Decode as Decode exposing (decodeValue)


type alias User =
    { username : String
    , name : String
    }


type alias Model =
    { user : Maybe User
    , token : String
    }


userDecoder : Decode.Decoder User
userDecoder =
    Decode.map2
        User
        (Decode.at [ "username" ] Decode.string)
        (Decode.at [ "name" ] Decode.string)


initialModel : String -> Model
initialModel token =
    { user = Nothing
    , token = token
    }
