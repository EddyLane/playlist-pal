module App.LoginForm.Update exposing (..)

import App.LoginForm.Msg exposing (..)
import App.LoginForm.Model exposing (Model)
import App.Msg as BaseMsg
import Http
import Json.Decode as Decode
import Json.Encode as Encode
import App.Session.Update exposing (guardianTokenRequest)
import App.LoginForm.View exposing (validate)

submitLogin : String -> String -> Cmd BaseMsg.Msg
submitLogin username password =
    let
        structure =
            [ ( "username", Encode.string username )
            , ( "password", Encode.string password )
            ]

        url =
            "/api/login"

        request =
            Http.post url (Encode.object ([ ( "user", Encode.object (structure) ) ]) |> Http.jsonBody) Decode.string
    in
        Http.send (SubmitLoginResponse >> BaseMsg.MsgForLoginForm) request


update : Msg -> Model -> ( Model, Cmd BaseMsg.Msg )
update msg loginForm =
    case msg of
        SetUsername username ->
            ( { loginForm | username = username }, Cmd.none )

        SetPassword password ->
            ( { loginForm | password = password }, Cmd.none )

        SubmitLogin ->
            case validate loginForm of
                [] ->
                    ( { loginForm | error = Nothing, submitting = True }, (submitLogin loginForm.username loginForm.password) )
                errors ->
                    ( { loginForm | error = Nothing, submitting = True }, (submitLogin loginForm.username loginForm.password) )

        SubmitLoginResponse (Ok res) ->
            ( { loginForm | error = Nothing, submitting = False }, guardianTokenRequest )

        SubmitLoginResponse (Err err) ->
            let
                message =
                    case err of
                        Http.BadStatus _ ->
                            "Incorrect login details"

                        _ ->
                            "Something went wrong"
            in
                ( { loginForm | error = Just message, submitting = False }, Cmd.none )
