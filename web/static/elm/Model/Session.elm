module Model.Session exposing (..)

type alias User =
    { username : String, name : String }

type alias Model =
    { user : Maybe User
    , token: String
    }

model : Model
model =
    { user = Nothing
    , token = ""
    }