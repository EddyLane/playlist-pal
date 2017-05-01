module App.SearchForm.View.View exposing (..)

import Html exposing (Html, div)
import App.SearchForm.Model exposing (Model)
import App.Msg exposing (..)
import App.SearchForm.View.Form exposing (searchForm)
import App.SearchForm.View.Results exposing (results)

view : Model -> Html Msg
view model =
    div [] [ searchForm model, results model.results ]