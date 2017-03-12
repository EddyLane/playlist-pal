module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value, src, style)
import Html.Events exposing (..)
import Json.Decode as Decode
import Http


-- MODEL


type alias Model =
    { search : String, results : List SpotifyTrack, user : User }

type alias User =
    { username: String, name: String }

type alias Flags =
    { user: User }


model : Model
model =
    { search = "", results = [], user = { username = "", name = "" } }


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { model | user = flags.user }, Cmd.none )

-- MESSAGES


type Msg
    = NoOp
    | Search String
    | SearchResults (Result Http.Error (List SpotifyTrack))
    | SearchUpdated String


type alias SpotifyTrack =
    { name : String, href : String, id : String, album : SpotifyAlbum }


type alias SpotifyAlbum =
    { name : String, images : List SpotifyImage }


type alias SpotifyImage =
    { height : Int, width : Int, url : String }



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
    in
        li [] [ image, text track.name ]


view : Model -> Html Msg
view model =
    let
        resultList =
            ul [] (List.map result model.results)

        search =
            Search model.search

        greeting =
            "How are you " ++ model.user.name ++ "?"
    in
        div
            [ class "jumbotron" ]
            [ h3 [] [ text "Hello from Elm and Phoenix!" ]
            , p [] [ text greeting ]
            , input [ class "form-input", value model.search, onInput SearchUpdated ] []
            , button [ onClick search ] [ text "Search" ]
            , resultList
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


spotifyTrackDecoder : Decode.Decoder SpotifyTrack
spotifyTrackDecoder =
    Decode.map4
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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Search term ->
            ( model, (searchSpotify term) )

        SearchUpdated term ->
            ( { model | search = term }, Cmd.none )

        SearchResults (Ok results) ->
            ( { model | results = results }
            , Cmd.none
            )

        SearchResults (Err _) ->
            ( model, Cmd.none )


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = (always Sub.none)
        }
