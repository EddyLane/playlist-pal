module Page.Header exposing (Model, Msg, initialState, viewHeader, update, subscriptions)

import Bootstrap.Navbar as Navbar
import Util exposing ((=>))
import Views.Page as Page exposing (ActivePage(..))
import Data.User as User exposing (User, Username, usernameToHtml)
import Bootstrap.Navbar as Navbar
import Html exposing (..)
import Html.Attributes exposing (..)
import Route exposing (Route)


type alias Model =
    { navbarState : Navbar.State }


type Msg
    = NavbarMsg Navbar.State


type ExternalMsg
    = NoOp


initialState : ( Model, Cmd Msg )
initialState =
    let
        ( navbarState, navbarCmd ) =
            Navbar.initialState NavbarMsg
    in
        { navbarState = navbarState }
            => navbarCmd


subscriptions : Model -> Sub Msg
subscriptions model =
    Navbar.subscriptions model.navbarState NavbarMsg


update : Msg -> Model -> ( ( Model, Cmd Msg ), ExternalMsg )
update msg model =
    case msg of
        NavbarMsg state ->
            { model | navbarState = state }
                => Cmd.none
                => NoOp


viewHeader : Model -> Maybe User -> Bool -> ActivePage -> Html Msg
viewHeader model user isLoading page =
    Navbar.config NavbarMsg
        |> Navbar.withAnimation
        |> Navbar.brand [ Route.href Route.Home ] [ text "PlaylistPal" ]
        |> Navbar.items (navbarItems user page)
        |> Navbar.view model.navbarState


navbarItems : Maybe User -> ActivePage -> List (Navbar.Item msg)
navbarItems user page =
    [ navbarLink (page == Page.Home) Route.Home [ text "Home" ] ] ++ viewSignIn page user


navbarLink : Bool -> Route -> List (Html msg) -> Navbar.Item msg
navbarLink isActive route linkContent =
    Navbar.itemLink [ classList [ ( "active", isActive ) ], Route.href route ] linkContent


viewSignIn : ActivePage -> Maybe User -> List (Navbar.Item msg)
viewSignIn page user =
    case user of
        Nothing ->
            [ navbarLink (page == Login) Route.Login [ text "Sign in" ]
            , navbarLink (page == Register) Route.Register [ text "Sign up" ]
            ]

        Just user ->
            [ navbarLink False Route.Logout [ text "Sign out" ]
            , navbarLink (page == Page.Events) Route.Events [ text "Events" ]
            ]
