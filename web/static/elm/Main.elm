module Main exposing (..)

import Html exposing (programWithFlags)
import Phoenix
import Phoenix.Socket as Socket exposing (Socket)
import App.Model exposing (init, Model, Flags)
import App.View exposing (view)
import App.Update exposing (update)
import App.Msg exposing (..)
import Time
import App.Session.View exposing (lobby)


socket : String -> Socket Msg
socket accessToken =
    Socket.init "ws://localhost:4000/socket/websocket"
        |> Socket.withParams [ ( "guardian_token", accessToken ) ]
        |> Socket.heartbeatIntervallSeconds 20
        |> Socket.withDebug


phoenixSubscription : Model -> Sub Msg
phoenixSubscription model =
    Phoenix.connect (socket model.session.token) [ lobby ]


subscriptions : Model -> Sub Msg
subscriptions model =
    Sub.batch [ phoenixSubscription model, Time.every Time.second Tick ]


main : Program Flags Model Msg
main =
    programWithFlags
        { init = init
        , view = view
        , update = update
        , subscriptions = subscriptions
        }
