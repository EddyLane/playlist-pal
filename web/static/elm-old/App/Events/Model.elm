module App.Events.Model exposing (..)

import Json.Decode as Decode
import Bootstrap.Modal as Modal
import Http


type alias Event =
    { id : Maybe Int
    , name : String
    , slug : Maybe String
    }


type alias Errors =
    { name : List String
    }


type alias Model =
    { events : List Event
    , newForm : Event
    , submitting : Bool
    , formModalState : Modal.State
    , lastCreatedId : Maybe Int
    , hasError : Maybe Http.Error
    , errorPresentTime : Int
    , errors : Errors
    }


errorDecoder : Decode.Decoder Errors
errorDecoder =
    Decode.map
        Errors
        (Decode.at [ "errors" ]
            (Decode.at [ "name" ]
                (Decode.list Decode.string)
            )
        )


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
    , hasError = Nothing
    , errorPresentTime = 0
    , errors = { name = [] }
    }
