module App.Model exposing (..)

import App.Session.Model as Session
import App.SearchForm.Model as SearchForm


type alias Model =
    { session : Session.Model
    , searchForm : SearchForm.Model
    }


type alias Flags =
    { token : String }


initialModel : Flags -> Model
initialModel flags =
    { session = (Session.initialModel flags.token)
    , searchForm = SearchForm.initialModel
    }


init : Flags -> ( Model, Cmd a )
init flags =
    ( (initialModel flags), Cmd.none )
