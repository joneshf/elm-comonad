module Store exposing (..)

{-|


# Data type

@docs Store


# Useful functions

@docs duplicate
@docs extract
@docs map
@docs move


# Using with `Html a`

@docs toBeginnerProgram

-}

import Html exposing (Html)


{-| Convert to a "beginner program" for use in a `main` function

    main : Program Never (Store String (Html a)) a
    main =
        Html.beginnerProgram
            (toBeginnerProgram { here = "Hello, World!", view = Html.text })

-}
toBeginnerProgram :
    Store s (Html a)
    ->
        { model : Store s (Html a)
        , update : s -> Store s (Html a) -> Store s (Html a)
        , view : Store s (Html a) -> Html a
        }
toBeginnerProgram store =
    { model = store
    , update = move
    , view = extract
    }


{-| Pack together the current value along with a function to view said value.

We can specialize the `a` to be `Html a`
and get something that works for top level programs.

We can also not do that.
We can describe many UIs and they don't have to be `Html a`.

-}
type alias Store s a =
    { here : s
    , view : s -> a
    }


{-| Transform the view.

Useful when you want to change the view of an already defined store.

-}
map : (a -> b) -> Store s a -> Store s b
map f store =
    { store | view = f << store.view }


{-| Create a new store where the view is another store.

Gives us the lazy unfolding of all future states of a given store.

-}
duplicate : Store s a -> Store s (Store s a)
duplicate store =
    { store | view = \next -> { here = next, view = store.view } }


{-| View the current value.
-}
extract : Store s a -> a
extract store =
    store.view store.here


{-| Move to the new given value.

This is how we make progress in the UI.

-}
move : s -> Store s a -> Store s a
move s store =
    (duplicate store).view s
