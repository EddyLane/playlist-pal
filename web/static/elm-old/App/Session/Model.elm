module App.Session.Model exposing (..)

import Json.Decode as Decode exposing (decodeValue)


type alias User =
    { username : String
    , name : String
    }


type alias Model =
    { user : Maybe User
    , token : Maybe String
    , initialising : Bool
    }


userDecoder : Decode.Decoder User
userDecoder =
    Decode.map2
        User
        (Decode.at [ "username" ] Decode.string)
        (Decode.at [ "name" ] Decode.string)


initialModel : Model
initialModel =
    { user = Nothing
    , token = Nothing
    , initialising = True
    }
