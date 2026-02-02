"""
    NACA4{Tm, Tp, Tt} <: AbstractAirfoilDefinition

Four-digit NACA airfoil definition.

Represents a classical NACA 4-digit airfoil parameterized by camber, camber
position, and thickness. This type encodes *how* the airfoil is defined, not
its discretized geometry.

# Arguments

- `max_camber::Tm`: Maximum camber as a fraction of the chord.
- `max_camber_position::Tp`: Chordwise position of maximum camber.
- `max_thickness::Tt`: Maximum thickness as a fraction of the chord.
- `open_trailing_edge::Bool`: Whether to use the open trailing-edge
  formulation.
"""
struct NACA4{Tm, Tp, Tt} <: AbstractAirfoilDefinition
    max_camber::Tm
    max_camber_position::Tp
    max_thickness::Tt
    open_trailing_edge::Bool

    @doc """
        NACA4(m, p, t; open_trailing_edge=true)

    Construct a NACA 4-digit airfoil from numerical parameters.

    # Arguments

    - `m`: Maximum camber as a fraction of the chord.
    - `p`: Chordwise position of maximum camber.
    - `t`: Maximum thickness as a fraction of the chord.

    # Keyword arguments

    - `open_trailing_edge`: Whether to use the open trailing-edge formulation.

    An `ArgumentError` is thrown if the parameters are invalid or inconsistent.
    """
    function NACA4(m::Tm, p::Tp, t::Tt; open_trailing_edge = true) where {Tm, Tp, Tt}
        naca4_validate_params(m, p, t)
        return new{Tm, Tp, Tt}(m, p, t, open_trailing_edge)
    end

    @doc """
        NACA4(s::String; open_trailing_edge=true)

    Construct a NACA 4-digit airfoil from a four-digit string.

    The string must contain exactly four digits, following the standard NACA
    convention (e.g. `"2412"`).

    # Arguments

    - `s`: Four-digit NACA airfoil designation.

    # Keyword arguments

    - `open_trailing_edge`: Whether to use the open trailing-edge formulation.

    An `ArgumentError` is thrown if the string does not contain exactly four
    digits.
    """
    function NACA4(s::String; open_trailing_edge = true)
        length(s) == 4 || throw(ArgumentError("expected 4 digits. Got '$(s)'."))

        m = parse(Int, s[1]) / 100
        p = parse(Int, s[2]) / 10
        t = parse(Int, s[3:end]) / 100

        return NACA4(m, p, t; open_trailing_edge)
    end
end


"""
    coordinates(method::NACA4; num_points=199, kwargs...)

Generate airfoil coordinates for a NACA 4-digit airfoil.

# Arguments

- `method::NACA4`: four-digit NACA airfoil definition.

# Keyword arguments

- `num_points::Int`: Total number of points used to discretize the airfoil.

# Returns

- `::Matrix`: Airfoil coordinates on a unit chord, ordered according
  to the Selig convention.
"""
function coordinates(method::NACA4; num_points = 199, kwargs...)
    points_per_side = ceil(typeof(num_points), num_points / 2)
    x = (1 .- cos.(LinRange(0, pi, points_per_side))) / 2

    half_thickness = naca4_half_thickness.(x, method.max_thickness, method.open_trailing_edge)

    if method.max_camber == 0 || method.max_camber_position == 0
        x_upper = x
        x_lower = x
        y_upper = half_thickness
        y_lower = -half_thickness
    else
        y_camber = naca4_camberline.(x, method.max_camber, method.max_camber_position)
        θ = atan.(naca4_derivative.(x, method.max_camber, method.max_camber_position))

        x_upper = @. x - half_thickness * sin(θ)
        x_lower = @. x + half_thickness * sin(θ)
        y_upper = @. y_camber + half_thickness * cos(θ)
        y_lower = @. y_camber - half_thickness * cos(θ)
    end

    offset = isodd(num_points) ? 1 : 0

    return [
        reverse(x_upper)[1:(end - offset)] reverse(y_upper)[1:(end - offset)];
        x_lower y_lower
    ]
end


"""
    UnitAirfoil(method::NACA4; num_points = 199, kwargs...)

Construct a [`UnitAirfoil`](@ref) from a NACA 4-digit airfoil definition.
Coordinates are generated using [`coordinates(::NACA4)`](@ref).
"""
function UnitAirfoil(method::NACA4; num_points = 199, kwargs...)
    coords = coordinates(method; num_points, kwargs...)
    return UnitAirfoil{typeof(method), typeof(coords)}(method, coords)
end


"""
    naca4_validate_params(m, p, t)

Validate NACA 4-digit airfoil parameters.

Ensures that camber, camber position, and thickness parameters fall within
physically meaningful bounds and are mutually consistent.

# Arguments

- `m`: Maximum camber as a fraction of the chord.
- `p`: Chordwise position of maximum camber.
- `t`: Maximum thickness as a fraction of the chord.
"""
function naca4_validate_params(m, p, t)
    if m < 0 || m >= 0.1
        throw(ArgumentError("the maximum camber should be in [0, 0.1). Got m = $m"))
    end

    if p < 0 || p >= 1
        throw(ArgumentError("the maximum camber should be in [0, 1). Got p = $p"))
    end

    if t < 0 || t >= 1
        throw(ArgumentError("the maximum camber should be in [0, 1). Got t = $t."))
    end

    return if (m == 0 && p != 0) || (m != 0 && p == 0)
        throw(
            ArgumentError(
                "if either `m` or `p` are zero, then both should be zero. " *
                    "Got m = $m and p = $p."
            )
        )
    end
end


"""
    naca4_half_thickness(x, t, open_trailing_edge)

Return the half-thickness distribution of a NACA 4-digit airfoil.

# Arguments

- `x`: Chordwise coordinate in `[0, 1]`.
- `t`: Maximum thickness as a fraction of the chord.
- `open_trailing_edge`: Whether to use the open trailing-edge formulation.
"""
function naca4_half_thickness(x, t, open_trailing_edge)
    return (
        5 * t * (
            0.2969 * sqrt(x)
                - 0.126 * x
                - 0.3516 * x^2
                + 0.2843 * x^3
                - ifelse(open_trailing_edge, 0.1015, 0.1036) * x^4
        )
    )
end


"""
    naca4_camberline(x, m, p)

Return the camberline ordinate at chordwise location `x`.

# Arguments

- `x`: Chordwise coordinate in `[0, 1]`.
- `m`: Maximum camber as a fraction of the chord.
- `p`: Chordwise position of maximum camber.
"""
function naca4_camberline(x, m, p)
    return ifelse(
        x < p,
        m / p^2 * ((2p * x) - x^2),
        m / (1 - p)^2 * ((1 - 2p) + (2p * x) - x^2)
    )
end


"""
    naca4_derivative(x, m, p)

Return the derivative of the camberline at chordwise location `x`.

# Arguments

- `x`: Chordwise coordinate in `[0, 1]`.
- `m`: Maximum camber as a fraction of the chord.
- `p`: Chordwise position of maximum camber.
"""
function naca4_derivative(x, m, p)
    return 2 * m / ifelse(x < p, (p * p), (1 - p)^2) * (p - x)
end
