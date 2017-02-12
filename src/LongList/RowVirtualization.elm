module LongList.RowVirtualization exposing (..)

import Html exposing (..)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Json
import Debouncer


type alias Model =
    { containerHeight : Int
    , elementHeight : Int
    , scrolled : Int
    , debouncer : Debouncer.DebouncerState
    }


type alias Pos =
    { scrolledHeight : Int
    , contentHeight : Int
    }


type Msg
    = Scroll Pos
    | DebounceScroll Pos
    | DebouncerMsg (Debouncer.SelfMsg Msg)


init : Int -> Int -> Int -> Model
init containerHeight elementHeight itemsCount =
    { containerHeight = containerHeight
    , elementHeight = elementHeight
    , itemsCount = itemsCount
    , scrolled = 0
    , debouncer = Debouncer.create (50 * Time.millisecond)
    }


onScroll : (Pos -> action) -> Attribute action
onScroll tagger =
    on "scroll" (Json.map tagger decodeScrollPosition)


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


update : Msg -> Model -> ( Model, Cmd Msg )
update msg model =
    case msg of
        DebounceScroll pos ->
            let
                ( debouncer, debouncerCmd ) =
                    model.debouncer |> Debouncer.bounce { id = "scroll", msgToSend = (Scroll pos) }
            in
                { model
                    | debouncer = debouncer
                }
                    ! [ debouncerCmd |> Cmd.map DebouncerMsg ]

        DebouncerMsg debouncerMsg ->
            let
                ( debouncer, cmd ) =
                    model.debouncer |> Debouncer.process debouncerMsg
            in
                { model | debouncer = debouncer } ! [ cmd ]

        Scroll pos ->
            let
                batchSize =
                    2000

                blockNumber =
                    floor (toFloat (pos.scrolledHeight) / batchSize)

                blockStart =
                    batchSize * blockNumber

                blockEnd =
                    blockStart + batchSize

                apertureTop =
                    Debug.log "apertureTop" (max 0 (blockStart - (model.elementHeight * 100)))

                apertureBottom =
                    Debug.log "apertureBottom" (min pos.contentHeight (blockEnd + (model.elementHeight * 100)))

                displayIndexStart =
                    Debug.log "start" (max 0 (floor <| (toFloat apertureTop) / (toFloat model.elementHeight)))

                displayIndexEnd =
                    Debug.log "end" (ceiling <| ((toFloat apertureBottom) / (toFloat model.elementHeight)))

                displayedItems =
                    Array.slice displayIndexStart displayIndexEnd (Lazy.force model.items)
            in
                ( { model | scrolled = apertureTop, displayedItems = displayedItems }, Cmd.none )


view : Model -> List a -> Html Msg
view model rows =
    div
        [ style
            [ ( "width", "auto" )
            , ( "height", toString model.containerHeight ++ "px" )
            , ( "border", "1px solid black" )
            , ( "overflow-y", "scroll" )
            ]
        , onScroll Scroll
        ]
        [ div
            [ style
                [ ( "height", (toString (model.elementHeight * List.length <| rows)) ++ "px" )
                ]
            ]
            rows
        ]
