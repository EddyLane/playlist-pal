module App.Model exposing (..)

import App.Session.Model as Session
import App.SearchForm.Model as SearchForm
import App.Events.Model as Events
import App.Events.Update exposing (getEvents)
import App.Msg exposing (Msg)


type alias Model =
    { session : Session.Model
    , searchForm : SearchForm.Model
    , events : Events.Model
    }


type alias Flags =
    { token : String }


initialModel : Flags -> Model
initialModel flags =
    { session = (Session.initialModel flags.token)
    , searchForm = SearchForm.initialModel
    , events = Events.initialModel
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( (initialModel flags), Cmd.none )
