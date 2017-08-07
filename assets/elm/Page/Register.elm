module Page.Register exposing (view, update, Model, Msg, ExternalMsg(..), initialModel)

import Route exposing (Route)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.Form as Form
import Json.Decode as Decode exposing (field, decodeString, string, Decoder)
import Json.Decode.Pipeline as Pipeline exposing (optional, decode)
import Data.Session as Session exposing (Session)
import Validate exposing (ifBlank)
import Request.User exposing (storeSession)
import Http
import Util exposing ((=>))


-- MODEL --


type alias Model =
    { errors : List Error
    , name : String
    , username : String
    , password : String
    }


initialModel : Model
initialModel =
    { errors = []
    , name = ""
    , username = ""
    , password = ""
    }



-- VIEW --


view : Session -> Model -> Html Msg
view session model =
    div [ class "auth-page" ]
        [ div [ class "container page" ]
            [ div [ class "row" ]
                [ div [ class "col-md-6 offset-md-3 col-xs-12" ]
                    [ h1 [ class "text-xs-center" ] [ text "Sign up" ]
                    , p [ class "text-xs-center" ]
                        [ a [ Route.href Route.Login ]
                            [ text "Have an account?" ]
                        ]
                    , Form.viewErrors model.errors
                    , viewForm
                    ]
                ]
            ]
        ]


viewForm : Html Msg
viewForm =
    Html.form [ onSubmit SubmitForm ]
        [ Form.input
            [ class "form-control-lg"
            , placeholder "Username"
            , onInput SetUsername
            ]
            []
        , Form.input
            [ class "form-control-lg"
            , placeholder "Name"
            , onInput SetName
            ]
            []
        , Form.password
            [ class "form-control-lg"
            , placeholder "Password"
            , onInput SetPassword
            ]
            []
        , button [ class "btn btn-lg btn-primary pull-xs-right" ]
            [ text "Sign up" ]
        ]



-- UPDATE --


type Msg
    = SubmitForm
    | SetName String
    | SetUsername String
    | SetPassword String
    | RegisterCompleted (Result Http.Error Session)


type ExternalMsg
    = NoOp
    | SetSession Session


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SubmitForm ->
            case validate model of
                [] ->
                    { model | errors = [] }
                        => Http.send RegisterCompleted (Request.User.register model)
                        => NoOp

                errors ->
                    { model | errors = errors }
                        => Cmd.none
                        => NoOp

        SetName name ->
            { model | name = name }
                => Cmd.none
                => NoOp

        SetUsername username ->
            { model | username = username }
                => Cmd.none
                => NoOp

        SetPassword password ->
            { model | password = password }
                => Cmd.none
                => NoOp

        RegisterCompleted (Err error) ->
            let
                errorMessages =
                    case error of
                        Http.BadStatus response ->
                            response.body
                                |> decodeString (field "errors" errorsDecoder)
                                |> Result.withDefault []

                        _ ->
                            [ "unable to process registration" ]
            in
                { model | errors = List.map (\errorMessage -> Form => errorMessage) errorMessages }
                    => Cmd.none
                    => NoOp

        RegisterCompleted (Ok session) ->
            model
                => Cmd.batch [ storeSession session, Route.modifyUrl Route.Home ]
                => SetSession session



-- VALIDATION --


type Field
    = Form
    | Username
    | Name
    | Password


type alias Error =
    ( Field, String )


validate : Model -> List Error
validate =
    Validate.all
        [ .username >> ifBlank (Username => "username can't be blank.")
        , .name >> ifBlank (Name => "name can't be blank.")
        , .password >> ifBlank (Password => "password can't be blank.")
        ]


errorsDecoder : Decoder (List String)
errorsDecoder =
    decode (\name username password -> List.concat [ name, username, password ])
        |> optionalError "name"
        |> optionalError "username"
        |> optionalError "password"


optionalError : String -> Decoder (List String -> a) -> Decoder a
optionalError fieldName =
    let
        errorToString errorMessage =
            String.join " " [ fieldName, errorMessage ]
    in
        optional fieldName (Decode.list (Decode.map errorToString string)) []
