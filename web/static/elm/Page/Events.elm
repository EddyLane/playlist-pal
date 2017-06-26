module Page.Events exposing (..)

{-| The events page
-}

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (..)
import Data.Session as Session exposing (Session)
import Bootstrap.Form as Form
import Bootstrap.Form.Input as Input
import Bootstrap.Button as Button
import Util exposing ((=>))

-- MODEL --

type alias Model =
    { submitting : Bool
    , name : String
    }


initialModel : Model
initialModel =
    { submitting = False
    , name = ""
    }

-- UPDATE

type Msg
    = SubmitForm
    | SetName String

type ExternalMsg
    = NoOp

-- VIEW --

form : Model -> Html Msg
form model =
    Form.form [ onSubmit SubmitForm ]
        [ Form.group []
            [ Form.label [ for "name" ] [ text "Name" ]
            , Input.text
                [ Input.attrs
                    [ value model.name
                    ]
                , Input.id "name"
                ]
            ]
        , Button.button
            [ Button.primary
            , Button.attrs
                [ type_ "button"
                , disabled model.submitting
                ]
            ]
            [ text "Submit" ]
        ]

view : Session -> Model -> Html Msg
view session model =
    div [ class "auth-page" ]
        [ form model ]


-- UPDATE --

update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of

        SetName name ->
            { model | name = name }
                => Cmd.none
                => NoOp

        SubmitForm ->
            model
                => Cmd.none
                => NoOp