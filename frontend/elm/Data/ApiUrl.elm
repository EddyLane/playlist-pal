module Data.ApiUrl exposing (ApiUrl, encode, decoder, apiUrlToString, stringToApiUrl)

import Json.Encode as Encode exposing (Value)
import Json.Decode as Decode exposing (Decoder)


type ApiUrl
    = ApiUrl String


encode : ApiUrl -> Value
encode (ApiUrl token) =
    Encode.string token


apiUrlToString : ApiUrl -> String
apiUrlToString (ApiUrl url) =
    url


stringToApiUrl : String -> ApiUrl
stringToApiUrl string =
    ApiUrl string


decoder : Decoder ApiUrl
decoder =
    Decode.string
        |> Decode.map ApiUrl
