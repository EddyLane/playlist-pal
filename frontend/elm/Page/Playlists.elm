module Page.Playlists exposing (..)

{-| The playlists page
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Data.Session as Session exposing (Session)
import Data.Playlist as Playlist exposing (Playlist, slugToString)
import Data.AuthToken as AuthToken exposing (AuthToken)
import Request.Playlist exposing (create)
import Bootstrap.Grid as Grid
import Bootstrap.ListGroup as ListGroup
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button
import Bootstrap.Grid.Col as Col
import Util exposing ((=>))
import Http
import Validate exposing (..)
import Views.Form as Form
import Json.Encode as Encode
import Json.Decode as Decode exposing (Value)
import Phoenix.Channel as Channel
import Page.Errored as Errored exposing (PageLoadError, pageLoadError)
import Channels.PlaylistChannel as PlaylistChannel exposing (playlistChannelName)
import Data.User exposing (User)
import Views.Page as Page
import Data.Playlist as Playlist exposing (Playlist, decoder)
import Phoenix.Socket as Socket
import Dict


-- MODEL --


type alias Model =
    { submitting : Bool
    , name : String
    , errors : List Error
    , playlists : List Playlist
    }


initialModel : Encode.Value -> Model
initialModel playlistsJson =
    let
        decodedPlaylists =
            playlistsJson
                |> Decode.decodeValue (Decode.list Playlist.decoder)

        playlists =
            Result.withDefault [] decodedPlaylists
    in
        { submitting = False
        , name = ""
        , errors = []
        , playlists = playlists
        }


destroy :
    User
    -> Socket.Socket msg
    -> ( Socket.Socket msg, Cmd (Socket.Msg msg) )
destroy user phxSocket =
    let
        leave =
            PlaylistChannel.leave user.username phxSocket
    in
        case PlaylistChannel.get user.username phxSocket of
            Just (Channel.Joined) ->
                leave

            Just (Channel.Joining) ->
                leave

            _ ->
                ( phxSocket, Cmd.none )


pageLoadError : String -> b -> Result PageLoadError value
pageLoadError msg =
    msg
        |> Errored.pageLoadError Page.Playlists
        |> Err
        |> always


onAdded : Value -> Msg
onAdded =
    Decode.decodeValue Playlist.decoder
        >> AddPlaylist


error : User -> Socket.Socket msg -> Socket.Socket msg
error user socket =
    let
        maybeChannel =
            socket.channels
                |> Dict.get (playlistChannelName user.username)
    in
        case maybeChannel of
            Just channel ->
                let
                    errorChannel =
                        { channel | state = Channel.Errored }

                    channels =
                        Dict.insert (playlistChannelName user.username) errorChannel socket.channels
                in
                    { socket | channels = channels }

            _ ->
                socket


init :
    User
    -> AuthToken
    -> Socket.Socket msg
    -> (Result PageLoadError Encode.Value -> msg)
    -> (Msg -> msg)
    -> ( Socket.Socket msg, Cmd (Socket.Msg msg) )
init user token phxSocket initMsg playlistMsg =
    let
        channel =
            PlaylistChannel.init user.username token (Ok >> initMsg) (pageLoadError "Channel failure" >> initMsg)

        join =
            phxSocket
                |> PlaylistChannel.onAdded channel (onAdded >> playlistMsg)
                |> PlaylistChannel.join channel
    in
        case PlaylistChannel.get user.username phxSocket of
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
    | AddPlaylist (Result String Playlist)
    | CreatePlaylistCompleted (Result Http.Error Playlist)


type ExternalMsg
    = NoOp
    | SetSocket


update : Session -> Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update session msg model =
    case msg of
        SetName name ->
            { model | name = name }
                => Cmd.none
                => NoOp

        SubmitForm ->
            case validate model of
                [] ->
                    { model | errors = [], submitting = True }
                        => Http.send CreatePlaylistCompleted (Request.Playlist.create { name = model.name } session)
                        => NoOp

                errors ->
                    { model | errors = errors }
                        => Cmd.none
                        => NoOp

        CreatePlaylistCompleted (Err err) ->
            { model | submitting = False, name = "" }
                => Cmd.none
                => NoOp

        CreatePlaylistCompleted (Ok playlist) ->
            model
                => Cmd.none
                => NoOp

        AddPlaylist (Ok playlist) ->
            { model | playlists = playlist :: model.playlists }
                => Cmd.none
                => NoOp

        AddPlaylist (Err err) ->
            Debug.log ("AddPlaylist err: " ++ err) model
                => Cmd.none
                => NoOp



-- VIEW --


form : Model -> Html Msg
form model =
    Form.form [ onSubmit SubmitForm ]
        [ Input.text
            [ Input.attrs
                [ value model.name
                , onInput SetName
                ]
            , Input.id "name"
            ]
        , Button.button
            [ Button.primary
            , Button.attrs
                [ type_ "submit"
                , disabled model.submitting
                ]
            ]
            [ text "Create" ]
        ]


playlistItem : Playlist -> ListGroup.CustomItem Msg
playlistItem playlist =
    let
        attrs =
            [ ListGroup.attrs [ href ("#playlist/" ++ (playlist.slug |> slugToString)) ] ]
    in
        ListGroup.anchor attrs [ text playlist.name ]


playlistList : List Playlist -> Html Msg
playlistList playlists =
    ListGroup.custom (List.map playlistItem playlists)


view : Session -> Model -> Html Msg
view session model =
    Grid.container []
        [ Grid.row []
            [ Grid.col [ Col.sm ]
                [ Form.viewErrors model.errors
                , form model
                ]
            ]
        , Grid.row []
            [ Grid.col [ Col.sm ]
                [ playlistList model.playlists
                ]
            ]
        ]



-- VALIDATION --


type Field
    = Name


type alias Error =
    ( Field, String )


validate : Model -> List Error
validate =
    Validate.all
        [ .name >> ifBlank (Name => "Please give your playlist a name.")
        ]
