module App.View exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, src, style, type_, placeholder, id, for)
import App.Model exposing (Model)
import App.Msg exposing (Msg)
import App.Session.View as Session
import App.Events.View as Events


view : Model -> Html Msg
view model =
    let
        session =
            model.session

        searchForm =
            model.searchForm

        events =
            model.events
    in
        div [ class "container" ]
            [ div [] [ Session.view session ]
            , div [ class "row" ]
                [ div [ class "col-sm-9" ]
                    [ Events.view events
                      --                    SearchForm.view searchForm
                    ]
                ]
            ]
