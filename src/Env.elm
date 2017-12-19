module Env exposing (..)

{-|


# Data type

@docs Env


# Useful functions

@docs duplicate
@docs extract
@docs map
@docs move
@docs set


# Using with `Html a`

@docs toBeginnerProgram

-}

import Html exposing (Html)


{-| Pack together the current value along with a computed view of said value.

We can specialize the `a` to be `Html a`
and get something that works for top level programs.

We can also not do that.
We can describe many UIs and they don't have to be `Html a`.

-}
type alias Env e a =
    { here : e
    , view : a
    }


{-| Transform the view.

Useful when you want to change the view of an already defined env.

-}
map : (a -> b) -> Env e a -> Env e b
map f env =
    { env | view = f env.view }


{-| Replace the view.

A common pattern is to just replace the old view without depending on it:
`set x = map (\_ -> x)`

-}
set : b -> Env s a -> Env s b
set b env =
    { env | view = b }


{-| Create a new env where the view is another env.

Gives us the lazy unfolding of all future states of a given env.

-}
duplicate : Env e a -> Env e (Env e a)
duplicate env =
    { env | view = env }


{-| View the current value.
-}
extract : Env e a -> a
extract env =
    env.view


{-| Move to the new given value.

This is how we make progress in the UI.

-}
move : e -> Env e a -> Env e a
move e env =
    case duplicate env of
        { view } ->
            { view | here = e }


{-| Convert to a "beginner program" for use in a `main` function.

    import Env exposing (Env)
    import Html exposing (Html)
    import Html.Events
    import String.Extra

    main : Program Never (Env Int (Int -> Html Int)) Int
    main =
        Html.beginnerProgram
            (Env.toBeginnerProgram { here = 0, view = view })

    view : Int -> Html Int
    view n =
        Html.div
            []
            [ Html.button
                [ Html.Events.onClick (n - 1) ]
                [ Html.text "-" ]
            , Html.div
                []
                [ Html.text (String.Extra.fromInt n) ]
            , Html.button
                [ Html.Events.onClick (n + 1) ]
                [ Html.text "+" ]
            ]

View this example on Ellie: <https://ellie-app.com/fLBqHbdNLa1/0>

-}
toBeginnerProgram :
    Env e (e -> Html a)
    ->
        { model : Env e (e -> Html a)
        , update : e -> Env e (e -> Html a) -> Env e (e -> Html a)
        , view : Env e (e -> Html a) -> Html a
        }
toBeginnerProgram env =
    { model = env
    , update = move
    , view = \env -> extract env env.here
    }
