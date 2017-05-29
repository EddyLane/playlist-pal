module View.Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, src, style, type_, placeholder, id, for)
import Html.Events exposing (..)
import Model.Main exposing (..)
import Msg.Main exposing (..)
import Model.Spotify as Spotify


result : Spotify.SpotifyTrack -> Html Msg
result track =
    let
        image =
            case List.head track.album.images of
                Just imageObj ->
                    (img [ style [ ( "width", "100px" ) ], src imageObj.url ] [])

                Nothing ->
                    div [] []

        tableRow =
            tr []
                [ td [] [ image ]
                , td [] [ text track.name ]
                , td [] [ text (String.join ", " track.artists) ]
                , td [] [ button [ onClick (AddTrack track) ] [ text "+" ] ]
                ]
    in
        tableRow

view : Model -> Html Msg
view model =
    let
        resultList =
            table [ class "table table-striped" ]
                [ tbody []
                    (List.map result model.spotify.results)
                , thead
                    []
                    [ tr [] [ th [] [ text "Image" ], th [] [ text "Name" ], th [] [ text "Artist" ], th [] [] ]
                    ]
                ]

        search =
            Search model.search

        greeting =
            case model.session.user of
                Just user ->
                    "How are you " ++ user.name ++ "?"

                Nothing ->
                    ""

        error =
            case model.spotify.error of
                Just error ->
                    (p [] [ text error ])

                Nothing ->
                    div [] []

        trackList =
            table [ class "table table-striped" ]
                [ tbody []
                    (List.map (\track -> (tr [] [ td [] [ text track.name ] ])) model.tracks)
                ]

        rightPlaylist =
            ul [ class "list-group" ]
                [ li [ class "list-group-item active" ] [ text "Recently added..." ]
                , li [ class "list-group-item list-group-item-action" ] [ text "Two" ]
                , li [ class "list-group-item list-group-item-action" ] [ text "Three" ]
                ]

    in
        div [ class "container" ]
            [ div [ class "row" ]
                [ div [ class "col-sm-9" ]
                    [ form []
                        [ div [ class "form-group row" ]
                            [ label [ for "search", class "col-sm-2 col-form-label col-form-label-lg" ] [ text "Track" ]
                            , div [ class "col-sm-10" ]
                                [ input [ type_ "search", class "form-control form-control-lg", id "search", placeholder "Search for track...", value model.search, onInput SearchUpdated ] []
                                ]
                            ]
                        ]
                    , resultList
                    ]
                , div [ class "col-sm-3" ] [ rightPlaylist ]
                ]
            ]
