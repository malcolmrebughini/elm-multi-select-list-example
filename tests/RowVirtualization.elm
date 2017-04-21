module RowVirtualization exposing (all)

import Test exposing (..)
import Expect exposing (Expectation)
import LongList.RowVirtualization exposing (getRenderableElements)


all : Test
all =
    describe "RowVirtualization"
        [ test "returns chunk from a list given start and end indexes" <|
            \_ ->
                let
                    model =
                        { apertureTop = 0
                        , containerHeight = 500
                        , elementHeight = 100
                        , displayIndexStart = 2
                        , displayIndexEnd = 7
                        }

                    list =
                        [ 1, 2, 3, 4, 5, 6, 7, 8, 9, 10 ]
                in
                    getRenderableElements model list
                        |> Expect.equal [ 3, 4, 5, 6, 7 ]
        ]
