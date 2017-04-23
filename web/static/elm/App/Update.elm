module App.Update exposing (..)

import App.Msg exposing (..)
import App.Model exposing (Model)
import App.Session.Update as Session


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgForSession msg ->
            ( { model
                | session = Session.update msg model.session
              }
            , Session.updateCmd msg
            )

        _ ->
            ( model, Cmd.none )
