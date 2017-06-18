module App.Events.View exposing (..)

import App.Events.Model exposing (..)
import App.Msg exposing (..)
import App.Events.Msg as EventsMsg
import Html exposing (..)
import Html.Attributes exposing (class, classList, for, type_, placeholder, value, id, disabled, href)
import Html.Events exposing (onSubmit, onInput, onClick)
import Json.Encode
import Phoenix.Channel as Channel exposing (Channel)
import App.Session.Model exposing (User)
import App.Model as BaseModel
import Bootstrap.Grid as Grid
import Bootstrap.Grid.Row as Row
import Bootstrap.Grid.Col as Col
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button
import Bootstrap.Modal as Modal
import Bootstrap.Alert as Alert


onJoin : Json.Encode.Value -> Msg
onJoin events =
    events
        |> EventsMsg.EventChannelConnected
        |> MsgForEvents


onUpdate : Json.Encode.Value -> Msg
onUpdate event =
    event
        |> EventsMsg.EventChannelUpdated
        |> MsgForEvents


eventChannel : User -> Channel Msg
eventChannel user =
    Channel.init ("events:" ++ user.username)
        |> Channel.onJoin onJoin
        |> Channel.on "added" onUpdate
        |> Channel.withDebug


newForm : Model -> Html Msg
newForm model =
    let
        submit =
            newEvent.name
                |> EventsMsg.CreateEvent
                |> MsgForEvents

        closeModal =
            Modal.hiddenState
                |> EventsMsg.FormModal
                |> MsgForEvents

        newEvent =
            model.newForm

        modalHeader =
            case model.hasError of
                Just err ->
                    Alert.danger [ text "Uhoh! Attempt to create your event seems to have failed.." ]
                _ ->
                    text ""

        hasNameErrors =
            (List.length model.errors.name) > 0

        nameFormGroupAttrs =
            if hasNameErrors then
                [ Form.groupDanger ]
            else
                []

        nameInputAttrs =
            if hasNameErrors then
                [ Input.danger ]
            else
                []

        nameErrors =
            List.map (\e -> Form.validationText [] [ text e ]) model.errors.name

        nameFormGroup =
            [ Form.label [ for "new-event-form-name" ] [ text "Event name" ]
            , Input.text
                (List.concat
                    [ [ Input.id "new-event-form-name"
                      , Input.attrs
                            [ placeholder "New event..."
                            , value newEvent.name
                            , onInput (EventsMsg.NewFormName >> MsgForEvents)
                            , disabled model.submitting
                            ]
                      ]
                    , nameInputAttrs
                    ]
                )
            ]

        modalBody =
            [ modalHeader
            , Form.form [ onSubmit submit ]
                [ Form.group nameFormGroupAttrs (List.concat [ nameFormGroup, nameErrors ])
                ]
            ]
    in
        Modal.config (EventsMsg.FormModal >> MsgForEvents)
            |> Modal.small
            |> Modal.h3 [] [ text "Create event" ]
            |> Modal.header [] [ h5 [] [ text "Create event" ] ]
            |> Modal.body [] modalBody
            |> Modal.footer []
                [ Button.button
                    [ Button.secondary
                    , Button.attrs
                        [ type_ "button"
                        , onClick closeModal
                        ]
                    ]
                    [ text "Close" ]
                , Button.button
                    [ Button.primary
                    , Button.attrs
                        [ disabled model.submitting
                        , type_ "submit"
                        , onClick submit
                        ]
                    ]
                    [ text "Create event" ]
                ]
            |> Modal.view model.formModalState


eventHash : String -> String
eventHash slug =
    slug


isActive : Maybe BaseModel.Route -> Event -> Bool
isActive maybeRoute event =
    case ( maybeRoute, event.slug ) of
        ( Just route, Just eventSlug ) ->
            case route of
                BaseModel.Event routeSlug ->
                    routeSlug == eventSlug

                _ ->
                    False

        _ ->
            False


eventItem : Maybe BaseModel.Route -> Event -> ListGroup.CustomItem Msg
eventItem maybeRoute event =
    let
        hash =
            case event.slug of
                Just slug ->
                    eventHash slug

                Nothing ->
                    ""

        attrs =
            [ ListGroup.attrs [ href ("#event/" ++ hash) ] ]

        props =
            if (isActive maybeRoute event) then
                ListGroup.active :: attrs
            else
                attrs
    in
        ListGroup.anchor props [ text event.name ]


eventList : List Event -> Maybe BaseModel.Route -> Html Msg
eventList events maybeLocation =
    ListGroup.custom (List.map (eventItem maybeLocation) events)


eventView : Maybe Event -> Html Msg
eventView maybeEvent =
    case maybeEvent of
        Just event ->
            div [] [ text event.name ]

        _ ->
            div [] []


event : Maybe BaseModel.Route -> List Event -> Maybe Event
event route events =
    List.head (List.filter (isActive route) events)


view : Model -> List (Maybe BaseModel.Route) -> Html Msg
view model locations =
    let
        route =
            (Maybe.withDefault Nothing (List.head locations))

        openModal =
            EventsMsg.FormModal Modal.visibleState |> MsgForEvents

        newButton =
            Button.button
                [ Button.outlineSuccess
                , Button.block
                , Button.attrs [ onClick openModal ]
                ]
                [ text "Create event" ]
    in
        Grid.row [ Row.centerXs ]
            [ Grid.col [ Col.md4 ]
                [ Grid.row [] [ Grid.col [] [ newButton ] ]
                , Grid.row [] [ Grid.col [] [ eventList model.events route ] ]
                ]
            , Grid.col [ Col.md8 ]
                [ event route model.events |> eventView
                , newForm model
                ]
            ]
