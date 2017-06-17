module App.LoginForm.Msg exposing (..)

import Http


type Msg
    = Username String
    | Password String
    | SubmitLogin
    | SubmitLoginResponse (Result Http.Error String)
