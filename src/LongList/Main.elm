port module LongList exposing (..)

import Html exposing (..)
import Html.Attributes as HtmlAttributes exposing (type_, checked, placeholder, value, property, style)
import Html.Events exposing (..)
import List.Extra exposing (elemIndex, remove, groupsOf)
import Regex
import Json.Encode as Encode
import LongList.ScrollUtils as ScrollUtils
import LongList.Styles as Css
import Html.CssHelpers
import Css exposing (px, height)
import LongList.ScrollUtils exposing (..)
import Debouncer
import Time
import Array.Hamt as Array
import Array.Extra
import Lazy exposing (Lazy)


{ id, class, classList } =
    Html.CssHelpers.withNamespace "long-list"


styles : List Css.Mixin -> Attribute msg
styles =
    Css.asPairs >> style


type alias Model =
    { items : Lazy (Array.Array Item)
    , displayedItems : Array.Array Item
    , filterBy : String
    , selectedItems : Array.Array Item
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
    = Input String
    | Select Item
    | SelectAll
    | ToggleDropDown
    | SelectFilter Filter
    | ReturnItems Bool
    | ToggleIncludeNoneUnknown


init : Flags -> ( Model, Cmd Msg )
init flags =
    ( { items = Lazy.lazy (\_ -> Array.fromList (flags.options))
      , displayedItems = Array.slice 0 200 (Array.fromList flags.options)
      , filterBy = ""
      , selectedItems = Array.fromList flags.selectedOptions
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
                    if isSelected item model.selectedItems then
                        Array.filter (\i -> i /= item) model.selectedItems
                    else
                        Array.push item model.selectedItems
            in
                ( { model | selectedItems = newSelectedItems }, Cmd.none )

        SelectAll ->
            ( { model
                | selectedItems = Array.empty
                , allSelected = not model.allSelected
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
            ( model, getValuesReturn { values = Array.toList model.selectedItems, includeNoneUnknown = model.includeNoneUnknown } )

        ToggleIncludeNoneUnknown ->
            ( { model | includeNoneUnknown = not model.includeNoneUnknown }, Cmd.none )


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


isSelected : Item -> Array.Array Item -> Bool
isSelected item selectedItems =
    let
        filtered =
            Array.filter (\i -> i == item) selectedItems
    in
        filtered /= Array.empty


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
renderItemsList { items, displayedItems, selectedItems, selectedFilter, filterBy, allSelected, containerHeight, elementHeight, scrolled } =
    let
        filter =
            getFilter selectedFilter
    in
        div
            [ class [ Css.ListContainer ], styles [ height (px (toFloat containerHeight)) ] ]
            --            [ class [ Css.ListContainer ], styles [ height (px (toFloat containerHeight)) ], onScroll Scroll ]
            --            [ div [ styles [ height (px (toFloat ((Array.length (Lazy.force items)) * elementHeight))) ] ]
            [ div [ styles [ height (px (toFloat (6500 * elementHeight))) ] ]
                (List.append
                    [ div [ styles [ height (px (toFloat scrolled)) ] ] [] ]
                    --                    [ div [] [] ]
                    (List.filterMap
                        (\item ->
                            if filterBy == "" || filter filterBy item.name then
                                --                        if item.id == 1 then
                                Just (renderItem item (allSelected || (isSelected item selectedItems)))
                            else
                                Nothing
                        )
                        (Array.toList displayedItems)
                    )
                )
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
        [ input [ type_ "checkbox", onClick (ToggleIncludeNoneUnknown), checked includeNoneUnknown ] []
        , text "Include None/Unknown"
        ]


indeterminate : Bool -> Attribute msg
indeterminate isIndeterminate =
    property "indeterminate" (Encode.bool isIndeterminate)


view : Model -> Html Msg
view model =
    let
        isIndeterminate =
            (Array.length model.selectedItems) > 0 && (Array.length model.selectedItems) < (Array.length (Lazy.force model.items))

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
                    [ input [ type_ "checkbox", onClick SelectAll, checked model.allSelected, indeterminate isIndeterminate ] []
                    , text ""
                    ]
                , renderItemsList model
                ]
              --            , renderListInfo (Array.length model.selectedItems) (Array.length (Lazy.force model.items))
            , renderListInfo (Array.length model.selectedItems) 6500
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
