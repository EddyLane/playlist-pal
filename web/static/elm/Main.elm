module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, src, style, type_, placeholder, id, for)
import Html.Events exposing (..)
import Json.Decode as Decode
import Http
import Phoenix
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Socket as Socket exposing (Socket)
import Phoenix.Push as Push
import Time exposing (Time, second)
import Json.Encode
import Json.Decode exposing (decodeValue)
import Debounce exposing (Debounce)

import Types exposing (..)

-- MODEL




model : Model
model =
    { search = "ddf"
    , results = []
    , user = Nothing
    , token = ""
    , error = Nothing
    , currentTime = 0
    , tracks = []
    , debounce = Debounce.init
    }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { model | token = flags.token }, Cmd.none )

-- This defines how the debouncer should work.
-- Choose the strategy for your use case.
debounceConfig : Debounce.Config Msg
debounceConfig =
  { strategy = Debounce.later (1 * second)
  , transform = DebounceMsg
  }


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

        SearchResults (Ok results) ->
            ( { model | results = results, error = Nothing }
            , Cmd.none
            )

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
                ( { model | error = Just message }
                , Cmd.none
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

        UserConnected user ->
            let
                u =
                    case decodeValue userDecoder user of
                        Ok newRecord ->
                            Just newRecord

                        Err _ ->
                            Nothing
            in
                ( { model | user = u }
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

-- MESSAGES


lobbySocket : String
lobbySocket =
    "ws://localhost:4000/socket/websocket"



--
--
--{-| Initialize a socket with the default heartbeat intervall of 30 seconds
---}


socket : String -> Socket Msg
socket accessToken =
    Socket.init lobbySocket
        |> Socket.withParams [ ( "guardian_token", accessToken ) ]
        |> Socket.heartbeatIntervallSeconds 20
        |> Socket.withDebug


lobby : Channel Msg
lobby =
    Channel.init "me"
        |> Channel.onJoin (\user -> UserConnected user)
        |> Channel.withDebug


tracks : Channel Msg
tracks =
    Channel.init "tracks"
        |> Channel.on "new_track" NewTrack
        |> Channel.withDebug



-- VIEW


result : SpotifyTrack -> Html Msg
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
                    (List.map result model.results)
                , thead
                    []
                    [ tr [] [ th [] [ text "Image" ], th [] [ text "Name" ], th [] [ text "Artist" ], th [] [] ]
                    ]
                ]

        search =
            Search model.search

        greeting =
            case model.user of
                Just user ->
                    "How are you " ++ user.name ++ "?"

                Nothing ->
                    ""

        error =
            case model.error of
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



--        div
--            [ class "jumbotron" ]
--            [ h3 [] [ text "Hello from Elm and Phoenix!" ]
--            , error
--            , p [] [ text greeting ]
--            , input [ class "form-input", value model.search, onInput SearchUpdated ] []
--            , button [ onClick search ] [ text "Search" ]
--            , resultList
--            , div [] [ text "hi" ]
--            ]
-- UPDATE


searchSpotify : String -> Cmd Msg
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
        Http.send SearchResults request


userDecoder : Decode.Decoder User
userDecoder =
    Decode.map2
        User
        (Decode.at [ "username" ] Decode.string)
        (Decode.at [ "name" ] Decode.string)


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


phoenixSubscription : Model -> Sub Msg
phoenixSubscription model =
    Phoenix.connect (socket model.token) [ lobby, tracks ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ phoenixSubscription model, Time.every Time.second Tick ]


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
