module App.Msg exposing (..)

import Time exposing (Time)
import App.Session.Msg as Session
import App.SearchForm.Msg as SearchForm
import App.Events.Msg as Events

type Msg
    = NoOp
    | Tick Time
    | MsgForSession Session.Msg
    | MsgForSearchForm SearchForm.Msg
    | MsgForEvents Events.Msg