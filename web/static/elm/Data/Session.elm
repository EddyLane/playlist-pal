module Data.Session exposing (Session)

import Data.User as User exposing (User)
import Util exposing ((=>))

type alias Session =
    { user : Maybe User }