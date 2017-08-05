module Request.Events exposing (..)

import Http
import Data.Event as Event exposing (Event, decoder)
import Json.Encode as Encode
import Json.Decode as Decode
import Util exposing ((=>))
import Request.Helpers exposing (apiUrl)


create : { r | name : String } -> Http.Request Event
create { name } =
    let
        event =
            Encode.object
                [ "name" => Encode.string name ]

        body =
            Encode.object [ "event" => event ]
                |> Http.jsonBody
    in
        Decode.field "event" Event.decoder
            |> Http.post (apiUrl "/events") (Debug.log "body" body)
