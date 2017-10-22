module Route exposing (Route(..), href, modifyUrl, fromLocation)

import UrlParser as Url exposing (parsePath, s, (</>), (<?>), string, oneOf, Parser)
import Navigation exposing (Location)
import Html exposing (Attribute)
import Html.Attributes as Attr
import UrlParser


type Route
    = Home
    | Authenticate (Maybe String)


route : Parser (Route -> a) a
route =
    oneOf
        [ Url.map Home (s "")
        , Url.map Authenticate (s "authenticate" <?> Url.stringParam "token")
        ]


-- INTERNAL --


routeToString : Route -> String
routeToString page =
    let
        pieces =
            case page of
                Home ->
                    []

                Authenticate maybeToken ->
                    [ "authenticate" ]

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