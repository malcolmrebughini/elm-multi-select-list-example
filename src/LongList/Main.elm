port module LongList exposing (..)

import Html exposing (..)
import Html.Attributes as HtmlAttributes exposing (type_, checked, placeholder, value, style)
import Html.Events exposing (..)
import Regex
import LongList.Styles as Css
import Html.CssHelpers
import Css exposing (px, height)
import LongList.RowVirtualization as RV
import LongList.Utils as Utils


{ id, class, classList } =
    Html.CssHelpers.withNamespace "long-list"


styles : List Css.Mixin -> Attribute msg
styles =
    Css.asPairs >> style


type alias Model =
    { items : List Item
    , displayedItems : List Item
    , displayedItemsCount : Int
    , filterBy : String
    , selectedItems : List Item
    , dropDownIsOpen : Bool
    , selectedFilter : Filter
    , hasNoneCheckbox : Bool
    , includeNoneUnknown : Bool
    , allSelected : Bool
    , rv : RV.Model
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


type alias Item =
    { name : String
    , id : Int
    }


type Filter
    = BeginsWith
    | Contains


type Msg
    = InputFilter String
    | Select Item
    | SelectAll Bool
    | ToggleDropDown
    | SelectFilter Filter
    | ReturnItems Bool
    | ToggleIncludeNoneUnknown
    | Scroll RV.Pos
    | NoOp


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { items = flags.options
      , displayedItems = flags.options
      , displayedItemsCount = List.length flags.options
      , selectedItems = flags.selectedOptions
      , filterBy = ""
      , selectedFilter = BeginsWith
      , dropDownIsOpen = False
      , hasNoneCheckbox = flags.hasNoneCheckbox
      , includeNoneUnknown = flags.includeNoneUnknown
      , allSelected = False
      , rv = RV.init flags.containerHeight flags.elementHeight
      }
    , Cmd.none
    )


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        InputFilter text ->
            let
                ( rvModel, rvCmd ) =
                    RV.resetPosition NoOp model.rv

                displayedItems =
                    filterItems model.selectedFilter text model.items

                displayedItemsCount =
                    List.length displayedItems
            in
                ( { model
                    | filterBy = text
                    , rv = rvModel
                    , displayedItems = displayedItems
                    , displayedItemsCount = displayedItemsCount
                  }
                , rvCmd
                )

        Select item ->
            let
                newSelectedItems =
                    if Utils.isIncluded item model.selectedItems then
                        List.filter (\i -> i /= item) model.selectedItems
                    else
                        List.append model.selectedItems [ item ]
            in
                ( { model | selectedItems = newSelectedItems }, Cmd.none )

        SelectAll bool ->
            ( { model
                | selectedItems = []
                , allSelected = not bool
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
            , Utils.cmdFromMsg <| InputFilter model.filterBy
            )

        ReturnItems bool ->
            let
                values =
                    if model.allSelected then
                        List.filter
                            (\i -> Utils.isIncluded i model.selectedItems |> not)
                            model.items
                    else
                        model.selectedItems
            in
                ( model, getValuesReturn { values = values, includeNoneUnknown = model.includeNoneUnknown } )

        ToggleIncludeNoneUnknown ->
            ( { model | includeNoneUnknown = not model.includeNoneUnknown }, Cmd.none )

        Scroll pos ->
            ( { model | rv = RV.update model.rv pos }, Cmd.none )

        NoOp ->
            ( model, Cmd.none )


filterItems : Filter -> String -> List Item -> List Item
filterItems selectedFilter filterBy items =
    let
        filter =
            getFilter selectedFilter
    in
        items
            |> List.filterMap
                (\item ->
                    if filterBy == "" || filter filterBy item.name then
                        Just item
                    else
                        Nothing
                )


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


isChecked : Bool -> Bool -> Bool
isChecked allSelected isSelected =
    if allSelected then
        not isSelected
    else
        isSelected


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
renderItemsList { rv, items, displayedItems, displayedItemsCount, selectedItems, selectedFilter, filterBy, allSelected } =
    let
        renderableRows =
            RV.getRenderableElements rv displayedItems

        renderedRows =
            renderableRows
                |> List.map
                    (\item ->
                        Utils.isIncluded item selectedItems
                            |> isChecked allSelected
                            |> renderItem item
                    )
    in
        div
            [ class [ Css.ListContainer ] ]
            [ RV.scrollableContainer
                rv
                displayedItemsCount
                [ RV.onScroll Scroll ]
                renderedRows
            ]


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
        [ input [ type_ "checkbox", onClick ToggleIncludeNoneUnknown, checked includeNoneUnknown ] []
        , text "Include None/Unknown"
        ]


view : Model -> Html Msg
view model =
    let
        isIndeterminate =
            (List.length model.selectedItems) > 0 && (List.length model.selectedItems) < (List.length model.items)

        noneUnknown =
            if model.hasNoneCheckbox then
                renderIncludeNoneUnknown model
            else
                text ""

        allCheckbox =
            if model.allSelected then
                model.allSelected && List.length model.items > List.length model.selectedItems
            else
                List.length model.items == List.length model.selectedItems

        selectedItemsCount =
            if model.allSelected then
                List.length model.items - List.length model.selectedItems
            else
                List.length model.selectedItems
    in
        div [ class [ Css.Container ] ]
            [ div [ class [ Css.ListFilter ] ]
                [ input
                    [ type_ "text"
                    , class [ Css.FilterInput ]
                    , onInput InputFilter
                    , value model.filterBy
                    , placeholder "Type to filter"
                    ]
                    []
                , renderDropDownButton model
                ]
            , div []
                [ label [ class [ Css.Header ] ]
                    [ input
                        [ type_ "checkbox"
                        , onClick <| SelectAll allCheckbox
                        , checked allCheckbox
                        , Utils.indeterminate isIndeterminate
                        ]
                        []
                    , text ""
                    ]
                , renderItemsList model
                ]
            , renderListInfo selectedItemsCount 6500
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
