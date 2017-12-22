module Html.Alternative exposing (..)

{-|


# Alternative definitions of programs

@docs BeginnerProgram
@docs Program


# Useful functions

@docs beginnerProgram
@docs program
@docs tuple2

-}

import Html exposing (Html)


{-| An alternative representation of a "beginner" program.

If we generate a new `model` in the HTML,
it turns out that we don't need to write an `update` function at all.

This representation will push us to write a more declarative UI
by expressing the model as distinct states.

-}
type alias BeginnerProgram model =
    { model : model
    , view : model -> Html model
    }


{-| Create a "beginner" program from an alternative program.
-}
beginnerProgram : BeginnerProgram model -> Platform.Program Never model model
beginnerProgram { model, view } =
    Html.beginnerProgram
        { model = model
        , update = always
        , view = view
        }


{-| An alternative representation of a program.

We can extend the idea of a `BeginnerProgram model`
to other contexts like `Sub` and `Cmd`.

If we again generate a new `model` in all of these contexts:
Commands, HTML, and Subscriptions;
it turns out that we don't need to write an `update` function here either.

This representation will also push us to write a more declarative UI
by expressing the model as distinct states.
Rather than thinking, "when we get this message, create this command;"
we start to think, "all models of this shape, produce this command."

-}
type alias Program model =
    { commands : model -> Cmd model
    , model : model
    , subscriptions : model -> Sub model
    , view : model -> Html model
    }


{-| Create a program from an alternative program.
-}
program : Program model -> Platform.Program Never model model
program { commands, model, subscriptions, view } =
    Html.program
        { init = ( model, commands model )
        , subscriptions = subscriptions
        , update = \model _ -> ( model, commands model )
        , view = view
        }


{-| Combine two programs together so both are displayed at once.

This lets us think about programs separately,
yet still combine them declaratively.

If you've read the paper,
this is the Day convolution of two programs with a pre-determined convolution.

If you haven't read the paper,
congratulations, you're using Day convolution without having to understand it!

-}
tuple2 : Program a -> Program b -> Program ( a, b )
tuple2 a b =
    { commands =
        \( newA, newB ) ->
            Cmd.batch
                [ Cmd.map (\a -> ( a, newB )) (a.commands newA)
                , Cmd.map (\b -> ( newA, b )) (b.commands newB)
                ]
    , model = ( a.model, b.model )
    , subscriptions =
        \( newA, newB ) ->
            Sub.batch
                [ Sub.map (\a -> ( a, newB )) (a.subscriptions newA)
                , Sub.map (\b -> ( newA, b )) (b.subscriptions newB)
                ]
    , view =
        \( newA, newB ) ->
            Html.div
                []
                [ Html.map (\a -> ( a, newB )) (a.view newA)
                , Html.map (\b -> ( newA, b )) (b.view newB)
                ]
    }
