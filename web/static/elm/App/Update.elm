module App.Update exposing (..)

import App.Msg exposing (..)
import App.Model exposing (..)
import App.Session.Update as Session
import App.SearchForm.Update as SearchForm
import App.Events.Update as Events
import App.LoginForm.Update as LoginForm
import App.Events.Msg as EventsMsg
import UrlParser as Url exposing (parseHash)


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

        MsgForLoginForm msg ->
            let
                ( loginForm, cmd ) =
                    LoginForm.update msg model.loginForm
            in
                ( { model | loginForm = loginForm }, cmd )

        UrlChange location ->
            ( { model
                | history = Url.parseHash route location :: model.history
              }
            , Cmd.none
            )

        Tick time ->
            let
                ( events, cmd ) =
                    Events.update (EventsMsg.Tick time) model.events
            in
                ( { model | events = events }, cmd )

        _ ->
            ( model, Cmd.none )
