module App.Update exposing (..)

import App.Msg exposing (..)
import App.Model exposing (Model)
import App.Session.Update as Session
import App.SearchForm.Update as SearchForm
import App.Events.Update as Events


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        MsgForSession msg ->
            let
                ( session, cmd ) =
                    Session.update msg model.session
            in
                ( { model | session = session }, cmd )

        MsgForSearchForm msg ->
            let
                ( searchForm, cmd ) =
                    SearchForm.update msg model.searchForm
            in
                ( { model | searchForm = searchForm }, cmd )

        MsgForEvents msg ->
            let
                ( events, cmd ) =
                    Events.update msg model.events
            in
                ( { model | events = events }, cmd )

        _ ->
            ( model, Cmd.none )
