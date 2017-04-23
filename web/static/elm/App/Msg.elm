module App.Msg exposing (..)

import Time exposing (Time)
import App.Session.Msg as Session


type Msg
    = NoOp
    | Tick Time
    | MsgForSession Session.Msg
