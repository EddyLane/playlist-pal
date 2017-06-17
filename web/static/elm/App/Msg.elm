module App.Msg exposing (..)

import Time exposing (Time)
import App.Session.Msg as Session
import App.SearchForm.Msg as SearchForm
import App.Events.Msg as Events
import App.LoginForm.Msg as LoginForm
import Navigation
import Http


type Msg
    = NoOp
    | Tick Time
    | NewUrl String
    | UrlChange Navigation.Location
    | MsgForSession Session.Msg
    | MsgForSearchForm SearchForm.Msg
    | MsgForEvents Events.Msg
    | MsgForLoginForm LoginForm.Msg
