module App.SearchForm.Update exposing (..)

import App.SearchForm.Model exposing (Model, spotifyTrackDecoder, debounceConfig)
import App.SearchForm.Msg exposing (..)
import Json.Decode as Decode exposing (decodeValue)
import App.Msg as BaseMsg
import Http
import Debounce exposing (Debounce)


searchSpotify : String -> Cmd BaseMsg.Msg
searchSpotify term =
    let
        url =
            "https://api.spotify.com/v1/search?type=track&q=" ++ Http.encodeUri (term)

        request =
            Http.get url
                (Decode.list spotifyTrackDecoder
                    |> Decode.at [ "items" ]
                    |> Decode.at [ "tracks" ]
                )
    in
        Http.send (\result -> SearchResults result |> BaseMsg.MsgForSearchForm) request


update : Msg -> Model -> ( Model, Cmd BaseMsg.Msg )
update msg searchForm =
    case msg of
        UpdateSearch term ->
            let
                ( debounce, cmd ) =
                    Debounce.push debounceConfig term searchForm.debounce
            in
                ( { searchForm | term = term, debounce = debounce }, cmd )

        DebounceMsg msg ->
            let
                ( debounce, cmd ) =
                    Debounce.update
                        debounceConfig
                        (Debounce.takeLast searchSpotify)
                        msg
                        searchForm.debounce
            in
                { searchForm | debounce = debounce } ! [ cmd ]

        SearchResults (Ok results) ->
            ( { searchForm | results = results, error = Nothing }, Cmd.none )

        SearchResults (Err err) ->
            let
                message =
                    case err of
                        Http.Timeout ->
                            "Timeout"

                        Http.BadUrl _ ->
                            "BadUrl"

                        Http.NetworkError ->
                            "NetworkError"

                        Http.BadStatus _ ->
                            "BadStatus"

                        Http.BadPayload _ _ ->
                            "BadPayload"
            in
                ( { searchForm | error = Just message }, Cmd.none )


updateCmd : Msg -> Cmd BaseMsg.Msg
updateCmd msg =
    Cmd.none
