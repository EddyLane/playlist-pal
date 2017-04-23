module App.Update exposing (..)

import App.Msg exposing (..)
import App.Model exposing (Model)
import App.Session.Update as Session

update : Msg -> Model -> (Model, Cmd Msg)
update msg model =
    ({ model
        | session = Session.update msg model.session
    }, Cmd.none)