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
import Html.Attributes exposing (value, type_, disabled)
import Html.Events exposing (onInput, onClick)


msg : (a -> Msg) -> a -> BaseMsg.Msg
msg msgType value =
    msgType value |> BaseMsg.MsgForLoginForm


view : Model -> Html BaseMsg.Msg
view model =
    Form.form []
        [ Form.group []
            [ Form.label [ for "username" ] [ text "Username" ]
            , Input.text
                [ Input.attrs
                    [ value model.username
                    , onInput (msg Username)
                    ]
                , Input.id "username"
                ]
            ]
        , Form.group []
            [ Form.label [ for "password" ] [ text "Password" ]
            , Input.password
                [ Input.attrs
                    [ value model.password
                    , onInput (msg Password)
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
