module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, src, style)
import Html.Events exposing (..)
import Json.Decode as Decode
import Http
import Phoenix
import Phoenix.Channel as Channel exposing (Channel)
import Phoenix.Socket as Socket exposing (Socket)
import Time exposing (Time)
import Json.Encode
import Json.Decode exposing (decodeValue)


-- MODEL


type alias Model =
    { search : String, results : List SpotifyTrack, user : Maybe User, token : String, error : Maybe String, currentTime : Time, tracks : List SpotifyTrack }


type alias User =
    { username : String, name : String }


type alias Flags =
    { token : String }


type ConnectionStatus
    = Connected
    | Disconnected
    | ScheduledReconnect { time : Time }


type State
    = JoiningLobby
    | JoinedLobby
    | LeavingLobby
    | LeftLobby


type Msg
    = NoOp
    | Search String
    | SearchResults (Result Http.Error (List SpotifyTrack))
    | SearchUpdated String
    | ConnectionStatusChanged ConnectionStatus
    | Tick Time
    | UpdateState State
    | UserConnected Json.Encode.Value
    | NewTrack Json.Encode.Value


type alias SpotifyTrack =
    { name : String, href : String, id : String, album : SpotifyAlbum, artists : List String }


type alias SpotifyAlbum =
    { name : String, images : List SpotifyImage }


type alias SpotifyImage =
    { height : Int, width : Int, url : String }


model : Model
model =
    { search = "", results = [], user = Nothing, token = "", error = Nothing, currentTime = 0, tracks = [] }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { model | token = flags.token }, Cmd.none )


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
            ( { model | search = term }
            , Cmd.none
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
        |> Socket.heartbeatIntervallSeconds 5
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
            tr [] [ td [] [ image ], td [] [ text track.name ], td [] [ text (String.join ", " track.artists) ] ]
    in
        tableRow


view : Model -> Html Msg
view model =
    let
        resultList =
            table []
                [ tbody []
                    (List.map result model.results)
                , thead
                    []
                    [ tr [] [ th [] [ text "Image" ], th [] [ text "Name" ], th [] [ text "Artist" ] ]
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
            table []
                [ tbody []
                    (List.map (\track -> (tr [] [ td [] [ text track.name ] ])) model.tracks)
                ]
    in
        div
            [ class "jumbotron" ]
            [ h3 [] [ text "Hello from Elm and Phoenix!" ]
            , error
            , p [] [ text greeting ]
            , input [ class "form-input", value model.search, onInput SearchUpdated ] []
            , button [ onClick search ] [ text "Search" ]
            , resultList
            , trackList
            ]



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
