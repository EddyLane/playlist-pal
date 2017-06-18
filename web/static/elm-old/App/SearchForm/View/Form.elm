module App.SearchForm.View.Form exposing (..)

import Html exposing (..)
import Html.Events exposing (onInput)
import Html.Attributes exposing (class, for, placeholder, id, type_, value)
import App.SearchForm.Model exposing (Model)
import App.Msg exposing (..)
import App.SearchForm.Msg as SearchFormMsg


searchForm : Model -> Html Msg
searchForm model =
    let
        updateSearch q =
            q
                |> SearchFormMsg.UpdateSearch
                |> MsgForSearchForm
    in
        form []
            [ div [ class "form-group row" ]
                [ label [ for "search", class "col-sm-2 col-form-label col-form-label-lg" ] [ text "Search" ]
                , div [ class "col-sm-10" ]
                    [ input
                        [ type_ "search"
                        , class "form-control form-control-lg"
                        , id "search"
                        , placeholder "Search for track..."
                        , value model.term
                        , onInput updateSearch
                        ]
                        []
                    ]
                ]
            ]
