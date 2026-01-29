"""
    normalize!(coordinates)

Normalize airfoil coordinates in place.

The normalization assumes that coordinates follow the Selig ordering and
follows the steps:

1. Translate the coordinates so that the leading edge lies at `(0, 0)`.
2. Scale the coordinates so that the chord length is unity.
3. Rotate the coordinates so that the trailing edge lies at `(1, 0)`.

## Arguments

- `coordinates<:AbstractMatrix`: Two-column matrix of airfoil coordinates
  `(x, y)` ordered in Selig format, with the first and last rows corresponding
  to the trailing edge.
"""
function normalize!(coordinates)
    x = @view coordinates[:, 1]
    y = @view coordinates[:, 2]

    # Step 1: translate so that the leading edge is at (0, 0).
    x_te = (x[1] + x[end]) / 2
    y_te = (y[1] + y[end]) / 2

    le_distance = ((x .- x_te) .^ 2 .+ (y .- y_te) .^ 2) .^ 0.5
    le_index = argmax(le_distance)

    @. x -= x[le_index]
    @. y -= y[le_index]

    # Step 2: scale so that the chord length is 1.
    scale_factor = 1 / le_distance[le_index]
    @. x *= scale_factor
    @. y *= scale_factor

    # Step 3: rotate so that the trailing edge lies at (1, 0).
    x_te = (x[1] + x[end]) / 2
    y_te = (y[1] + y[end]) / 2

    θ = atan(y_te, x_te)
    cosθ = cos(-θ)
    sinθ = sin(-θ)

    x_new = @. cosθ * x - sinθ * y
    y_new = @. sinθ * x + cosθ * y

    x .= x_new
    y .= y_new

    return nothing
end
