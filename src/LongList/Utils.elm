module LongList.Utils exposing (..)

import List.Extra as ListExtra
import Html exposing (Attribute)
import Html.Attributes as HtmlAttributes exposing (property)
import Json.Encode as Encode
import Task


indeterminate : Bool -> Attribute msg
indeterminate isIndeterminate =
    property "indeterminate" <| Encode.bool isIndeterminate


cmdFromMsg : msg -> Cmd msg
cmdFromMsg msg =
    Task.perform identity (Task.succeed msg)


isIncluded : a -> List a -> Bool
isIncluded item items =
    let
        filtered =
            ListExtra.find (\i -> i == item) items
    in
        filtered /= Nothing
