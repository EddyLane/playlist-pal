module Route exposing (Route(..), href, modifyUrl, fromLocation)

import Data.Playlist as Playlist
import UrlParser as Url exposing (parsePath, s, (</>), string, oneOf, Parser)
import Navigation exposing (Location)
import Html exposing (Attribute)
import Html.Attributes as Attr


type Route
    = Home
    | Login
    | Logout
    | Register
    | Playlists
    | Playlist Playlist.Slug


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home (s "")
        , Url.map Login (s "login")
        , Url.map Logout (s "logout")
        , Url.map Register (s "register")
        , Url.map Playlists (s "playlists")
        , Url.map Playlist (s "playlist" </> Playlist.slugParser)
        ]



-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Login ->
                    [ "login" ]

                Logout ->
                    [ "logout" ]

                Playlists ->
                    [ "playlists" ]

                Register ->
                    [ "register" ]

                Playlist slug ->
                    [ "playlist", Playlist.slugToString slug ]

    in
        "/" ++ (String.join "/" pieces)


-- PUBLIC HELPERS --


href : Route -> Attribute msg
href route =
    Attr.href (routeToString route)


modifyUrl : Route -> Cmd msg
modifyUrl =
    routeToString >> Navigation.modifyUrl


fromLocation : Location -> Maybe Route
fromLocation location =
    let
        debugLocation =
            Debug.log "location" location
    in
        if String.isEmpty debugLocation.pathname then
            Just Home
        else
            parsePath route location