module Update.Main exposing (..)

import Msg.Main exposing (..)
import Model.Main exposing (..)
import Debounce exposing (Debounce)
import Time exposing (Time, second)
import Http
import Json.Encode
import Json.Decode exposing (decodeValue)
import Json.Decode as Decode
import Phoenix
import Phoenix.Push as Push
import Update.Session as Session
import Update.Spotify as Spotify
import Model.Spotify exposing (SpotifyTrack, SpotifyImage, SpotifyAlbum)
import Msg.Spotify

spotifyTrackDecoder : Decode.Decoder SpotifyTrack
spotifyTrackDecoder =
    Decode.map5
        SpotifyTrack
        (Decode.at [ "name" ] Decode.string)
        (Decode.at [ "href" ] Decode.string)
        (Decode.at [ "id" ] Decode.string)
        (Decode.at [ "album" ]
            (Decode.map2
                SpotifyAlbum
                (Decode.at [ "name" ] Decode.string)
                (Decode.at [ "images" ]
                    (Decode.list
                        (Decode.map3
                            SpotifyImage
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
  , transform = DebounceMsg
  }


lobbySocket : String
lobbySocket =
    "ws://localhost:4000/socket/websocket"

searchSpotify : String -> Cmd Msg.Spotify.Msg
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
        Http.send Msg.Spotify.SearchResults request

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model
            , Cmd.none
            )

        Search term ->
            ( model
            , (searchSpotify term)
            )

        SearchUpdated term ->
            let
                (debounce, cmd) = Debounce.push debounceConfig term model.debounce
            in
                ( { model | search = term, debounce = debounce }
                , cmd
                )

        ConnectionStatusChanged status ->
            ( model
            , Cmd.none
            )

        Tick time ->
            { model | currentTime = time } ! []

        UpdateState _ ->
            ( model
            , Cmd.none
            )

        NewTrack track ->
            let
                updatedTracks =
                    case decodeValue spotifyTrackDecoder track of
                        Ok newTrack ->
                            newTrack :: model.tracks

                        Err _ ->
                            model.tracks
            in
                ( { model | tracks = updatedTracks }
                , Cmd.none
                )

        AddTrack track ->
            let
                push =
                    Push.init "tracks" "new_track"
                        |> Push.withPayload (Json.Encode.string track.id)
            in
                ( model
                , Phoenix.push lobbySocket push
                )

        DebounceMsg msg ->
          let
            (debounce, cmd) =
              Debounce.update
                debounceConfig
                (Debounce.takeLast searchSpotify)
                msg
                model.debounce
          in
            { model | debounce = debounce } ! [ cmd ]


        MsgForSession msg ->
            ( { model | session = Session.update msg model.session }, Cmd.none)


        MsgForSpotify msg ->
            ( { model | spotify = Spotify.update msg model.spotify }, Cmd.none)