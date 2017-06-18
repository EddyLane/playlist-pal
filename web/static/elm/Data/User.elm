module Data.User exposing (User, Username)

type alias User =
    { username : String
    , name : String
    }

type Username
    = Username String