module Main exposing (main)

import Navigation exposing (Location)
import Route exposing (Route)
import Data.Session as Session exposing (Session)
import Data.User as User exposing (User, Username, usernameToString)
import Data.Event as Event exposing (Event)
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
import Json.Encode as Encode
import Page.Header as Header exposing (Model, initialState, subscriptions)
import Phoenix.Socket
import Phoenix.Channel
import Channels.UserSocket exposing (initPhxSocket)
import Data.AuthToken exposing (AuthToken, tokenToString)


--import Phoenix.Channel as Channel exposing (Channel)


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


phxSocket : Phoenix.Socket.Socket Msg
phxSocket =
    initPhxSocket
        |> Phoenix.Socket.on "new:msg" "rooms:lobby" ReceiveChatMessage


eventChannel : User -> Phoenix.Channel.Channel Msg
eventChannel user =
    let
        guardianToken =
            user.token
                |> tokenToString

        username =
            user.username
                |> usernameToString
    in
        Phoenix.Channel.init ("events:" ++ username)
            |> Phoenix.Channel.withPayload (Encode.object [ ( "guardian_token", Encode.string guardianToken ) ])


channels : Session -> Phoenix.Socket.Socket Msg -> Cmd Msg
channels session phxSocket =
    let
        ( socket, phxCmd ) =
            case session.user of
                Just user ->
                    Phoenix.Socket.join (eventChannel user) phxSocket

                Nothing ->
                    phxSocket => Cmd.none
    in
        Cmd.map (ChannelJoined socket) phxCmd


init : Value -> Location -> ( Model, Cmd Msg )
init val location =
    let
        ( headerModel, headerCmd ) =
            Header.initialState

        ( pageModel, pageCmd ) =
            setRoute (Route.fromLocation location)
                { pageState = Loaded initialPage
                , session = { user = decodeUserFromJson val, events = [] }
                , headerState = headerModel
                , phxSocket = phxSocket
                }

        commands =
            Cmd.batch
                [ pageCmd
                , channels pageModel.session pageModel.phxSocket
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
--channels: Page -> User -> List (Channel Events.Msg)
--channels page user =
--    case page of
--        Events _ ->
--            Events.channels user
--        _ ->
--            []
--channelMsg: Page -> Events.Msg -> Msg
--channelMsg page msg =
--    case page of
--        Events _ ->
--            EventsMsg msg
--        _ ->
--            NoOp
--socket : Page -> Maybe User -> Sub Msg
--socket page maybeUser =
--    case maybeUser of
--        Just user ->
--            phoenixSubscription user (channels page user)
--                |> Sub.map (channelMsg page)
--
--        Nothing ->
--            Sub.none


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
    --    let
    --        channel =
    --          Phoenix.Channel.init "events:tom_lane"
    ----            |> Phoenix.Channel.withPayload userParams
    ----            |> Phoenix.Channel.onJoin (always (ShowJoinedMessage "rooms:lobby"))
    ----            |> Phoenix.Channel.onClose (always (ShowLeftMessage "rooms:lobby"))
    --
    --        (phxSocket, phxCmd) = Phoenix.Socket.join channel model.phxSocket
    --    in
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
    | HeaderMsg Header.Msg
    | SetUser (Maybe User)
    | EventChannelUpdated Encode.Value
    | EventChannelJoined Encode.Value
    | NoOp
    | ReceiveChatMessage Encode.Value
    | PhoenixMsg (Phoenix.Socket.Msg Msg)
    | JoinChannel
    | SetSocket (Phoenix.Socket.Socket Msg)
    | ChannelJoined (Phoenix.Socket.Socket Msg) (Phoenix.Socket.Msg Msg)


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
            Just (Route.Login) ->
                { model | pageState = Loaded (Login Login.initialModel) } => Cmd.none

            Just (Route.Register) ->
                { model | pageState = Loaded (Register Register.initialModel) } => Cmd.none

            Just (Route.Events) ->
                { model | pageState = Loaded (Events Events.initialModel) } => Cmd.none

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
                                    ( socket, phxCmd ) =
                                        Phoenix.Socket.join (eventChannel user) phxSocket

                                    session =
                                        model.session
                                in
                                    { model
                                        | session = { session | user = Just user }
                                        , phxSocket = socket
                                    }
                                        => phxCmd
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
                        Debug.log "Setting session" model.session

                    redirectCmd =
                        -- If we just signed out, then redirect to Home.
                        if session.user /= Nothing && user == Nothing then
                            Route.modifyUrl Route.Home
                        else
                            Cmd.none

                    channel =
                        Phoenix.Channel.init "events:eddy_lane"

                    ( phxSocket, phxCmd ) =
                        Phoenix.Socket.join channel model.phxSocket
                in
                    { model
                        | session = { session | user = user }
                        , phxSocket = phxSocket
                    }
                        => Cmd.batch
                            [ redirectCmd
                            , Cmd.map PhoenixMsg phxCmd
                            ]

            ( EventChannelUpdated eventJson, _ ) ->
                let
                    session =
                        model.session

                    events =
                        case (Decode.decodeValue Event.decoder eventJson) of
                            Ok event ->
                                event :: session.events

                            _ ->
                                session.events

                    updatedSession =
                        { session | events = events }
                in
                    { model | session = updatedSession }
                        => Cmd.none

            ( EventChannelJoined eventsJson, _ ) ->
                let
                    session =
                        model.session

                    events =
                        (Decode.decodeValue (Decode.list Event.decoder) eventsJson)
                            |> Result.withDefault session.events

                    updatedSession =
                        { session | events = events }
                in
                    { model | session = updatedSession }
                        => Cmd.none

            --            ( JoinChannel, _ ) ->
            --                let
            --                    channel =
            --                        Phoenix.Channel.init "events:eddy_lane"
            --                           |> Phoenix.Channel.withPayload (Encode.object [ ( "guardian_token", Encode.string "eyJhbGciOiJIUzUxMiIsInR5cCI6IkpXVCJ9.eyJhdWQiOiJVc2VyOjEiLCJleHAiOjE1MDI5MDk1NzYsImlhdCI6MTUwMDMxNzU3NiwiaXNzIjoiTXlBcHAiLCJqdGkiOiIzMTA4YmJhMC1lNjFlLTQ2OTMtYWU4Yy02NmFhMWUyYWRiNWYiLCJwZW0iOnt9LCJzdWIiOiJVc2VyOjEiLCJ0eXAiOiJhY2Nlc3MifQ.Y7lqRcri28wAEWPfV_ohsViF9nYMOuac97mwOHwB0BvjGX6JflTVjsmJg__Gsaq5-4IGHZmdK21OEKEZK4SrHA") ])
            --
            --                    ( phxSocket, phxCmd ) =
            --                        Phoenix.Socket.join channel model.phxSocket
            --                in
            --                    ( { model | phxSocket = phxSocket }
            --                    , Cmd.map PhoenixMsg phxCmd
            --                    )
            ( ChannelJoined socket msg, _ ) ->
                let
                    ( phxSocket, phxCmd ) =
                        Phoenix.Socket.update msg socket
                in
                    ( { model | phxSocket = phxSocket }
                    , Cmd.map PhoenixMsg phxCmd
                    )

            ( PhoenixMsg msg, _ ) ->
                let
                    ( phxSocket, phxCmd ) =
                        Phoenix.Socket.update msg model.phxSocket
                in
                    ( { model | phxSocket = phxSocket }
                    , Cmd.map PhoenixMsg phxCmd
                    )

            ( SetSocket phxSocket, _ ) ->
                { model | phxSocket = phxSocket }
                    => Cmd.none

            ( _, NotFound ) ->
                -- Disregard incoming messages when we're on the
                -- NotFound page.
                model => Cmd.none

            ( _, _ ) ->
                -- Disregard incoming messages that arrived for the wrong page
                model => Cmd.none



-- MAIN --


main : Program Value Model Msg
main =
    Navigation.programWithFlags (Route.fromLocation >> SetRoute)
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
