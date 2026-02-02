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

- `x`: Nondimensional chordwise coordinates [0, 1]
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
