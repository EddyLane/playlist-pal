module App.View exposing (..)

import Html exposing (..)
import App.Model exposing (..)
import App.Msg exposing (Msg)


--import App.Session.View as Session

import App.Events.View as Events
import App.LoginForm.View as LoginForm
import Bootstrap.Grid as Grid


page : Model -> Html Msg
page model =
    let
        session =
            model.session

        searchForm =
            model.searchForm

        events =
            model.events

        history =
            model.history

        initialising =
            session.initialising

        display =
            Events.view events history
    in
        if initialising then
            div [] [ text "Loading..." ]
        else
            case session.token of
                Just token ->
                    display

                _ ->
                    LoginForm.view model.loginForm


view : Model -> Html Msg
view model =
    Grid.container []
        [ Grid.row []
            [ Grid.col []
                [ page model
                ]
            ]
        ]
