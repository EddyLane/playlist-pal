module App.Model exposing (..)

import App.Session.Model as Session
import App.SearchForm.Model as SearchForm
import App.Events.Model as Events
import App.LoginForm.Model as LoginForm
import App.Msg exposing (..)
import Navigation exposing (Location)
import UrlParser as Url exposing ((</>), (<?>), s, int, string, stringParam, top, parseHash)
import App.Session.Update exposing (guardianTokenRequest)


type Route
    = Home
    | Event String


type alias Model =
    { session : Session.Model
    , searchForm : SearchForm.Model
    , events : Events.Model
    , history : List (Maybe Route)
    , loginForm : LoginForm.Model
    }


type alias Flags =
    {}


route : Url.Parser (Route -> a) a
route =
    Url.oneOf
        [ Url.map Home top
        , Url.map Event (s "event" </> string)
        ]


initialModel : Flags -> Location -> Model
initialModel flags location =
    { session = Session.initialModel
    , searchForm = SearchForm.initialModel
    , events = Events.initialModel
    , history = [ parseHash route location ]
    , loginForm = LoginForm.initialModel
    }


init : Flags -> Location -> ( Model, Cmd Msg )
init flags location =
    ( (initialModel flags location), guardianTokenRequest )
