module Tests exposing (all)

import Test exposing (..)
import RowVirtualization


all : Test
all =
    describe "Elm Long List"
        [ RowVirtualization.all
        ]
