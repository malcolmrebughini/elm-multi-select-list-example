port module Stylesheets exposing (..)

import Css.File exposing (CssFileStructure, CssCompilerProgram)
import LongList.LStyles as LongListCss
import Styles as MainCss


port files : CssFileStructure -> Cmd msg


fileStructure : CssFileStructure
fileStructure =
    Css.File.toFileStructure
        [ ( "index.css", Css.File.compile [ MainCss.css, LongListCss.css ] ) ]


main : CssCompilerProgram
main =
    Css.File.compiler files fileStructure
