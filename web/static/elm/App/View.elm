module App.View exposing (..)

import Html exposing (..)
import App.Model exposing (..)
import App.Msg exposing (Msg)
import App.Session.View as Session
import App.Events.View as Events
import Navigation
import Bootstrap.Grid as Grid


viewLocation : Navigation.Location -> Html msg
viewLocation location =
    li [] [ text (location.pathname ++ location.hash) ]


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
    in
        case (Maybe.withDefault Nothing (List.head history)) of
            Just (Event _) ->
                Events.view events history

            _ ->
                Events.view events history


view : Model -> Html Msg
view model =
    Grid.container []
        [ Grid.row []
            [ Grid.col []
                [ Session.view model.session
                , page model
                ]
            ]
        ]
