port module LongList exposing (..)

import Html exposing (..)
import Html.Attributes as HtmlAttributes exposing (type_, checked, placeholder, value, property)
import Html.Events exposing (..)
import List.Extra exposing (elemIndex, remove)
import Regex
import Json.Encode as Encode
import Platform.Sub exposing (Sub)
import Html.Keyed as Keyed
import LongList.ScrollUtils as ScrollUtils
import LongList.Styles as Css
import Html.CssHelpers


{ id, class, classList } =
    Html.CssHelpers.withNamespace "long-list"


type alias Model =
    { items : List Item
    , filterBy : String
    , selectedItems : List Item
    , dropDownIsOpen : Bool
    , selectedFilter : Filter
    , hasNoneCheckbox : Bool
    , includeNoneUnknown : Bool
    , allSelected : Bool
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
    }


type alias Item =
    { name : String
    , id : Int
    }


type Filter
    = BeginsWith
    | Contains


type Msg
    = Input String
    | Select Item
    | SelectAll
    | ToggleDropDown
    | SelectFilter Filter
    | ReturnItems Bool
    | ToggleIncludeNoneUnknown
    | Scroll ScrollUtils.Pos


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { items = flags.options
      , filterBy = ""
      , selectedItems = flags.selectedOptions
      , dropDownIsOpen = False
      , selectedFilter = BeginsWith
      , hasNoneCheckbox = flags.hasNoneCheckbox
      , includeNoneUnknown = flags.includeNoneUnknown
      , allSelected = False
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        Input text ->
            ( { model | filterBy = text }, Cmd.none )

        Select item ->
            let
                newSelectedItems =
                    if (elemIndex item model.selectedItems) /= Nothing then
                        remove item model.selectedItems
                    else
                        List.append [ item ] model.selectedItems
            in
                ( { model | selectedItems = newSelectedItems }, Cmd.none )

        SelectAll ->
            let
                newSelectedItems =
                    if (List.length model.items) == (List.length model.selectedItems) then
                        []
                    else
                        model.items

                allSelected =
                    not <| (List.length model.items) == (List.length model.selectedItems)
            in
                ( { model
                    | selectedItems = newSelectedItems
                    , allSelected = allSelected
                  }
                , Cmd.none
                )

        ToggleDropDown ->
            ( { model | dropDownIsOpen = not model.dropDownIsOpen }, Cmd.none )

        SelectFilter filter ->
            ( { model
                | selectedFilter = filter
                , dropDownIsOpen = False
              }
            , Cmd.none
            )

        ReturnItems bool ->
            ( model, getValuesReturn { values = model.selectedItems, includeNoneUnknown = model.includeNoneUnknown } )

        ToggleIncludeNoneUnknown ->
            ( { model | includeNoneUnknown = not model.includeNoneUnknown }, Cmd.none )

        Scroll pos ->
            let
                a =
                    Debug.log "A" pos
            in
                ( model, Cmd.none )


renderDropDownButton : Model -> Html Msg
renderDropDownButton { dropDownIsOpen, selectedFilter } =
    let
        dropdown =
            if dropDownIsOpen then
                div [ class [ Css.PopupContainer ] ]
                    [ ul []
                        [ li [ class [ Css.DropDownItem ], onClick (SelectFilter BeginsWith) ] [ text "Begins With" ]
                        , li [ class [ Css.DropDownItem ], onClick (SelectFilter Contains) ] [ text "Contains" ]
                        ]
                    ]
            else
                text ""

        label =
            case selectedFilter of
                BeginsWith ->
                    "Begins With"

                Contains ->
                    "Contains"
    in
        div [ class [ Css.DropDownButtonContainer ] ]
            [ div [ class [ Css.ToggleButton ] ]
                [ span [ class [ Css.ActiveTitle ], onClick ToggleDropDown ]
                    [ text label
                    , i
                        [ class [ Css.CaretIcon ]
                        , HtmlAttributes.classList [ ( "fa", True ), ( "fa-caret-down", True ) ]
                        ]
                        []
                    ]
                ]
            , dropdown
            ]


isSelected : Item -> List Item -> Bool
isSelected item selectedItems =
    let
        index =
            elemIndex item selectedItems
    in
        index /= Nothing


renderItem : Item -> Bool -> Html Msg
renderItem item isSelected =
    label
        [ classList [ ( Css.Item, True ), ( Css.Checked, isSelected ) ] ]
        [ input [ type_ "checkbox", onClick (Select item), checked isSelected ] []
        , span [] [ text item.name ]
        ]


getFilter : Filter -> (String -> String -> Bool)
getFilter selectedFilter filterBy string =
    let
        regex =
            case selectedFilter of
                BeginsWith ->
                    "^" ++ filterBy

                Contains ->
                    filterBy
    in
        Regex.regex regex
            |> Regex.caseInsensitive
            |> flip (Regex.contains) string


renderItemsList : Model -> Html Msg
renderItemsList { items, selectedItems, selectedFilter, filterBy, allSelected } =
    let
        filter =
            getFilter selectedFilter
    in
        Keyed.node "div"
            [ class [ Css.ListContainer ] ]
            (List.filterMap
                (\item ->
                    if filterBy == "" || filter filterBy item.name then
                        Just ( item.name, renderItem item (allSelected || (isSelected item selectedItems)) )
                    else
                        Nothing
                )
                items
            )


renderListInfo : Int -> Int -> Html Msg
renderListInfo selectedCount totalCount =
    div [ class [ Css.ListInfo ] ]
        [ span [] [ text (toString selectedCount ++ " item(s) currently selected") ]
        , span [] [ text (toString totalCount ++ " item(s)") ]
        ]


renderIncludeNoneUnknown : Model -> Html Msg
renderIncludeNoneUnknown { includeNoneUnknown } =
    label
        [ class [ Css.ListOptions ] ]
        [ input [ type_ "checkbox", onClick (ToggleIncludeNoneUnknown), checked includeNoneUnknown ] []
        , text "Include None/Unknown"
        ]


indeterminate : Bool -> Attribute msg
indeterminate isIntermediate =
    property "indeterminate" (Encode.bool isIntermediate)


view : Model -> Html Msg
view model =
    let
        isIntermediate =
            (List.length model.selectedItems) > 0 && (List.length model.selectedItems) < (List.length model.items)

        noneUnknown =
            if model.hasNoneCheckbox then
                renderIncludeNoneUnknown model
            else
                text ""
    in
        div [ class [ Css.Container ] ]
            [ div [ class [ Css.ListFilter ] ]
                [ input
                    [ type_ "text"
                    , class [ Css.FilterInput ]
                    , onInput Input
                    , value model.filterBy
                    , placeholder "Type to filter"
                    ]
                    []
                , renderDropDownButton model
                ]
            , div []
                [ label [ class [ Css.Header ] ]
                    [ input [ type_ "checkbox", onClick SelectAll, checked model.allSelected, indeterminate isIntermediate ] []
                    , text ""
                    ]
                , renderItemsList model
                ]
            , renderListInfo (List.length model.selectedItems) (List.length model.items)
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
