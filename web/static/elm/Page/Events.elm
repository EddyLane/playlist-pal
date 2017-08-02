module Page.Events exposing (..)

{-| The events page
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Data.Session as Session exposing (Session)
import Data.Event as Event exposing (Event)
import Request.Events exposing (create)
import Bootstrap.Grid as Grid
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button
import Util exposing ((=>))
import Http
import Validate exposing (..)
import Views.Form as Form
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value)
import Phoenix.Channel as Channel
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Channels.EventChannel as EventChannel exposing (eventChannelName)
import Data.User exposing (User)
import Views.Page as Page
import Data.Event as Event exposing (Event, decoder)
import Phoenix.Socket as Socket
import Dict


-- MODEL --


type alias Model =
    { submitting : Bool
    , name : String
    , errors : List Error
    , events : List Event
    }


initialModel : Encode.Value -> Model
initialModel eventsJson =
    let
        decodedEvents =
            eventsJson
                |> Decode.decodeValue (Decode.list Event.decoder)

        events =
            Result.withDefault [] decodedEvents
    in
        { submitting = False
        , name = ""
        , errors = []
        , events = events
        }


destroy :
    User
    -> Socket.Socket msg
    -> ( Socket.Socket msg, Cmd (Socket.Msg msg) )
destroy user phxSocket =
    let
        leave =
            EventChannel.leave user phxSocket
    in
        case EventChannel.get user phxSocket of
            Just (Channel.Joined) ->
                leave

            Just (Channel.Joining) ->
                leave

            _ ->
                ( phxSocket, Cmd.none )


pageLoadError : String -> b -> Result PageLoadError value
pageLoadError msg =
    msg
        |> Errored.pageLoadError Page.Events
        |> Err
        |> always


onAdded : Value -> Msg
onAdded =
    Decode.decodeValue Event.decoder
        >> AddEvent


error : User -> Socket.Socket msg -> Socket.Socket msg
error user socket =
    let
        maybeChannel =
            socket.channels
                |> Dict.get (eventChannelName user)

        errorChannel channel =
            { channel | state = Channel.Errored }
    in
        case maybeChannel of
            Just channel ->
                { socket | channels = Dict.insert (eventChannelName user) (errorChannel channel) socket.channels }

            _ ->
                socket


init :
    User
    -> Socket.Socket msg
    -> (Result PageLoadError Encode.Value -> msg)
    -> (Msg -> msg)
    -> ( Socket.Socket msg, Cmd (Socket.Msg msg) )
init user phxSocket initMsg eventMsg =
    let
        channel =
            EventChannel.init user (Ok >> initMsg) (pageLoadError "Channel failure" >> initMsg)

        join =
            phxSocket
                |> EventChannel.onAdded channel (onAdded >> eventMsg)
                |> EventChannel.join channel
    in
        case EventChannel.get user phxSocket of
            Nothing ->
                join

            Just (Channel.Closed) ->
                join

            Just (Channel.Leaving) ->
                join

            Just (Channel.Errored) ->
                join

            _ ->
                ( phxSocket, Cmd.none )



-- UPDATE


type Msg
    = SubmitForm
    | SetName String
    | AddEvent (Result String Event)
    | CreateEventCompleted (Result Http.Error Event)


type ExternalMsg
    = NoOp
    | SetSocket



-- VIEW --


form : Model -> Html Msg
form model =
    Form.form [ onSubmit SubmitForm ]
        [ Form.group []
            [ Form.label [ for "name" ] [ text "Name" ]
            , Input.text
                [ Input.attrs
                    [ value model.name
                    , onInput SetName
                    ]
                , Input.id "name"
                ]
            ]
        , Button.button
            [ Button.primary
            , Button.attrs
                [ type_ "submit"
                , disabled model.submitting
                ]
            ]
            [ text "Submit" ]
        ]


eventItem : Event -> ListGroup.CustomItem Msg
eventItem event =
    let
        attrs =
            [ ListGroup.attrs [ href ("#event/" ++ event.slug) ] ]
    in
        ListGroup.anchor attrs [ text event.name ]


eventList : List Event -> Html Msg
eventList events =
    ListGroup.custom (List.map eventItem events)


view : Session -> Model -> Html Msg
view session model =
    Grid.container []
        [ Grid.row []
            [ Grid.col []
                [ Form.viewErrors model.errors
                , form model
                ]
            , Grid.col [] [ eventList model.events ]
            ]
        ]


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SetName name ->
            { model | name = name }
                => Cmd.none
                => NoOp

        SubmitForm ->
            case validate model of
                [] ->
                    { model | errors = [], submitting = True }
                        => Http.send CreateEventCompleted (Request.Events.create { name = model.name })
                        => NoOp

                errors ->
                    { model | errors = errors }
                        => Cmd.none
                        => NoOp

        CreateEventCompleted (Err err) ->
            { model | submitting = False, name = "" }
                => Cmd.none
                => NoOp

        CreateEventCompleted (Ok event) ->
            model
                => Cmd.none
                => NoOp

        AddEvent (Ok event) ->
            { model | events = event :: model.events }
                => Cmd.none
                => NoOp

        AddEvent (Err err) ->
            Debug.log ("AddEvent err: " ++ err) model
                => Cmd.none
                => NoOp



-- VALIDATION --


type Field
    = Name


type alias Error =
    ( Field, String )


validate : Model -> List Error
validate =
    Validate.all
        [ .name >> ifBlank (Name => "Please give your event a name.")
        ]
