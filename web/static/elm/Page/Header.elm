module Page.Header exposing (Model, Msg, initialState, viewHeader, update, subscriptions)

import Bootstrap.Navbar as Navbar
import Util exposing ((=>))
import Views.Page as Page exposing (ActivePage(..))
import Data.User as User exposing (User, Username, usernameToHtml)
import Bootstrap.Navbar as Navbar
import Html.Lazy exposing (lazy2)
import Views.Spinner exposing (spinner)
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
        |> Navbar.items
            [ Navbar.itemLink [ Route.href Route.Home ] [ text "Home" ]
            , Navbar.itemLink [ Route.href Route.Events ] [ text "Events" ]
            ]
        |> Navbar.view model.navbarState



--
--
--    nav [ class "navbar navbar-light" ]
--        [ div [ class "container" ]
--            [ a [ class "navbar-brand", Route.href Route.Home ]
--                [ text "PlaylistPal" ]
--            , ul [ class "nav navbar-nav pull-xs-right" ] <|
--                lazy2 Util.viewIf isLoading spinner
--                    :: (navbarLink (page == Page.Home) Route.Home [ text "Home" ])
--                    :: viewSignIn page user
--            ]
--        ]


navbarLink : Bool -> Route -> List (Html msg) -> Html msg
navbarLink isActive route linkContent =
    li [ classList [ ( "nav-item", True ), ( "active", isActive ) ] ]
        [ a [ class "nav-link", Route.href route ] linkContent ]


viewSignIn : ActivePage -> Maybe User -> List (Html msg)
viewSignIn page user =
    case user of
        Nothing ->
            [ navbarLink (page == Login) Route.Login [ text "Sign in" ]
            ]

        Just user ->
            [ navbarLink
                True
                Route.Home
                [ User.usernameToHtml user.username
                ]
            , navbarLink False Route.Logout [ text "Sign out" ]
            , navbarLink False Route.Events [ text "Events" ]
            ]
