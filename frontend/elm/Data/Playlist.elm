module Data.Playlist exposing (Playlist, decoder, slugToString, Slug, slugParser)

import Json.Decode as Decode exposing (Decoder)
import UrlParser

type alias Playlist =
    { id : Int
    , name : String
    , slug : Slug
    }


-- Identifiers --

type Slug
    = Slug String

slugParser : UrlParser.Parser (Slug -> a) a
slugParser =
    UrlParser.custom "SLUG" (Ok << Slug)


slugToString : Slug -> String
slugToString (Slug slug) =
    slug


-- Serialization --

decoder : Decoder Playlist
decoder =
    Decode.map3
        Playlist
        (Decode.at [ "id" ] Decode.int)
        (Decode.at [ "name" ] Decode.string)
        (Decode.at [ "slug" ] (Decode.map Slug Decode.string))
