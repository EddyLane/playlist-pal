module Main exposing (main)

import Navigation exposing (Location)
import Route exposing (Route)
import Data.Session as Session exposing (Session)
import Data.User as User exposing (User, Username, usernameToString)
import Data.Config as Config exposing (Config)
import Page.Errored as Errored exposing (PageLoadError)
import Views.Page as Page exposing (ActivePage)
import Json.Decode as Decode exposing (Value)
import Page.Login as Login
import Page.Playlists as Playlists
import Page.Playlist as Playlist
import Page.Register as Register
import Page.NotFound as NotFound
import Page.Home as Home
import Util exposing ((=>))
import Html exposing (..)
import Ports
import Page.Header as Header exposing (Model, initialState, subscriptions)
import Phoenix.Socket
import Channels.UserSocket exposing (initPhxSocket)
import Json.Encode as Encode
import Json.Decode as Decode
import Phoenix.Socket as Socket
import OAuth
import OAuth.Implicit

type Page
    = Blank
    | NotFound
    | Home Home.Model
    | Errored PageLoadError
    | Login Login.Model
    | Register Register.Model
    | Playlists Playlists.Model
    | Playlist Playlist.Model


type PageState
    = Loaded Page
    | Transitioning Page Route


pageToActivePage : Page -> ActivePage
pageToActivePage page =
    case page of
        Home _ ->
            Page.Home

        Playlists _ ->
            Page.Playlists

        Playlist _ ->
            Page.Playlist

        Login _ ->
            Page.Login

        Register _ ->
            Page.Register

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

        ( pageModel, pageCmd ) =
            setRoute (Route.fromLocation location)
                { pageState = Loaded initialPage
                , session = sessionModel
                , headerState = headerModel
                , phxSocket = phxSocket
                , config = configModel
                }

        commands =
            Cmd.batch
                [ pageCmd
                , Cmd.map HeaderMsg headerCmd
                ]
    in
        ( pageModel, commands )

decodeSessionFromJson : Value -> Maybe Session
decodeSessionFromJson json =
    json
        |> Decode.decodeValue (Decode.at ["session"] Decode.string)
        |> Result.toMaybe
        |> Maybe.andThen (Decode.decodeString Session.decoder >> Result.toMaybe)

decodeConfigFromJson : Value -> Config
decodeConfigFromJson json =
    json
        |> Decode.decodeValue (Decode.at ["config"] Config.decoder)
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

            Login subModel ->
                Login.view session subModel
                    |> frame activePage
                    |> Html.map LoginMsg

            Register subModel ->
                Register.view session subModel
                    |> frame activePage
                    |> Html.map RegisterMsg

            Playlists subModel ->
                Playlists.view session subModel
                    |> frame activePage
                    |> Html.map PlaylistsMsg

            Playlist subModel ->
                Playlist.view session subModel
                    |> frame activePage
                    |> Html.map PlaylistMsg



-- SUBSCRIPTIONS --


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
        Playlists _ ->
            Sub.none

        _ ->
            Sub.none



-- UPDATE --


type Msg
    = SetRoute (Maybe Route)
    | DestroyingPage (Cmd Msg)
    | LoginMsg Login.Msg
    | RegisterMsg Register.Msg
    | PlaylistsMsg Playlists.Msg
    | PlaylistMsg Playlist.Msg
    | PlaylistsLoaded (Result PageLoadError Encode.Value)
    | HeaderMsg Header.Msg
    | SetSocket (Phoenix.Socket.Socket Msg)
    | SetUser (Maybe User)
    | SetSession (Maybe Session)
    | NoOp
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | HomeMsg Home.Msg
    | Authorize

destroyPage : Maybe Route -> Model -> ( Model, Cmd Msg )
destroyPage maybeRoute model =
    let
        page =
            getPage model.pageState

        maybeUser =
            model.session.user

        ( phxSocket, phxCmd ) =
            case ( page, maybeUser, maybeRoute ) of
                ( Playlists _, Just user, Just (Route.Playlists) ) ->
                    ( model.phxSocket, Cmd.none )

                ( Playlists _, Just user, _ ) ->
                    Playlists.destroy user model.phxSocket

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
    in
        case maybeRoute of
            Just (Route.Home) ->
                { model | pageState = Loaded (Home Home.initialModel) } =>
                    Cmd.none


            Just (Route.Login) ->
                { model | pageState = Loaded (Login Login.initialModel) } => Cmd.none

            Just (Route.Register) ->
                { model | pageState = Loaded (Register Register.initialModel) } => Cmd.none

            Just (Route.Playlists) ->
                case ( model.session.user, model.session.token, page ) of
                    ( Just user, Just token, Playlists _ ) ->
                        model => Cmd.none

                    ( Just user, Just token, _ ) ->
                        let
                            ( phxSocket, phxCmd ) =
                                Playlists.init user token model.phxSocket PlaylistsLoaded PlaylistsMsg
                        in
                            { model
                                | pageState = Transitioning (getPage model.pageState) Route.Playlists
                                , phxSocket = phxSocket
                            }
                                => Cmd.map PhoenixMsg phxCmd

                    ( _, _, _ ) ->
                        errored Page.Other "You must be signed in to view your playlists page"

            Just (Route.Playlist slug) ->
                { model | pageState = Loaded (Playlist Playlist.initialModel) } => Cmd.none

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
    let
        ( updatedModel, updatedCmd ) =
            updatePage (getPage model.pageState) msg (model)
    in
        updatedModel
            => Cmd.batch
                [ updatedCmd
                ]


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

            ( Authorize, _ ) ->
                model
                    ! [ OAuth.Implicit.authorize
                            { clientId = "clientId"
                            , redirectUri = "redirectUri"
                            , responseType = OAuth.Token -- Use the OAuth.Token response type
                            , scope = [ "whatever" ]
                            , state = Nothing
                            , url = "authorizationEndpoint"
                            }
                      ]


            ( DestroyingPage msg, _ ) ->
                model => msg

            ( SetRoute route, _ ) ->
                let
                    ( destroyPageModel, destroyPageCmd ) =
                        destroyPage route model

                    ( updateRouteModel, updatedRouteCmd ) =
                        setRoute route model
                in
                    updateRouteModel
                        => Cmd.batch
                            [ destroyPageCmd
                            , updatedRouteCmd
                            ]

            ( LoginMsg subMsg, Login subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        Login.update subMsg subModel baseUrl

                    ( newModel, channelCmd ) =
                        case msgFromPage of
                            Login.NoOp ->
                                model => Cmd.none

                            Login.SetSession session ->
                                { model | session = session } => Cmd.none
                in
                    { newModel | pageState = Loaded (Login pageModel) }
                        => Cmd.batch
                            [ Cmd.map LoginMsg cmd
                            , Cmd.map PhoenixMsg channelCmd
                            ]

            ( RegisterMsg subMsg, Register subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        Register.update subMsg subModel baseUrl

                    newModel =
                        case msgFromPage of
                            Register.NoOp ->
                                model

                            Register.SetSession session ->
                                { model | session = session }
                in
                    { newModel | pageState = Loaded (Register pageModel) }
                        => Cmd.map RegisterMsg cmd

            ( PlaylistsLoaded (Ok json), _ ) ->
                { model | pageState = Loaded (Playlists <| Playlists.initialModel json) }
                    => Cmd.none

            ( PlaylistsLoaded (Err error), _ ) ->
                case model.session.user of
                    Just user ->
                        { model
                            | pageState = Loaded (Errored error)
                            , phxSocket = Playlists.error user model.phxSocket
                        }
                            => Cmd.none

                    _ ->
                        { model | pageState = Loaded (Errored error) } => Cmd.none

            ( PlaylistsMsg subMsg, Playlists subModel ) ->
                let
                    ( ( pageModel, cmd ), msgFromPage ) =
                        Playlists.update session baseUrl subMsg subModel
                in
                    { model | pageState = Loaded (Playlists pageModel) }
                        => Cmd.map PlaylistsMsg cmd

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
