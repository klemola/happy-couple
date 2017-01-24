port module Main exposing (..)

import Html exposing (..)
import Html.Attributes exposing (style)
import Html.Events exposing (onClick)
import Json.Decode as Decode exposing (Value)


-- outgoing port


port prompt : String -> Cmd msg



-- incoming port


port userInput : (Value -> msg) -> Sub msg



-- app


type alias Model =
    { userInput : Result String String
    }


type Msg
    = OpenPrompt
    | ReceiveInput Value


main : Program Never Model Msg
main =
    Html.program
        { init = init
        , update = update
        , view = view
        , subscriptions = \_ -> userInput ReceiveInput
        }


init : ( Model, Cmd Msg )
init =
    ( { userInput = Ok "Initial value"
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        OpenPrompt ->
            ( model, prompt "Type something" )

        ReceiveInput value ->
            let
                -- We could just use a "String" type for incoming data.
                -- If we did though, we'd lose information on when user submitted an empty response
                -- Decoded result is either an actual input string or an error with a message.
                decodedValue =
                    Decode.decodeValue Decode.string value
            in
                ( { model | userInput = decodedValue }, Cmd.none )


view : Model -> Html Msg
view model =
    div []
        [ h1 [] [ text "Prompt demo" ]
        , p [] [ text "I'm an Elm app!" ]
        , button [ onClick OpenPrompt ] [ text "Open prompt" ]
        , h4 [] [ text "User input" ]
        , (case model.userInput of
            Ok input ->
                p [] [ text input ]

            Err message ->
                p []
                    [ span [] [ text "Invalid input: " ]
                    , span [ style [ ( "color", "red" ) ] ] [ text message ]
                    ]
          )
        ]
