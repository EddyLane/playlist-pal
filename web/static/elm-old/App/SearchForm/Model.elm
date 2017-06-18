module App.SearchForm.Model exposing (..)

import Debounce exposing (Debounce)
import Json.Decode as Decode
import App.SearchForm.Msg as SearchFormMsg
import App.Msg exposing (..)
import Time exposing (second)


type alias Model =
    { term : String
    , results : List SearchFormMsg.SpotifyTrack
    , error : Maybe String
    , debounce : Debounce String
    }


initialModel : Model
initialModel =
    { term = ""
    , results = []
    , error = Nothing
    , debounce = Debounce.init
    }


spotifyTrackDecoder : Decode.Decoder SearchFormMsg.SpotifyTrack
spotifyTrackDecoder =
    Decode.map5
        SearchFormMsg.SpotifyTrack
        (Decode.at [ "name" ] Decode.string)
        (Decode.at [ "href" ] Decode.string)
        (Decode.at [ "id" ] Decode.string)
        (Decode.at [ "album" ]
            (Decode.map2
                SearchFormMsg.SpotifyAlbum
                (Decode.at [ "name" ] Decode.string)
                (Decode.at [ "images" ]
                    (Decode.list
                        (Decode.map3
                            SearchFormMsg.SpotifyImage
                            (Decode.at [ "height" ] Decode.int)
                            (Decode.at [ "width" ] Decode.int)
                            (Decode.at [ "url" ] Decode.string)
                        )
                    )
                )
            )
        )
        (Decode.at [ "artists" ]
            (Decode.list
                (Decode.at [ "name" ] Decode.string)
            )
        )


debounceConfig : Debounce.Config Msg
debounceConfig =
    { strategy = Debounce.later (1 * second)
    , transform = (\msg -> SearchFormMsg.DebounceMsg msg |> MsgForSearchForm)
    }
