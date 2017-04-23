module App.Session.Msg exposing (..)

import App.Session.Model exposing (User)
import Json.Encode as Encode

type Msg
    = UserConnected Encode.Value