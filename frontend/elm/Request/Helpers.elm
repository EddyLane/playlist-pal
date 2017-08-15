module Request.Helpers exposing (apiUrl)


apiUrl : String -> String
apiUrl str =
    "http://playlist-pal.local:4000/api" ++ str
