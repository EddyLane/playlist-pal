module App.Update exposing (..)

import App.Msg exposing (..)
import App.Model exposing (Model)
import App.Session.Update as Session
import App.SearchForm.Update as SearchForm

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgForSession msg ->
            let
                (session, cmd) = Session.update msg model.session
            in
                ({ model | session = session }, cmd)

        MsgForSearchForm msg ->
            let
                (searchForm, cmd) = SearchForm.update msg model.searchForm
            in
                ({ model | searchForm = searchForm }, cmd)

        _ ->
            ( model, Cmd.none )
