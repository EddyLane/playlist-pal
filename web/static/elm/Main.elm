module Main exposing (main)

import Navigation exposing (Location)
import Route exposing (Route)
import Data.Session as Session exposing (Session)
import Data.User as User exposing (User, Username)
import Data.Event as Event exposing (Event)
import Page.Errored as Errored exposing (PageLoadError)
import Channels.UserSocket exposing (phoenixSubscription)
import Channels.EventChannel exposing (eventChannel)
import Phoenix.Channel as Channel exposing (Channel)
import Views.Page as Page exposing (ActivePage)
import Json.Decode as Decode exposing (Value)
import Page.Login as Login
import Page.Events as Events
import Task
import Util exposing ((=>))
import Html exposing (..)
import Ports
import Json.Encode as Encode


type Page
    = Blank
    | NotFound
    | Errored PageLoadError
    | Login Login.Model
    | Events Events.Model

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
        , session = { user = decodeUserFromJson val, events = [] }
        }


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
            Login subModel ->
                Login.view session subModel
                    |> frame Page.Other
                    |> Html.map LoginMsg

            Events subModel ->
                Events.view session subModel
                    |> frame Page.Events
                    |> Html.map EventsMsg

            _ ->
                -- This is for the very intiial page load, while we are loading
                -- data via HTTP. We could also render a spinner here.
                Html.text ""
                    |> frame Page.Other



-- SUBSCRIPTIONS --
-- Note: we aren't currently doing any page subscriptions, but I thought it would
-- be a good idea to put this in here as an example. If I were actually
-- maintaining this in production, I wouldn't bother until I needed this!


socket : Maybe User -> Sub Msg
socket maybeUser =
    let
        events user =
            user.username
                |> eventChannel
                |> Channel.onJoin EventChannelJoined
    in
        case maybeUser of
            Just user ->
                phoenixSubscription user [(events user)]

            Nothing ->
                Sub.none


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ pageSubscriptions (getPage model.pageState)
        , Sub.map SetUser sessionChange
        , socket model.session.user
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


pageSubscriptions : Page -> Sub Msg
pageSubscriptions page =
    case page of
        _ ->
            Sub.none



-- UPDATE --


type Msg
    = SetRoute (Maybe Route)
    | LoginMsg Login.Msg
    | EventsMsg Events.Msg
    | SetUser (Maybe User)
    | EventChannelJoined Encode.Value

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
                ( { model | pageState = Loaded (toModel newModel) }, Cmd.map toMsg newCmd )

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

                    newModel =
                        case msgFromPage of
                            Login.NoOp ->
                                model

                            Login.SetUser user ->
                                let
                                    session =
                                        model.session

                                    updateSession =
                                        { session | user = Just user }

                                in
                                    { model | session = updateSession }
                in
                    { newModel | pageState = Loaded (Login pageModel) }
                        => Cmd.map LoginMsg cmd

            ( SetUser user, _ ) ->
                let
                    session =
                        Debug.log "Setting session" model.session

                    cmd =
                        -- If we just signed out, then redirect to Home.
                        if session.user /= Nothing && user == Nothing then
                            Route.modifyUrl Route.Home
                        else
                            Cmd.none
                in
                    { model | session = { session | user = user } }
                        => cmd

            (EventChannelJoined eventsJson, _) ->
                let

                    session =
                        model.session

                    events =
                        (Decode.decodeValue (Decode.list Event.decoder) eventsJson)
                            |> Result.withDefault model.session.events

                    updatedSession =
                        { session | events = events }

                in
                    { model | session = updatedSession }
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
