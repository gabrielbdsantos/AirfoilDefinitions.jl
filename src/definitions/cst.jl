"""
    CST{Tu, Tl, Te, Tt, Tn1, Tn2} <: AbstractAirfoilDefinition

Class–-Shape Transformation (CST) airfoil definition.

# Fields

- `upper_weights::Tu`: Weights for the *upper* surface.
- `lower_weights::Tl`: weights for the *lower* surface.
- `leading_edge_weight::Te`: Leading-edge curvature.
- `trailing_edge_thickness::Tt`: Trailing-edge thickness.
- `N1::Tn1`: Leading-edge class exponent (default: 0.5).
- `N2::Tn2`: Trailing-edge class exponent (default: 1.0).
"""
@kwdef struct CST{Tu, Tl, Te, Tt, Tn1, Tn2} <: AbstractAirfoilDefinition
    upper_weights::Tu
    lower_weights::Tl
    leading_edge_weight::Te
    trailing_edge_thickness::Tt
    N1::Tn1 = 0.5
    N2::Tn2 = 1.0
end


"""
    CST(coordinates; num_upper_weights=8, num_lower_weights=8, N1=0.5, N2=1.0)

Fit a CST airfoil definition to a set of input airfoil coordinates.

This constructor performs a nonlinear least-squares fit of the CST
(Class--Shape Transformation) parameterization to the provided airfoil
coordinates. Upper and lower surfaces are fitted simultaneously using Bernstein
polynomial shape functions.

The input coordinates are internally normalized to a unit chord prior to
fitting.

# Arguments

- `coordinates::AbstractMatrix`: Airfoil coordinates following the Selig
  ordering.

# Keyword Arguments

- `num_upper_weights::Int`: Number of Bernstein coefficients used for the upper
  surface shape function.
- `num_lower_weights::Int`: Number of Bernstein coefficients used for the lower
  surface shape function.
- `N1::Real`: Leading-edge class exponent.
- `N2::Real`: Trailing-edge class exponent.

# Returns

- `CST`: A CST representation of the given airfoil coordinates.
"""
function CST(coordinates; num_upper_weights = 8, num_lower_weights = 8, N1 = 0.5, N2 = 1.0)
    normalize!(coordinates)
    coords_upper, coords_lower = split_upper_lower_surfaces(coordinates)

    x_upper = @view coords_upper[:, 1]
    y_upper = @view coords_upper[:, 2]
    x_lower = @view coords_lower[:, 1]
    y_lower = @view coords_lower[:, 2]

    trailing_edge_thickness = y_upper[1] - y_lower[end]

    fit = LsqFit.curve_fit(
        (x, p) -> __coordinates(x, p, length(x_upper), num_upper_weights, N1, N2),
        [x_upper; x_lower],
        [y_upper; y_lower],
        [ones(num_upper_weights + num_lower_weights + 1); trailing_edge_thickness],
        autodiff = :forwarddiff
    )

    offset = 1

    if fit.param[end] < 0
        offset = 0

        fit = LsqFit.curve_fit(
            (x, p) -> __coordinates(x, [p; 0], length(x_upper), num_upper_weights, N1, N2),
            [x_upper; x_lower],
            [y_upper; y_lower],
            ones(num_upper_weights + num_lower_weights + 1),
            autodiff = :forwarddiff
        )
    end

    return CST(
        upper_weights = fit.param[1:num_upper_weights],
        lower_weights = fit.param[(num_upper_weights + 1):(num_upper_weights + num_lower_weights)],
        leading_edge_weight = fit.param[end - offset],
        trailing_edge_thickness = offset * fit.param[end],
        N1 = N1,
        N2 = N2
    )
end


"""
    coordinates(method::CST; num_points=199, kwargs...)

Generate airfoil coordinates using the CST airfoil definition.

# Arguments

- `method::CST`: CST airfoil definition.

# Keyword arguments

- `num_points::Int`: Total number of points used to discretize the airfoil.

# Returns

- `Matrix{<:Real}`: Airfoil coordinates on a unit chord, ordered according
  to the Selig convention.
"""
function coordinates(method::CST; num_points = 199, kwargs...)
    offset = isodd(num_points) ? 1 : 0
    points_per_side = ceil(typeof(num_points), num_points / 2)
    x = (1 .- cos.(LinRange(0, pi, points_per_side))) / 2

    y_upper = cst(
        x, method.upper_weights, method.leading_edge_weight,
        method.trailing_edge_thickness / 2, method.N1, method.N2
    )
    y_lower = cst(
        x, method.lower_weights, method.leading_edge_weight,
        -method.trailing_edge_thickness / 2, method.N1, method.N2
    )

    return [
        reverse(x) reverse(y_upper);
        x[(1 + offset):end] y_lower[(1 + offset):end]
    ]
end


"""
    UnitAirfoil(method::CST; num_points = 199, kwargs...)

Construct a [`UnitAirfoil`](@ref) from a CST airfoil definition.
Coordinates are generated using [`coordinates(::CST)`](@ref).
"""
function UnitAirfoil(method::CST; num_points = 199, kwargs...)
    coords = coordinates(method; num_points, kwargs...)
    return UnitAirfoil{typeof(method), typeof(coords)}(method, coords)
end


"""
    bernstein(x, v, n)

Evaluate the Bernstein basis polynomial of degree `n` and index `v`
(`0 ≤ v ≤ n`) at coordinate(s) `x`.

# Arguments

- `x`: Evaluation points (scalar or array-like).
- `v::Integer`: Index of the basis polynomial.
- `n::Integer`: Degree of the polynomial.

# Returns

- Scalar or array with the same shape as `x`: Value(s) of the Bernstein
  polynomial.
"""
@inline function bernstein(x, v::I, n::I) where {I <: Integer}
    return @. binomial(n, v) * x^v * (1 - x)^(n - v)
end


"""
    class_function(x, N1, N2)

Evaluate the [`CST`](@ref) class function.

# Arguments

- `x`: Nondimensional chordwise coordinates [0, 1].
- `N1::Real`: Leading-edge exponent.
- `N2::Real`: Trailing-edge exponent.

# Returns

- Scalar or array with the same shape as `x`: Value(s) of the class function
"""
@inline function class_function(x, N1, N2)
    return @. (x^N1) * (1 - x)^N2
end


"""
    shape_function(x, coefficients)

CST shape function defined as a weighted sum of Bernstein polynomials.

# Arguments

- `x`: Nondimensional chordwise coordinates [0, 1].
- `coefficients::AbstractVector`: Weights for the Bernstein polynomials.

# Returns

- Scalar or array with the same shape as `x`: Value(s) of the shape function.
"""
@inline function shape_function(x, coefficients)
    S = similar(x) .= 0
    L = length(coefficients)

    for (i, c) in enumerate(coefficients)
        S += c * bernstein(x, i - 1, L - 1)
    end

    return S
end


"""
    cst(x, coefficients, leading_edge_weight, trailing_edge_thickness, N1, N2)

Class--Shape Transformation (CST) airfoil parametrization.

# Arguments

- `x::AbstractVector`: Nondimensional chordwise coordinates [0, 1]
- `coefficients::AbstractVector`: Shape function weights
- `leading_edge_weight::Real`: Leading-edge modification term
- `trailing_edge_thickness::Real`: Trailing-edge thickness parameter
- `N1::Real`: Leading-edge exponent (default: 0.5)
- `N2::Real`: Trailing-edge exponent (default: 1.0)

# Returns

- Array with the same shape as `x`: Airfoil surface coordinates defined by the
  CST parametrization
"""
function cst(x, coefficients, leading_edge_weight, trailing_edge_thickness, N1, N2)
    N = length(coefficients)
    C = class_function(x, N1, N2)
    S = shape_function(x, coefficients)

    return @. C * S +
        x * trailing_edge_thickness +
        leading_edge_weight * x * max(1 - x, 0)^(N + 0.5)
end


function __coordinates(x, parameters, num_upper_points, num_weights_upper, N1, N2)
    weights..., leading_edge_weight, trailing_edge_gap = parameters

    weights_upper = weights[1:num_weights_upper]
    weights_lower = weights[(num_weights_upper + 1):end]

    x_upper = x[1:num_upper_points]
    x_lower = x[(num_upper_points + 1):end]

    y_upper = cst(
        reverse(x_upper), weights_upper, leading_edge_weight, trailing_edge_gap / 2,
        N1, N2
    )
    y_lower = cst(
        x_lower, weights_lower, leading_edge_weight, -trailing_edge_gap / 2,
        N1, N2
    )

    return [reverse(y_upper); y_lower]
end
