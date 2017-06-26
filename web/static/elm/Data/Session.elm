module Data.Session exposing (Session)

import Data.User as User exposing (User)
import Data.Event as Event exposing (Event)

type alias Session =
    { user : Maybe User, events: List Event }
