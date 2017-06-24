module Page.Login exposing (view, update, Model, Msg, initialModel, ExternalMsg(..))

{-| The login page.
-}

import Route exposing (Route)
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Views.Form as Form
import Json.Decode as Decode exposing (field, decodeString, string, Decoder)
import Json.Decode.Pipeline as Pipeline exposing (optional, decode)
import Validate exposing (..)
import Data.Session as Session exposing (Session)
import Http
import Util exposing ((=>))
import Data.User as User exposing (User)
import Request.User exposing (storeSession)

-- MODEL --


type alias Model =
    { errors : List Error
    , username : String
    , password : String
    }


initialModel : Model
initialModel =
    { errors = []
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
                    [ h1 [ class "text-xs-center" ] [ text "Sign in" ]
                    , p [ class "text-xs-center" ]
                        [ a []
                            [ text "Need an account?" ]
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
        , Form.password
            [ class "form-control-lg"
            , placeholder "Password"
            , onInput SetPassword
            ]
            []
        , button [ class "btn btn-lg btn-primary pull-xs-right" ]
            [ text "Sign in" ]
        ]

-- UPDATE --


type Msg
    = SubmitForm
    | SetUsername String
    | SetPassword String
    | LoginCompleted (Result Http.Error User)


type ExternalMsg
    = NoOp
    | SetUser User


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        SubmitForm ->
            case validate model of
                [] ->
                    { model | errors = [] }
                        => Http.send LoginCompleted (Request.User.login model)
                        => NoOp

                errors ->
                    { model | errors = errors }
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

        LoginCompleted (Err error) ->
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
                { model | errors = List.map (\errorMessage -> (Form, errorMessage)) errorMessages }
                    => Cmd.none
                    => NoOp

        LoginCompleted (Ok user) ->
            model
                => Cmd.batch [ storeSession user, Route.modifyUrl Route.Home ]
                => SetUser user





-- VALIDATION --


type Field
    = Form
    | Username
    | Password


type alias Error =
    ( Field, String )


validate : Model -> List Error
validate =
    Validate.all
        [ .username >> ifBlank (Username => "username can't be blank.")
        , .password >> ifBlank (Password => "password can't be blank.")
        ]


errorsDecoder : Decoder (List String)
errorsDecoder =
    decode (\username password -> List.concat [ username, password ])
        |> optionalError "username"
        |> optionalError "password"


optionalError : String -> Decoder (List String -> a) -> Decoder a
optionalError fieldName =
    let
        errorToString errorMessage =
            String.join " " [ fieldName, errorMessage ]
    in
        optional fieldName (Decode.list (Decode.map errorToString string)) []
