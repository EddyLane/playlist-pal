module App.Model exposing (..)

import App.Session.Model as Session

type alias Model =
    { session: Session.Model
    }

type alias Flags =
    { token : String }

initialModel : Flags -> Model
initialModel flags =
    { session = (Session.initialModel flags.token)
    }

init : Flags -> ( Model, Cmd a )
init flags =
    ((initialModel flags), Cmd.none )