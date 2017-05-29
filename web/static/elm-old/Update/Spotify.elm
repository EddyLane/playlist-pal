module Update.Spotify exposing (..)

import Model.Spotify exposing (Model)
import Msg.Spotify exposing (..)
import Http

update : Msg -> Model -> Model
update msg spotify =
    case msg of

        SearchResults (Ok results) ->
            { spotify | results = results, error = Nothing }

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
                { spotify | error = Just message }

        _ -> spotify