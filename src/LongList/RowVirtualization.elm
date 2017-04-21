module LongList.RowVirtualization exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Json
import Dom.Scroll exposing (toTop)
import Task


type alias Model =
    { containerHeight : Int
    , elementHeight : Int
    , displayIndexStart : Int
    , displayIndexEnd : Int
    , apertureTop : Int
    }


type alias Pos =
    { scrolledHeight : Int
    , contentHeight : Int
    }


type Msg
    = Scroll Pos


init : Int -> Int -> Model
init containerHeight elementHeight =
    { containerHeight = containerHeight
    , elementHeight = elementHeight
    , displayIndexStart = 0
    , displayIndexEnd = 200
    , apertureTop = 0
    }


onScroll : (Pos -> action) -> Attribute action
onScroll tagger =
    on "scroll" <| Json.map tagger decodeScrollPosition


decodeScrollPosition : Json.Decoder Pos
decodeScrollPosition =
    Json.map2 Pos
        scrollTop
        scrollHeight


scrollTop : Json.Decoder Int
scrollTop =
    Json.at [ "target", "scrollTop" ] Json.int


scrollHeight : Json.Decoder Int
scrollHeight =
    Json.at [ "target", "scrollHeight" ] Json.int


update : Model -> Pos -> Model
update model pos =
    let
        -- After how many pixels scrolled the list, the start and end indexes should be updated
        blockSize =
            model.elementHeight * 50

        -- What blockNumber is displayed currently
        blockNumber =
            pos.scrolledHeight // blockSize

        -- Pixel the block starts
        blockStart =
            blockSize * blockNumber

        -- Pixel the current block ends
        blockEnd =
            blockStart + blockSize

        -- Pixel the blocks should be rendered at
        apertureTop =
            Basics.max 0 (blockStart - blockSize)

        -- Pixel the blocks should be rendered until
        apertureBottom =
            Basics.min pos.contentHeight (blockEnd + blockSize)

        -- Start index to slice
        displayIndexStart =
            apertureTop // model.elementHeight

        -- End index to slice
        displayIndexEnd =
            apertureBottom // model.elementHeight
    in
        { model
            | apertureTop = apertureTop
            , displayIndexStart = displayIndexStart
            , displayIndexEnd = displayIndexEnd
        }


getRenderableElements : Model -> List a -> List a
getRenderableElements { displayIndexStart, displayIndexEnd } items =
    items
        |> List.indexedMap
            (\index item ->
                if displayIndexStart <= index && index < displayIndexEnd then
                    Just item
                else
                    Nothing
            )
        |> List.filterMap (\item -> item)


resetPosition : msg -> Model -> ( Model, Cmd msg )
resetPosition noOp model =
    ( { model | apertureTop = 0 }
    , Task.attempt (always noOp) <| toTop "rowVirtualizationContainer"
    )


scrollableContainer : Model -> Int -> List (Html.Attribute a) -> List (Html a) -> Html a
scrollableContainer model itemsCount attributes children =
    div
        (List.append
            attributes
            [ style
                [ ( "width", "auto" )
                , ( "height", toString model.containerHeight ++ "px" )
                , ( "overflow-y", "scroll" )
                ]
            , id "rowVirtualizationContainer"
            ]
        )
        [ div
            [ style
                [ ( "height", toString ((itemsCount * model.elementHeight) - model.apertureTop) ++ "px" )
                , ( "padding-top", toString model.apertureTop ++ "px" )
                ]
            ]
            (List.append
                [ div
                    [ style
                        []
                    ]
                    []
                ]
                children
            )
        ]
