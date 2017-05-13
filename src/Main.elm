port module Main exposing (..)

import Html exposing (..)
import Html.Attributes as HtmlAttributes exposing (type_, checked)
import Html.Events exposing (onClick)
import Html.CssHelpers
import LongList
import Styles as Css


{ id, class, classList } =
    Html.CssHelpers.withNamespace "main"


type alias Model =
    { includeNoneUnknown : Bool
    , hasNoneCheckbox : Bool
    , longList : LongList.Model
    }


type alias Item =
    { name : String
    , id : Int
    }


type alias ReturnValues =
    { values : List Item
    , includeNoneUnknown : Bool
    }


type alias Flags =
    { options : List Item
    , selectedOptions : List Item
    , hasNoneCheckbox : Bool
    , includeNoneUnknown : Bool
    , containerHeight : Int
    , elementHeight : Int
    }


type Msg
    = ToggleIncludeNoneUnknown
    | ReturnItems Bool
    | LongListMsg LongList.Msg


init : Flags -> ( Model, Cmd Msg )
init flags =
    let
        ( longListModel, longListCmd ) =
            LongList.init
                { items = flags.options
                , selectedItems = flags.selectedOptions
                , containerHeight = flags.containerHeight
                , elementHeight = flags.elementHeight
                }
    in
        ( { hasNoneCheckbox = flags.hasNoneCheckbox
          , includeNoneUnknown = flags.includeNoneUnknown
          , longList = longListModel
          }
        , Cmd.batch [ Cmd.map LongListMsg longListCmd ]
        )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        ToggleIncludeNoneUnknown ->
            ( { model | includeNoneUnknown = not model.includeNoneUnknown }, Cmd.none )

        ReturnItems bool ->
            let
                values =
                    LongList.getSelectedValues model.longList
            in
                ( model, getValuesReturn { values = values, includeNoneUnknown = model.includeNoneUnknown } )

        LongListMsg longListMsg ->
            let
                ( updatedLongListModel, longListCmd ) =
                    LongList.update longListMsg model.longList
            in
                ( { model | longList = updatedLongListModel }, Cmd.map LongListMsg longListCmd )


renderIncludeNoneUnknown : Model -> Html Msg
renderIncludeNoneUnknown { includeNoneUnknown } =
    label
        [ class [ Css.ListOptions ] ]
        [ input [ type_ "checkbox", onClick ToggleIncludeNoneUnknown, checked includeNoneUnknown ] []
        , text "Include None/Unknown"
        ]


view : Model -> Html Msg
view model =
    let
        noneUnknown =
            if model.hasNoneCheckbox then
                renderIncludeNoneUnknown model
            else
                text ""
    in
        div []
            [ Html.map LongListMsg (LongList.view model.longList)
            , noneUnknown
            ]


subscriptions : Model -> Sub Msg
subscriptions model =
    getValues ReturnItems


main : Program Flags Model Msg
main =
    Html.programWithFlags
        { init = init
        , update = update
        , view = view
        , subscriptions = subscriptions
        }


port getValues : (Bool -> msg) -> Sub msg


port getValuesReturn : ReturnValues -> Cmd msg
