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

destroy
    : Maybe User
    -> Socket.Socket msg
    -> ( Socket.Socket msg, Cmd (Socket.Msg msg) )
destroy maybeUser phxSocket =
    case maybeUser of
        Just user ->
            EventChannel.leave user phxSocket
        _ ->
            phxSocket => Cmd.none

init
 : User
 -> Page.ActivePage
 -> Socket.Socket c
 -> (Result PageLoadError Encode.Value -> c)
 -> (Msg -> c)
 -> ( Socket.Socket c, Cmd (Socket.Msg c) )
init user activePage phxSocket msg newMsg =
    let

        listeningSocket =
            phxSocket
                |> Socket.on "added" (eventChannelName user) (EventChannelJoined >> newMsg)

        error msg =
            msg
                |> Errored.pageLoadError activePage
                |> Err
                |> always

        channel =
            EventChannel.join user
                |> Channel.onJoin (Ok >> msg)
                |> Channel.onJoinError (error "Channel failure" >> msg)
    in
        Socket.join channel listeningSocket



-- UPDATE


type Msg
    = SubmitForm
    | SetName String
    | EventChannelJoined Encode.Value
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

        EventChannelJoined eventsJson ->
            let
                events =
                    (Decode.decodeValue (Decode.list Event.decoder) eventsJson)
                        |> Result.withDefault model.events
            in
                { model | events = events }
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
