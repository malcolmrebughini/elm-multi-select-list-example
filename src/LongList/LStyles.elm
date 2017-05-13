module LongList.LStyles exposing (..)

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace exposing (namespace)


type CssClasses
    = Container
    | ListContainer
    | Item
    | Header
    | ListInfo
    | ListFilter
    | FilterInput
    | DropDownButtonContainer
    | ToggleButton
    | ActiveTitle
    | PopupContainer
    | DropDownItem
    | ListOptions
    | Checked
    | CaretIcon


css : Stylesheet
css =
    (stylesheet << namespace "long-list")
        [ (.) Container
            [ position relative
            , padding2 (em 1) (em 1.5)
            ]
        , (.) ListContainer
            [ maxHeight (vh 50)
            , overflow hidden
            , border3 (px 1) solid (hex "d8d8d8")
            ]
        , (.) Item
            [ borderBottom3 (px 1) solid (hex "eaeaea")
            , backgroundColor (hex "FFFFFF")
            , color (hex "888888")
            , cursor pointer
            , width (pct 100)
            , height (px 20)
            , displayFlex
            , alignItems center
            , hover
                [ backgroundColor (hex "b5d6f7") ]
            , children
                [ span
                    [ marginTop (px 1) ]
                , (.) Checked
                    [ backgroundColor (hex "b5d6f7") ]
                ]
            ]
        , (.) Header
            [ backgroundColor (hex "cfcfcf")
            , cursor pointer
            , display block
            ]
        , (.) ListInfo
            [ displayFlex
            , property "justify-content" "space-between"
            , padding2 (em 0.5) (em 1)
            , backgroundColor (hex "FFFFFF")
            , color (hex "888888")
            ]
        , (.) ListFilter
            [ height (em 1.8)
            , displayFlex
            , property "justify-content" "space-between"
            , alignItems center
            , width (pct 100)
            , marginBottom (em 1)
            ]
        , (.) FilterInput
            [ flexGrow (num 2)
            , height (Css.rem 1.8)
            , margin zero
            , paddingLeft (Css.rem 0.5)
            , outline none
            , border3 (px 1) solid (hex "d8d8d8")
            , boxSizing borderBox
            ]
        , (.) DropDownButtonContainer
            [ width (em 8)
            , height (pct 100)
            , boxSizing borderBox
            , float left
            , position relative
            , children
                [ (.) ToggleButton
                    [ width (pct 100)
                    , height (pct 100)
                    , cursor pointer
                    , property "display" "table"
                    , textAlign center
                    , children
                        [ (.) ActiveTitle
                            [ fontSize (em 0.9)
                            , property "display" "table-cell"
                            , verticalAlign middle
                            , color (hex "666666")
                            , children
                                [ (.) CaretIcon
                                    [ float right
                                    , padding2 zero (px 6)
                                    ]
                                ]
                            ]
                        ]
                    ]
                , (.) PopupContainer
                    [ position absolute
                    , width (pct 100)
                    , children
                        [ ul
                            [ children
                                [ (.) DropDownItem
                                    [ padding (Css.rem 0.5)
                                    , borderBottom3 (px 1) solid (hex "eaeaea")
                                    , backgroundColor (hex "cfcfcf")
                                    , cursor pointer
                                    , hover
                                        [ backgroundColor (hex "eaeaea") ]
                                    ]
                                ]
                            ]
                        ]
                    ]
                ]
            ]
        , (.) ListOptions
            [ displayFlex
            , alignItems center
            , color (hex "888888")
            , children
                [ label
                    [ cursor pointer
                    ]
                ]
            ]
        ]
