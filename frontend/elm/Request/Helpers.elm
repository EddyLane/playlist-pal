module Request.Helpers exposing (apiUrl)

import Data.ApiUrl as ApiUrl exposing (ApiUrl, apiUrlToString)


apiUrl : ApiUrl -> String -> String
apiUrl baseUrl str =
    "http://" ++ (apiUrlToString baseUrl) ++ "/v1" ++ str
