module Main exposing (main)

import Navigation exposing (Location)
import Route exposing (Route)
import Data.Session as Session exposing (Session)
import Data.User as User exposing (User, Username, usernameToString)
import Page.Errored as Errored exposing (PageLoadError)
import Views.Page as Page exposing (ActivePage)
import Json.Decode as Decode exposing (Value)
import Page.Login as Login
import Page.Events as Events
import Page.Register as Register
import Task
import Util exposing ((=>))
import Html exposing (..)
import Ports
import Page.Header as Header exposing (Model, initialState, subscriptions)
import Phoenix.Socket
import Channels.UserSocket exposing (initPhxSocket)
import Json.Encode as Encode
import Json.Decode as Decode
import Data.Event

type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | Login Login.Model
    | Register Register.Model
    | Events Events.Model


type PageState
    = Loaded Page
    | TransitioningFrom Page



-- MODEL --


type alias Model =
    { session : Session
    , pageState : PageState
    , headerState : Header.Model
    , phxSocket : Phoenix.Socket.Socket Msg
    }


init : Value -> Location -> ( Model, Cmd Msg )
init val location =
    let
        ( headerModel, headerCmd ) =
            Header.initialState

        ( pageModel, pageCmd ) =
            setRoute (Route.fromLocation location)
                { pageState = Loaded initialPage
                , session = { user = decodeUserFromJson val }
                , headerState = headerModel
                , phxSocket = initPhxSocket
                }

        commands =
            Cmd.batch
                [ pageCmd
                , Cmd.map HeaderMsg headerCmd
                ]
    in
        pageModel
            => commands


decodeUserFromJson : Value -> Maybe User
decodeUserFromJson json =
    json
        |> Decode.decodeValue Decode.string
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString User.decoder >> Result.toMaybe)


initialPage : Page
initialPage =
    Blank


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            div []
                [ viewHeader model False page
                , viewPage model False page
                ]

        TransitioningFrom page ->
            div []
                [ viewHeader model True page
                , viewPage model True page
                ]


pageToActivePage : Page -> ActivePage
pageToActivePage page =
    case page of
        Events _ ->
            Page.Events

        Login _ ->
            Page.Login

        Register _ ->
            Page.Register

        _ ->
            Page.Other


viewHeader : Model -> Bool -> Page -> Html Msg
viewHeader model isLoading page =
    page
        |> pageToActivePage
        |> Header.viewHeader model.headerState model.session.user isLoading
        |> Html.map HeaderMsg


viewPage : Model -> Bool -> Page -> Html Msg
viewPage model isLoading page =
    let
        session =
            model.session

        user =
            session.user

        frame =
            Page.frame isLoading user

        activePage =
            pageToActivePage page
    in
        case page of
            Login subModel ->
                Login.view session subModel
                    |> frame activePage
                    |> Html.map LoginMsg

            Register subModel ->
                Register.view session subModel
                    |> frame activePage
                    |> Html.map RegisterMsg

            Events subModel ->
                Events.view session subModel
                    |> frame activePage
                    |> Html.map EventsMsg

            _ ->
                -- This is for the very intiial page load, while we are loading
                -- data via HTTP. We could also render a spinner here.
                Html.text ""
                    |> frame activePage



-- SUBSCRIPTIONS --
-- Note: we aren't currently doing any page subscriptions, but I thought it would
-- be a good idea to put this in here as an example. If I were actually
-- maintaining this in production, I wouldn't bother until I needed this!


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        navbarState =
            model.headerState.navbarState

        user =
            model.session.user

        header =
            Header.subscriptions model.headerState
                |> Sub.map HeaderMsg

        page =
            getPage model.pageState
    in
        Sub.batch
            [ pageSubscriptions page model
            , Sub.map SetUser sessionChange
            , header
            , Phoenix.Socket.listen model.phxSocket PhoenixMsg
            ]


sessionChange : Sub (Maybe User)
sessionChange =
    Ports.onSessionChange (Decode.decodeValue User.decoder >> Result.toMaybe)


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        TransitioningFrom page ->
            page


pageSubscriptions : Page -> Model -> Sub Msg
pageSubscriptions page model =
    case page of
        Events _ ->
            Sub.none

        _ ->
            Sub.none



-- UPDATE --


type Msg
    = SetRoute (Maybe Route)
    | LoginMsg Login.Msg
    | RegisterMsg Register.Msg
    | EventsMsg Events.Msg
    | EventsLoaded (Result PageLoadError Encode.Value)
    | HeaderMsg Header.Msg
    | SetUser (Maybe User)
    | NoOp
    | PhoenixMsg (Phoenix.Socket.Msg Msg)


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let

        page =
            getPage model.pageState

        activePage =
            page |> pageToActivePage

        transition toMsg task =
            { model | pageState = TransitioningFrom (getPage model.pageState) }
                => Task.attempt toMsg task

        errored =
            pageErrored model
    in
        case maybeRoute of
            Just (Route.Login) ->
                { model | pageState = Loaded (Login Login.initialModel) } => Cmd.none

            Just (Route.Register) ->
                { model | pageState = Loaded (Register Register.initialModel) } => Cmd.none

            Just (Route.Events) ->
                case model.session.user of
                    Just user ->
                        let
                            channel =
                                Events.init user activePage EventsLoaded

                            ( phxSocket, phxCmd ) =
                                Phoenix.Socket.join channel model.phxSocket
                        in
                            { model
                                | pageState = TransitioningFrom (getPage model.pageState)
                                , phxSocket = phxSocket
                            }
                                => Cmd.map PhoenixMsg phxCmd

                    Nothing ->
                        errored Page.Other "You must be signed in to view your events page"

            -- TEMP
            Just (Route.Home) ->
                let
                    ( newPhxSocket, phxCmd ) =
                        Phoenix.Socket.leave "events:eddy_lane" model.phxSocket
                in
                    { model | phxSocket = newPhxSocket, pageState = Loaded NotFound }
                        => Cmd.map PhoenixMsg phxCmd

            -- TEMP
            Just (Route.Logout) ->
                let
                    session =
                        model.session
                in
                    { model | session = { session | user = Nothing } }
                        => Cmd.batch
                            [ Ports.storeSession Nothing
                            , Route.modifyUrl Route.Home
                            ]

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
                { model | pageState = Loaded (toModel newModel) }
                    => Cmd.map toMsg newCmd

        errored =
            pageErrored model
    in
        case ( msg, page ) of
            ( SetRoute route, _ ) ->
                setRoute route model

            ( LoginMsg subMsg, Login subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        Login.update subMsg subModel

                    ( newModel, channelCmd ) =
                        case msgFromPage of
                            Login.NoOp ->
                                model => Cmd.none

                            Login.SetUser user ->
                                let
                                    session =
                                        model.session
                                in
                                    { model
                                        | session = { session | user = Just user }
                                    }
                                        => Cmd.none
                in
                    { newModel | pageState = Loaded (Login pageModel) }
                        => Cmd.batch
                            [ Cmd.map LoginMsg cmd
                            , Cmd.map PhoenixMsg channelCmd
                            ]

            ( RegisterMsg subMsg, Register subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        Register.update subMsg subModel

                    newModel =
                        case msgFromPage of
                            Register.NoOp ->
                                model

                            Register.SetUser user ->
                                let
                                    session =
                                        model.session

                                    updateSession =
                                        { session | user = Just user }
                                in
                                    { model | session = updateSession }
                in
                    { newModel | pageState = Loaded (Register pageModel) }
                        => Cmd.map RegisterMsg cmd


            ( EventsLoaded (Ok json), _ ) ->
                let
                    initialSubModel =
                        Events.initialModel

                    decodedEvents =
                        json
                            |> Decode.decodeValue (Decode.list Data.Event.decoder)

                    events =
                        Result.withDefault initialSubModel.events decodedEvents

                    newModel =
                        { initialSubModel | events = events }


                in
                    { model | pageState = Loaded (Events newModel) }
                        => Cmd.none

            ( EventsLoaded (Err error), _ ) ->
                { model | pageState = Loaded (Errored error) } => Cmd.none


            ( EventsMsg subMsg, Events subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        Events.update subMsg subModel
                in
                    { model | pageState = Loaded (Events pageModel) }
                        => Cmd.map EventsMsg cmd

            ( HeaderMsg subMsg, _ ) ->
                let
                    ( ( headerModel, cmd ), msgFromPage ) =
                        Header.update subMsg model.headerState
                in
                    { model | headerState = headerModel }
                        => Cmd.map HeaderMsg cmd

            ( SetUser user, _ ) ->
                let
                    session =
                        model.session

                    redirectCmd =
                        -- If we just signed out, then redirect to Home.
                        if session.user /= Nothing && user == Nothing then
                            Route.modifyUrl Route.Home
                        else
                            Cmd.none
                in
                    { model | session = { session | user = user } }
                        => Cmd.batch
                            [ redirectCmd
                            ]

            ( PhoenixMsg msg, _ ) ->
                let
                    ( phxSocket, phxCmd ) =
                        Phoenix.Socket.update msg model.phxSocket
                in
                    ( { model | phxSocket = phxSocket }
                    , Cmd.map PhoenixMsg phxCmd
                    )

            ( _, NotFound ) ->
                -- Disregard incoming messages when we're on the
                -- NotFound page.
                model => Cmd.none

            ( _, _ ) ->
                -- Disregard incoming messages that arrived for the wrong page
                model => Debug.log "COMMAND FALLING THROUGH THE FLOOR" Cmd.none



-- MAIN --


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
