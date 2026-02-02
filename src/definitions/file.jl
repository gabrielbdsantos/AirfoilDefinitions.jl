"""
    AirfoilFile <: AbstractAirfoilDefinition

Generic airfoil definition that reads the coordinates stored in an external
file.

The file is expected to contain two columns representing `(x, y)` coordinates,
ordered according to the Selig format. The geometry is read and normalized when
coordinates are requested.
"""
struct AirfoilFile <: AbstractAirfoilDefinition
    filename::String
end


"""
    coordinates(method::AirfoilFile; kwargs...)

Read and return normalized airfoil coordinates from a file.

The coordinates are normalized in place to a canonical reference frame (unit
chord, leading edge at the origin, Selig ordering).

# Arguments

- `method::AirfoilFile`: Generic airfoil definition stored in an external file.
"""
function coordinates(method::AirfoilFile; kwargs...)
    c = DelimitedFiles.readdlm(method.filename)
    normalize!(c)
    return c
end


"""
    UnitAirfoil(method::AirfoilFile; kwargs...)

Construct a [`UnitAirfoil`](@ref) by reading and normalazing the coordinates in
a file.
"""
function UnitAirfoil(method::AirfoilFile; kwargs...)
    coords = coordinates(method; kwargs...)
    return UnitAirfoil{typeof(method), typeof(coords)}(method, coords)
end
