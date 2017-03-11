module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (class, value)
import Json.Decode as Decode
import Result


-- MODEL


type alias Model =
    { search : String }


init : ( Model, Cmd Msg )
init =
    ( { search = "Modest Mouse" }, Cmd.none )



-- MESSAGES


type Msg
    = NoOp
    | Search String


type alias SpotifyTrack =
    { name : String, href : String, id : String, album : SpotifyAlbum }


type alias SpotifyAlbum =
    { name : String, images : List SpotifyImage }


type alias SpotifyImage =
    { height : Int, width : Int, url : String }



-- VIEW


view : Model -> Html Msg
view model =
    div
        [ class "jumbotron" ]
        [ h3 [] [ text "Hello from Elm and Phoenix!" ]
        , p [] [ text "You good?" ]
        , input [ class "form-input", value model.search ] []
        , button [] [ text "Search" ]
        ]



-- UPDATE
--
--searchSpotify : Http.Request String
--searchSpotify =
--    Http.get "https://api.spotify.com/v1/search"


spotifyImageDecoder : Decode.Decoder SpotifyImage
spotifyImageDecoder =
    Decode.map3
        SpotifyImage
        (Decode.at [ "height" ] Decode.int)
        (Decode.at [ "width" ] Decode.int)
        (Decode.at [ "url" ] Decode.string)


spotifyAlbumDecoder : Decode.Decoder SpotifyAlbum
spotifyAlbumDecoder =
    Decode.map2
        SpotifyAlbum
        (Decode.at [ "name" ] Decode.string)
        (Decode.at [ "images" ] (Decode.list spotifyImageDecoder))


spotifyTrackDecoder : Decode.Decoder SpotifyTrack
spotifyTrackDecoder =
    Decode.map4
        SpotifyTrack
        (Decode.at [ "name" ] Decode.string)
        (Decode.at [ "href" ] Decode.string)
        (Decode.at [ "id" ] Decode.string)
        (Decode.at [ "album" ] spotifyAlbumDecoder)


spotifyItemResultDecoder : Decode.Decoder (List SpotifyTrack)
spotifyItemResultDecoder =
    Decode.map
        (\results -> results)
        (Decode.at [ "items" ] (Decode.list spotifyTrackDecoder))

spotifyTrackResultDecoder : Decode.Decoder (List SpotifyTrack)
spotifyTrackResultDecoder =
    Decode.map
        (\results -> results)
        (Decode.at [ "tracks" ] spotifyItemResultDecoder)

update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        NoOp ->
            ( model, Cmd.none )

        Search term ->
            ( model, Cmd.none )


jsonToDecode : String
jsonToDecode =
    """
    {"name": "Eddy"}
    """


spotifyJsonToDecode : String
spotifyJsonToDecode =
    """
{
  "tracks" : {
    "href" : "https://api.spotify.com/v1/search?query=Cupboard+Shaker&type=track&offset=0&limit=20",
    "items" : [ {
      "album" : {
        "album_type" : "album",
        "artists" : [ {
          "external_urls" : {
            "spotify" : "https://open.spotify.com/artist/1ng3xz2dyz57Z1WpnzM2G7"
          },
          "href" : "https://api.spotify.com/v1/artists/1ng3xz2dyz57Z1WpnzM2G7",
          "id" : "1ng3xz2dyz57Z1WpnzM2G7",
          "name" : "Pogo",
          "type" : "artist",
          "uri" : "spotify:artist:1ng3xz2dyz57Z1WpnzM2G7"
        } ],
        "available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TR", "TW", "US", "UY" ],
        "external_urls" : {
          "spotify" : "https://open.spotify.com/album/2Hog1V8mdTWKhCYqI5paph"
        },
        "href" : "https://api.spotify.com/v1/albums/2Hog1V8mdTWKhCYqI5paph",
        "id" : "2Hog1V8mdTWKhCYqI5paph",
        "images" : [ {
          "height" : 640,
          "url" : "https://i.scdn.co/image/868668e90858ea60a9a3928a454eb934b8fc926f",
          "width" : 640
        }, {
          "height" : 300,
          "url" : "https://i.scdn.co/image/d5739a1afeaea5f64f85136fed61c4e7729e14ea",
          "width" : 300
        }, {
          "height" : 64,
          "url" : "https://i.scdn.co/image/25436af6e1a7e9af7040eee5f3fb4d019b4c821c",
          "width" : 64
        } ],
        "name" : "Weightless",
        "type" : "album",
        "uri" : "spotify:album:2Hog1V8mdTWKhCYqI5paph"
      },
      "artists" : [ {
        "external_urls" : {
          "spotify" : "https://open.spotify.com/artist/1ng3xz2dyz57Z1WpnzM2G7"
        },
        "href" : "https://api.spotify.com/v1/artists/1ng3xz2dyz57Z1WpnzM2G7",
        "id" : "1ng3xz2dyz57Z1WpnzM2G7",
        "name" : "Pogo",
        "type" : "artist",
        "uri" : "spotify:artist:1ng3xz2dyz57Z1WpnzM2G7"
      } ],
      "available_markets" : [ "AD", "AR", "AT", "AU", "BE", "BG", "BO", "BR", "CA", "CH", "CL", "CO", "CR", "CY", "CZ", "DE", "DK", "DO", "EC", "EE", "ES", "FI", "FR", "GB", "GR", "GT", "HK", "HN", "HU", "ID", "IE", "IS", "IT", "JP", "LI", "LT", "LU", "LV", "MC", "MT", "MX", "MY", "NI", "NL", "NO", "NZ", "PA", "PE", "PH", "PL", "PT", "PY", "SE", "SG", "SK", "SV", "TR", "TW", "US", "UY" ],
      "disc_number" : 1,
      "duration_ms" : 203891,
      "explicit" : false,
      "external_ids" : {
        "isrc" : "TCACW1622192"
      },
      "external_urls" : {
        "spotify" : "https://open.spotify.com/track/0IK7mnSCms1ynDj2RwrBcr"
      },
      "href" : "https://api.spotify.com/v1/tracks/0IK7mnSCms1ynDj2RwrBcr",
      "id" : "0IK7mnSCms1ynDj2RwrBcr",
      "name" : "Cupboard Shaker",
      "popularity" : 34,
      "preview_url" : "https://p.scdn.co/mp3-preview/caea5ceaebb8728a15d13f2026877b12da57fe9e?cid=null",
      "track_number" : 2,
      "type" : "track",
      "uri" : "spotify:track:0IK7mnSCms1ynDj2RwrBcr"
    } ],
    "limit" : 20,
    "next" : null,
    "offset" : 0,
    "previous" : null,
    "total" : 1
  }
}
    """


main : Html a
main =
    case (Decode.decodeString spotifyTrackResultDecoder spotifyJsonToDecode) of
        Result.Ok list ->
            case List.head list of
                Just firstResult ->
                    text firstResult.name
                Nothing ->
                    text "nope"

        Result.Err err ->
            text "no"



--
--main : Program Never Model Msg
--main =
--    program
--        { init = init
--        , view = view
--        , update = update
--        , subscriptions = (always Sub.none)
--        }
