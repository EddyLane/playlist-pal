import Html exposing (..)
import Html.Attributes exposing (class)

main : Html.Html msg
main =
  div [ class "jumbotron" ] [
  h3 [] [ text "Hello from Elm and Phoenix!" ],
  p [] [ text "You good?" ]
  ]