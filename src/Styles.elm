module Styles exposing (..)

import Css exposing (..)
import Css.Elements exposing (..)
import Css.Namespace exposing (namespace)


type CssClasses
    = Container
    | ListContainer
    | ListOptions


css : Stylesheet
css =
    (stylesheet << namespace "long-list")
        [ (.) ListOptions
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
