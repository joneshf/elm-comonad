module Platform.Alternative exposing (..)

{-|

@docs Program
@docs program

-}


{-| An alternative representation of a program.

If we generate a new `model` in both Commands and Subscriptions,
it turns out that we don't need to write an `update` function at all.

This representation will also push us to write a more declarative program
by expressing the model as distinct states.
Rather than thinking, "when we get this message, create this command;"
we start to think, "all models of this shape, produce this command."

-}
type alias Program model =
    { commands : model -> Cmd model
    , model : model
    , subscriptions : model -> Sub model
    }


{-| Create a headless program from an alternative program.
-}
program :
    { commands : model -> Cmd model
    , model : model
    , subscriptions : model -> Sub model
    }
    -> Platform.Program Never model model
program { commands, model, subscriptions } =
    Platform.program
        { init = ( model, commands model )
        , update = \model _ -> ( model, commands model )
        , subscriptions = subscriptions
        }
