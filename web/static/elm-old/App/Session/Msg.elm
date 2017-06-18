module App.Session.Msg exposing (..)

import App.Session.Model exposing (User)
import Json.Encode as Encode
import Http


type Msg
    = UserConnected Encode.Value
    | SetToken (Result Http.Error String)
