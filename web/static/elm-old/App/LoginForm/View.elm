module App.LoginForm.View exposing (..)

import App.LoginForm.Model exposing (..)
import App.LoginForm.Msg exposing (..)
import App.Msg as BaseMsg
import App.LoginForm.Msg exposing (..)
import Html exposing (..)
import Html.Attributes exposing (..)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button
import Bootstrap.Alert as Alert
import Html.Attributes exposing (value, type_, disabled)
import Html.Events exposing (onInput, onClick)
import Validate exposing (..)

msg : (a -> Msg) -> a -> BaseMsg.Msg
msg msgType value =
    msgType value |> BaseMsg.MsgForLoginForm


form : Model -> Html BaseMsg.Msg
form model =
    Form.form []
        [ Form.group []
            [ Form.label [ for "username" ] [ text "Username" ]
            , Input.text
                [ Input.attrs
                    [ value model.username
                    , onInput (msg SetUsername)
                    ]
                , Input.id "username"
                ]
            ]
        , Form.group []
            [ Form.label [ for "password" ] [ text "Password" ]
            , Input.password
                [ Input.attrs
                    [ value model.password
                    , onInput (msg SetPassword)
                    ]
                , Input.id "password"
                ]
            ]
        , Button.button
            [ Button.primary
            , Button.attrs
                [ type_ "button"
                , onClick (SubmitLogin |> BaseMsg.MsgForLoginForm)
                , disabled model.submitting
                ]
            ]
            [ text "Submit" ]
        ]


alert : String -> Html BaseMsg.Msg
alert error =
    Alert.warning [ text error ]


view : Model -> Html BaseMsg.Msg
view model =
    case model.error of
        Just error ->
            div [] [ alert error, form model ]

        Nothing ->
            form model

type Field
    = Form
    | Username
    | Password

type alias Error =
    ( Field, String )

(=>) : a -> b -> ( a, b )
(=>) =
    (,)

validate : Model -> List Error
validate =
    Validate.all
        [ .username >> ifBlank (Username => "username can't be blank.")
        , .password >> ifBlank (Password => "password can't be blank.")
        ]
