module Traced
    exposing
        ( Traced
        , addition
        , duplicate
        , extract
        , list
        , map
        , move
        , multiplication
        , set
        , string
        , toBeginnerProgram
        , view
        )

{-|


# Data type

@docs Traced


# Useful functions

@docs duplicate
@docs extract
@docs map
@docs move
@docs set
@docs view


# Defined traces

@docs addition
@docs list
@docs multiplication
@docs string


# Using with `Html a`

@docs toBeginnerProgram

-}

import Html exposing (Html)


{-| Pack together an accumulator, a unique value,
and a function to view the value.

Accumulates new values together in most operations.

This is very similar to `Store a b`.
The difference being that a `Traced a b` accumulates the `a`
as it unfolds all future states,
whereas a `Store a b` replaces all `a`s as it unfolds all future states.

-}
type Traced m a
    = Traced (m -> m -> m) m (m -> a)


{-| Creates a traced that accumulates with addition.

The unique value is 0.

-}
addition : Traced number number
addition =
    Traced (+) 0 identity


{-| Creates a traced that accumulates lists.

The unique value is the empty list.

-}
list : Traced (List a) (List a)
list =
    Traced (++) [] identity


{-| Creates a traced that accumulates with multiplication.

The unique value is 1.

-}
multiplication : Traced number number
multiplication =
    Traced (*) 1 identity


{-| Creates a traced that accumulates strings.

The unique value is the empty string.

-}
string : Traced String String
string =
    Traced (++) "" identity


{-| Returns the view of a traced.

Useful when you want to view the value,
with something other than the unique value of the traced.

-}
view : Traced m a -> m -> a
view (Traced _ _ view) =
    view


{-| Transform the view.

Useful when you want to change the view of an already defined traced.

-}
map : (a -> b) -> Traced m a -> Traced m b
map f (Traced append empty view) =
    Traced append empty (f << view)


{-| Replace the view.

A common pattern is to just replace the old view without depending on it:
`set x = map (\_ -> x)`

-}
set : b -> Traced m a -> Traced m b
set b (Traced append empty _) =
    Traced append empty (always b)


{-| Create a new traced where the view is another traced.

Gives us the lazy unfolding of all future states of a given traced.

-}
duplicate : Traced m a -> Traced m (Traced m a)
duplicate (Traced append empty view) =
    Traced append empty (\m -> Traced append empty (view << append m))


{-| View the current value.
-}
extract : Traced m a -> a
extract (Traced _ empty view) =
    view empty


{-| Move to the new given value.

This is how we make progress in the UI.

-}
move : m -> Traced m a -> Traced m a
move m traced =
    view (duplicate traced) m


{-| Convert to a "beginner program" for use in a `main` function

    import Html exposing (Html)
    import Html.Events
    import String.Extra
    import Traced exposing (Traced)

    main : Program Never (Traced String (Html a)) a
    main =
        Html.beginnerProgram
            (Traced.toBeginnerProgram (Traced.map view Traced.addition))

    view : Int -> Html Int
    view n =
        Html.div []
            [ Html.button
                [ Html.Events.onClick -1 ]
                [ Html.text "-" ]
            , Html.div
                []
                [ Html.text (String.Extra.fromInt n) ]
            , Html.button
                [ Html.Events.onClick 1 ]
                [ Html.text "+" ]
            ]

-}
toBeginnerProgram :
    Traced m (Html a)
    ->
        { model : Traced m (Html a)
        , update : m -> Traced m (Html a) -> Traced m (Html a)
        , view : Traced m (Html a) -> Html a
        }
toBeginnerProgram traced =
    { model = traced
    , update = move
    , view = extract
    }
