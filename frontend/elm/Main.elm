module Main exposing (main)

import Navigation exposing (Location)
import Route exposing (Route)
import Data.Session as Session exposing (Session)
import Data.User as User exposing (User, Username, usernameToString)
import Data.Config as Config exposing (Config)
import Page.Errored as Errored exposing (PageLoadError)
import Views.Page as Page exposing (ActivePage)
import Json.Decode as Decode exposing (Value)
import Page.NotFound as NotFound
import Page.Home as Home
import Util exposing ((=>))
import Html exposing (..)
import Ports
import Page.Header as Header exposing (Model, initialState, subscriptions)
import Phoenix.Socket
import Channels.UserSocket exposing (initPhxSocket)
import Json.Decode as Decode
import Phoenix.Socket as Socket
import Request.Authenticate as Authenticate
import Http


type Page
    = Blank
    | NotFound
    | Home Home.Model
    | Errored PageLoadError


type PageState
    = Loaded Page
    | Transitioning Page Route


pageToActivePage : Page -> ActivePage
pageToActivePage page =
    case page of
        Home _ ->
            Page.Home

        _ ->
            Page.Other



-- MODEL --


type alias Model =
    { session : Session
    , pageState : PageState
    , headerState : Header.Model
    , phxSocket : Phoenix.Socket.Socket Msg
    , config : Config
    }


init : Value -> Location -> ( Model, Cmd Msg )
init val location =
    let
        sessionModel =
            decodeSessionFromJson val
                |> Maybe.withDefault Session.initialModel

        configModel =
            decodeConfigFromJson val

        phxSocket =
            initPhxSocket configModel.apiUrl

        ( headerModel, headerCmd ) =
            Header.initialState

        route =
            Route.fromLocation location

        ( pageModel, pageCmd ) =
            setRoute route
                { pageState = Loaded initialPage
                , session = sessionModel
                , headerState = headerModel
                , phxSocket = phxSocket
                , config = configModel
                }

        redirectToAuth =
            case ( sessionModel.token, route ) of
                ( Just _, _ ) ->
                    Cmd.none

                ( Nothing, Just (Route.Authenticate _) ) ->
                    Cmd.none

                ( _, _ ) ->
                    Navigation.load "http://localhost:4000/v1/sign-up"

        commands =
            Cmd.batch
                [ pageCmd
                , Cmd.map HeaderMsg headerCmd
                , redirectToAuth
                ]
    in
        ( pageModel, commands )


decodeSessionFromJson : Value -> Maybe Session
decodeSessionFromJson json =
    json
        |> Decode.decodeValue (Decode.at [ "session" ] Decode.string)
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString Session.decoder >> Result.toMaybe)


decodeConfigFromJson : Value -> Config
decodeConfigFromJson json =
    json
        |> Decode.decodeValue (Decode.at [ "config" ] Config.decoder)
        |> Result.toMaybe
        |> Maybe.withDefault Config.defaultModel


initialPage : Page
initialPage =
    Blank



-- VIEW --


view : Model -> Html Msg
view model =
    case model.pageState of
        Loaded page ->
            div []
                [ viewHeader model False page
                , viewPage model False page
                ]

        Transitioning fromPage _ ->
            div []
                [ viewHeader model True fromPage
                , viewPage model True fromPage
                ]


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
            NotFound ->
                NotFound.view session
                    |> frame Page.Other

            Blank ->
                -- This is for the very intiial page load, while we are loading
                -- data via HTTP. We could also render a spinner here.
                Html.text ""
                    |> frame Page.Other

            Errored subModel ->
                Errored.view session subModel
                    |> frame Page.Other

            Home subModel ->
                Home.view session subModel
                    |> frame activePage
                    |> Html.map HomeMsg



-- SUBSCRIPTIONS --


subscriptions : Model -> Sub Msg
subscriptions model =
    let
        header =
            Header.subscriptions model.headerState
                |> Sub.map HeaderMsg

        page =
            getPage model.pageState
    in
        Sub.batch
            [ pageSubscriptions page model
            , Sub.map SetSession sessionChange
            , header
            , Phoenix.Socket.listen model.phxSocket PhoenixMsg
            ]


sessionChange : Sub (Maybe Session)
sessionChange =
    Ports.onSessionChange (Decode.decodeValue Session.decoder >> Result.toMaybe)


getPage : PageState -> Page
getPage pageState =
    case pageState of
        Loaded page ->
            page

        Transitioning fromPage _ ->
            fromPage


pageSubscriptions : Page -> Model -> Sub Msg
pageSubscriptions page model =
    case page of
        _ ->
            Sub.none



-- UPDATE --


type Msg
    = SetRoute (Maybe Route)
    | DestroyingPage (Cmd Msg)
    | HeaderMsg Header.Msg
    | SetSocket (Phoenix.Socket.Socket Msg)
    | SetUser (Maybe User)
    | SetSession (Maybe Session)
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | HomeMsg Home.Msg
    | Authenticate (Result Http.Error Session)


destroyPage : Maybe Route -> Model -> ( Model, Cmd Msg )
destroyPage maybeRoute model =
    let
        page =
            getPage model.pageState

        maybeUser =
            model.session.user

        ( phxSocket, phxCmd ) =
            case ( page, maybeUser, maybeRoute ) of
                _ ->
                    ( model.phxSocket, Cmd.none )

        pageDestroyCmd =
            phxCmd |> Cmd.map PhoenixMsg
    in
        { model | phxSocket = phxSocket }
            => pageDestroyCmd


setRoute : Maybe Route -> Model -> ( Model, Cmd Msg )
setRoute maybeRoute model =
    let
        page =
            getPage model.pageState

        activePage =
            page |> pageToActivePage

        apiUrl =
            model.config.apiUrl

        errored =
            pageErrored model

        config =
            model.config
    in
        case maybeRoute of
            Just (Route.Home) ->
                { model | pageState = Loaded (Home Home.initialModel) }
                    => Cmd.none

            Just (Route.Authenticate (Just token)) ->
                model
                    => Http.send Authenticate (Authenticate.authenticate token config.apiUrl)

            _ ->
                { model | pageState = Loaded NotFound } => Cmd.none


getSession : Maybe String -> Cmd msg
getSession maybeToken =
    case maybeToken of
        Just token ->
            Cmd.none

        Nothing ->
            Cmd.none


pageErrored : Model -> ActivePage -> String -> ( Model, Cmd msg )
pageErrored model activePage errorMessage =
    let
        error =
            Errored.pageLoadError activePage errorMessage
    in
        { model | pageState = Loaded (Errored error) } => Cmd.none


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    let
        ( updatedModel, updatedCmd ) =
            updatePage (getPage model.pageState) msg model
    in
        updatedModel => updatedCmd


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

        baseUrl =
            model.config.apiUrl

        errored =
            pageErrored model
    in
        case ( msg, page ) of
            ( Authenticate (Ok session), _ ) ->
                { model | session = session }
                    ! [ Authenticate.storeSession session, Route.modifyUrl Route.Home ]

            ( SetRoute route, _ ) ->
                let
                    ( destroyPageModel, destroyPageCmd ) =
                        destroyPage route model

                    ( updateRouteModel, updatedRouteCmd ) =
                        setRoute route model
                in
                    updateRouteModel ! [ destroyPageCmd, updatedRouteCmd ]

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
                        => redirectCmd

            ( SetSession session, _ ) ->
                let
                    redirectCmd =
                        -- If we just signed out, then redirect to Home.
                        if model.session.user /= Nothing && Maybe.andThen .user session == Nothing then
                            Route.modifyUrl Route.Home
                        else
                            Cmd.none
                in
                    { model | session = Maybe.withDefault model.session session }
                        => redirectCmd

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
