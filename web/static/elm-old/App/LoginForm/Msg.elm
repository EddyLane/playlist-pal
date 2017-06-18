module App.LoginForm.Msg exposing (..)

import Http


type Msg
    = SetUsername String
    | SetPassword String
    | SubmitLogin
    | SubmitLoginResponse (Result Http.Error String)
