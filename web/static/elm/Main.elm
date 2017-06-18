module Main exposing (main)

import Navigation exposing (Location)
import Route exposing (Route)
import Data.Session as Session exposing (Session)
import Page.Errored as Errored exposing (PageLoadError)
import Views.Page as Page exposing (ActivePage)
import Json.Decode as Decode exposing (Value)
import Task
import Util exposing ((=>))
import Html exposing (..)

type Page
    = Blank
    | NotFound
    | Errored PageLoadError

type PageState
    = Loaded Page
    | TransitioningFrom Page

-- MODEL --

type alias Model =
    { session : Session
    , pageState : PageState
    }

init : Value -> Location -> ( Model, Cmd Msg )
init val location =
    setRoute (Route.fromLocation location)
        { pageState = Loaded initialPage
        , session = { user = Nothing }
        }

initialPage : Page
initialPage =
    Blank

view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            viewPage model.session False page

        TransitioningFrom page ->
            viewPage model.session True page


viewPage : Session -> Bool -> Page -> Html Msg
viewPage session isLoading page =
    let
        frame =
            Page.frame isLoading session.user
    in
        case page of

            _ ->
                -- This is for the very intiial page load, while we are loading
                -- data via HTTP. We could also render a spinner here.
                Html.text ""
                    |> frame Page.Other


-- SUBSCRIPTIONS --
-- Note: we aren't currently doing any page subscriptions, but I thought it would
-- be a good idea to put this in here as an example. If I were actually
-- maintaining this in production, I wouldn't bother until I needed this!


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ pageSubscriptions (getPage model.pageState)
--        , Sub.map SetUser sessionChange
        ]


--sessionChange : Sub (Maybe User)
--sessionChange =
--    Ports.onSessionChange (Decode.decodeValue User.decoder >> Result.toMaybe)


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page


pageSubscriptions : Page -> Sub Msg
pageSubscriptions page =
    case page of
        _ ->
            Sub.none

-- UPDATE --


type Msg
    = SetRoute (Maybe Route)

setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        transition toMsg task =
            { model | pageState = TransitioningFrom (getPage model.pageState) }
                => Task.attempt toMsg task

        errored =
            pageErrored model
    in
        case maybeRoute of
            _ ->
                { model | pageState = Loaded NotFound } => Cmd.none

pageErrored : Model -> ActivePage -> String -> ( Model, Cmd msg )
pageErrored model activePage errorMessage =
    let
        error =
            Errored.pageLoadError activePage errorMessage
    in
        { model | pageState = Loaded (Errored error) } => Cmd.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    updatePage (getPage model.pageState) msg model


updatePage : Page -> Msg -> Model -> ( Model, Cmd Msg )
updatePage page msg model =
    let
        session =
            model.session

        toPage toModel toMsg subUpdate subMsg subModel =
            let
                ( newModel, newCmd ) =
                    subUpdate subMsg subModel
            in
                ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )

        errored =
            pageErrored model
    in
        case ( msg, page ) of
            ( SetRoute route, _ ) ->
                setRoute route model

--            ( _, NotFound ) ->
--                -- Disregard incoming messages when we're on the
--                -- NotFound page.
--                model => Cmd.none
--
--            ( _, _ ) ->
--                -- Disregard incoming messages that arrived for the wrong page
--                model => Cmd.none

-- MAIN --


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }