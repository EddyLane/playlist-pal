module Main exposing (..)

import Phoenix
import Phoenix.Socket as Socket exposing (Socket)
import App.Model exposing (..)
import App.View exposing (view)
import App.Update exposing (update)
import App.Msg exposing (..)
import Time
import App.Session.View exposing (lobby)
import App.Events.View exposing (eventChannel)
import Navigation exposing (programWithFlags)


socket : String -> Socket Msg
socket accessToken =
    Socket.init "ws://localhost:4000/socket/websocket"
        |> Socket.withParams [ ( "guardian_token", accessToken ) ]
        |> Socket.heartbeatIntervallSeconds 20
        |> Socket.withDebug


phoenixSubscription : Model -> Sub Msg
phoenixSubscription model =
    let
        subs =
            case model.session.user of
                Just user ->
                    [ lobby, user |> eventChannel ]

                Nothing ->
                    [ lobby ]

        phoenixSocket =
            socket model.session.token
    in
        Phoenix.connect phoenixSocket subs


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch
        [ phoenixSubscription model
        , Time.every Time.second Tick
        ]


main : Program Flags Model Msg
main =
    programWithFlags UrlChange
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
