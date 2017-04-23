module Msg.Session exposing (..)

import Json.Encode

type Msg
    = NoOp
    | UserConnected Json.Encode.Value