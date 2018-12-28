import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Json.Decode exposing (Decoder, field, string)
import Json.Encode as Encode


main =
  Browser.element
    { init = init
    , view = view
    , update = update
    , subscriptions = subscriptions
    }


type alias Model =
  { email : String
  , password : String
  }


init : () -> (Model, Cmd Msg)
init _ =
  (Model "" "", Cmd.none)


-- UPDATE


type Msg
  = Noop
  | Email String
  | Password String
  | Submit
  | Success
  | Failure
  | Authenticated (Result Http.Error String)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
  case msg of
    Noop ->
      (model, Cmd.none)
    Email email ->
      ({ model | email = email }, Cmd.none)
    Password password ->
      ({ model | password = password }, Cmd.none)
    Submit ->
      (model, remoteLogin model)
    Failure ->
      (model, Cmd.none)
    Success ->
      (model, Cmd.none)
    Authenticated result ->
      case result of
        Ok _ ->
          (model, Cmd.none)
        Err _ ->
          (model, Cmd.none)


-- VIEW


view : Model -> Html Msg
view model =
  div []
    [ viewInput "text" "Email" model.email Email
    , viewInput "password" "Password" model.password Password
    , button [ onClick Submit ] [ text "Login" ]
    ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
  input [ type_ t, placeholder p, value v, onInput toMsg ] []


-- SUBSCRIPTIONS


subscriptions : Model -> Sub Msg
subscriptions model =
  Sub.none


-- HTTP
remoteLogin : Model -> Cmd Msg
remoteLogin model =
  Http.post
    { url = "http://localhost:3000/login"
    , body = credsEncoder model |> Http.jsonBody
    , expect = Http.expectJson Authenticated userDecoder
    }

credsEncoder : Model -> Encode.Value
credsEncoder model =
    let
        attributes =
            [ ( "email", Encode.string model.email )
            , ( "password", Encode.string model.password )
            ]
    in
        Encode.object attributes

userDecoder : Decoder String
userDecoder =
  field "user_id" string
