module Data.Event exposing (Event, decoder)

import Json.Decode as Decode exposing (Decoder)

type alias Event =
    { id : Int
    , name : String
    , slug : String
    }

decoder : Decoder Event
decoder =
    Decode.map3
        Event
        (Decode.at [ "id" ] Decode.int)
        (Decode.at [ "name" ] Decode.string)
        (Decode.at [ "slug" ] Decode.string)