module App.LoginForm.Model exposing (..)


type alias Model =
    { username : String
    , password : String
    , error : Maybe String
    , submitting : Bool
    }


initialModel : Model
initialModel =
    { username = ""
    , password = ""
    , error = Nothing
    , submitting = False
    }
