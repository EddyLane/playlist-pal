module App.Events.Model exposing (..)

import Json.Decode as Decode
import Bootstrap.Modal as Modal


type alias Event =
    { id : Maybe Int
    , name : String
    , slug : Maybe String
    }


type alias Model =
    { events : List Event
    , newForm : Event
    , submitting : Bool
    , formModalState : Modal.State
    , lastCreatedId : Maybe Int
    }


eventDecoder : Decode.Decoder Event
eventDecoder =
    Decode.map3
        Event
        (Decode.maybe (Decode.at [ "id" ] Decode.int))
        (Decode.at [ "name" ] Decode.string)
        (Decode.maybe (Decode.at [ "slug" ] Decode.string))


initialModel : Model
initialModel =
    { events = []
    , newForm =
        { id = Nothing
        , name = ""
        , slug = Nothing
        }
    , submitting = False
    , formModalState = Modal.hiddenState
    , lastCreatedId = Nothing
    }
