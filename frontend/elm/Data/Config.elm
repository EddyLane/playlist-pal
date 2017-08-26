module Data.Config exposing (Config, decoder, defaultModel)

import Json.Decode as Decode exposing (Decoder)
import Data.ApiUrl as ApiUrl exposing (ApiUrl)

type alias Config =
    { apiUrl : ApiUrl }


decoder : Decoder Config
decoder =
    Decode.map
        Config
        (Decode.at [ "apiUrl" ] ApiUrl.decoder)


defaultModel : Config
defaultModel = { apiUrl = ApiUrl.stringToApiUrl "" }