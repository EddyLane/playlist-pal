module Data.Playlist exposing (Playlist, decoder)

import Json.Decode as Decode exposing (Decoder)


type alias Playlist =
    { id : Int
    , name : String
    , slug : String
    }


decoder : Decoder Playlist
decoder =
    Decode.map3
        Playlist
        (Decode.at [ "id" ] Decode.int)
        (Decode.at [ "name" ] Decode.string)
        (Decode.at [ "slug" ] Decode.string)
