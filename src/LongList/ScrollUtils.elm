module LongList.ScrollUtils exposing (..)

import Html exposing (Attribute)
import Html.Attributes exposing (..)
import Html.Events exposing (on)
import Json.Decode as Json


type alias Pos =
    { scrolledHeight : Int
    , contentHeight : Int
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


offsetHeight : Json.Decoder Int
offsetHeight =
    Json.at [ "target", "offsetHeight" ] Json.int


clientHeight : Json.Decoder Int
clientHeight =
    Json.at [ "target", "clientHeight" ] Json.int


maxInt : Json.Decoder Int -> Json.Decoder Int -> Json.Decoder Int
maxInt x y =
    Json.map2 Basics.max x y
