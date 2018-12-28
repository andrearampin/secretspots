import Browser
import Html exposing (..)


main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


type alias Model =
  {}


init : () -> (Model, Cmd Msg)
init _ =
  (Model, Cmd.none)


-- UPDATE


type Msg
  = Noop


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Noop ->
      ( model, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ text "Hello world!"
    ]



-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none
