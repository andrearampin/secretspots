module Main exposing (..)

import Browser
import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (onClick, onInput)
import Http exposing (..)
import Json.Decode exposing (Decoder, field, int)
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
    , id : Maybe Int
    }


init : () -> ( Model, Cmd Msg )
init _ =
    ( { email = "", password = "", id = Nothing }, Cmd.none )



-- UPDATE


type Msg
    = SetEmail String
    | SetPassword String
    | Submit
    | Remote (Result Http.Error Int)


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        SetEmail email ->
            ( { model | email = email }, Cmd.none )

        SetPassword password ->
            ( { model | password = password }, Cmd.none )

        Submit ->
            ( model, remoteLogin model )

        Remote result ->
            case result of
                Ok value ->
                    ( { model | id = Just value }, Cmd.none )

                Err _ ->
                    ( { model | id = Nothing }, Cmd.none )



-- VIEW


view : Model -> Html Msg
view model =
    div []
        [ viewInput "text" "Email" model.email SetEmail
        , viewInput "password" "Password" model.password SetPassword
        , button [ onClick Submit ] [ text "Login" ]
        , text (viewUserId model)
        ]


viewInput : String -> String -> String -> (String -> msg) -> Html msg
viewInput t p v toMsg =
    input [ type_ t, placeholder p, value v, onInput toMsg ] []


viewUserId : Model -> String
viewUserId model =
    case model.id of
        Nothing ->
            ""

        Just id ->
            String.fromInt id



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
        , expect = Http.expectJson Remote userDecoder
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


userDecoder : Decoder Int
userDecoder =
    field "user_id" int
