module Page.Home exposing (view, update, Model, Msg, initialModel)

{-| The homepage. You can get here via either the / or /#/ routes.
-}

import Html exposing (..)
import Html.Attributes exposing (class, href, id, placeholder, attribute, classList)
import Data.Session as Session exposing (Session)
import Util exposing ((=>), onClickStopPropagation)
import Bootstrap.Grid as Grid


-- MODEL --


initialModel : Model
initialModel =
    {}


type alias Model =
    {}



-- VIEW --


view : Session -> Model -> Html Msg
view session model =
    Grid.container []
        [ Grid.row []
            [ Grid.col []
                [ div [ class "jumbotron" ]
                    [ h1 [ class "display-3" ] [ text "Homepage" ]
                    , p [ class "lead" ] [ text "Welcome to the goddamn homepage mofo" ]
                    ]
                ]
            ]
        ]


type Msg
    = NoOp


update : Session -> Msg -> Model -> ( Model, Cmd Msg )
update session msg model =
    case msg of
        _ ->
            model => Cmd.none
