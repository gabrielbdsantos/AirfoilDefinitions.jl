"""
    normalize(coordinates) -> AbstractMatrix
    normalize!(coordinates)

Normalize airfoil coordinates.

The normalization assumes that coordinates are arranged according to the Selig
ordering and performs the following steps:

1. Identify the leading edge as the point farthest from the midpoint of the
   trailing edge.
2. Translate the coordinates so that the leading edge lies at `(0, 0)`.
3. Scale the coordinates so that the chord length is unity.
4. Rotate the coordinates so that the trailing edge lies at `(1, 0)`.

# Arguments

- `coordinates::AbstractMatrix`: Two-column matrix of airfoil coordinates
  `(x, y)` ordered in Selig format.
"""
function normalize!(coordinates)
    x = @view coordinates[:, 1]
    y = @view coordinates[:, 2]

    # Step 1: identify the leading edge.
    x_te = (x[1] + x[end]) / 2
    y_te = (y[1] + y[end]) / 2

    le_distance = sqrt.((x .- x_te) .^ 2 .+ (y .- y_te) .^ 2)
    le_index = argmax(le_distance)

    # Step 2: translate so that the leading edge is at (0, 0).
    @. x -= x[le_index]
    @. y -= y[le_index]

    # Step 3: scale so that the chord length is 1.
    scale_factor = 1 / le_distance[le_index]
    @. x *= scale_factor
    @. y *= scale_factor

    # Step 4: rotate so that the trailing edge lies at (1, 0).
    x_te = (x[1] + x[end]) / 2
    y_te = (y[1] + y[end]) / 2

    θ = -atan(y_te, x_te)

    x_new = @. cos(θ) * x - sin(θ) * y
    y_new = @. sin(θ) * x + cos(θ) * y

    x .= x_new
    y .= y_new

    return nothing
end


@doc (@doc normalize!)
function normalize(coordinates)
    x = similar(coordinates) .= coordinates
    normalize!(x)
    return x
end


"""
    split_upper_lower_surfaces(coordinates)

Split coordinates into upper and lower surfaces.

# Arguments

- `coordinates::AbstractMatrix`: Matrix of airfoil coordinates with columns
  representing the x and y values.

# Returns

- `(upper, lower)`: Two matrices containing the coordinates of the upper
  and lower surfaces, respectively.
"""
@inline function split_upper_lower_surfaces(coordinates)
    _, n = findmin(@view coordinates[:, 1])
    offset = isodd(size(coordinates, 1)) ? 0 : 1

    return coordinates[1:n, :], coordinates[(n + offset):end, :]
end
