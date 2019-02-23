Functions in a Kleisli category can be combined via the `>=>`
"fish" operator.[^fish]

[^fish]:
    ```
    (>=>) :: Monad m => (a -> m b) -> (b -> m c) -> a -> m c
    ```
