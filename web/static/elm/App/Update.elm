module App.Update exposing (..)

import App.Msg exposing (..)
import App.Model exposing (Model)
import App.Session.Update as Session
import App.SearchForm.Update as SearchForm

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgForSession msg ->
            ( { model
                | session = Session.update msg model.session
              }
            , Session.updateCmd msg
            )

        MsgForSearchForm msg ->
            ( { model
                | searchForm = SearchForm.update msg model.searchForm
              }
            , Cmd.none
            )
        _ ->
            ( model, Cmd.none )
