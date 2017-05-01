module App.SearchForm.View.Results exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)

import App.SearchForm.Msg exposing (SpotifyTrack)
import App.Msg exposing (..)

result : SpotifyTrack -> Html Msg
result track =
    let
        image =
            case List.head track.album.images of
                Just imageObj ->
                    (img [ style [ ( "width", "100px" ) ], src imageObj.url ] [])

                Nothing ->
                    div [] []
    in
        tr []
            [ td [] [ image ]
            , td [] [ text track.name ]
            , td [] [ text (String.join ", " track.artists) ]
            , td [] [ button [] [ text "+" ] ]
            ]

results: List SpotifyTrack -> Html Msg
results results =
    table [ class "table table-striped" ]
        [ tbody []
            (List.map result results)
        , thead
            []
            [ tr [] [ th [] [ text "Image" ], th [] [ text "Name" ], th [] [ text "Artist" ], th [] [] ]
            ]
        ]